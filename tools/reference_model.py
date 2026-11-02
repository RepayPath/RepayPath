#!/usr/bin/env python3
"""英国学贷还款参考模型（用于验证 Swift 实现前的算法正确性）。
规则来源：gov.uk/repaying-your-student-loan（2026-10-22 更新）
"""
from dataclasses import dataclass

# 2026/27 门槛（官方表格）
PLANS = {
    "Plan 1":       {"monthly": 2241, "rate": 0.09, "writeoff_years": 25},
    "Plan 2":       {"monthly": 2448, "rate": 0.09, "writeoff_years": 30},
    "Plan 4":       {"monthly": 2816, "rate": 0.09, "writeoff_years": 30},
    "Plan 5":       {"monthly": 2083, "rate": 0.09, "writeoff_years": 40},
    "Postgraduate": {"monthly": 1750, "rate": 0.06, "writeoff_years": 30},
}


def monthly_repayment(plan: str, monthly_income: float) -> float:
    """每月应扣（未取整）"""
    p = PLANS[plan]
    excess = monthly_income - p["monthly"]
    return max(0.0, excess) * p["rate"]


@dataclass
class Result:
    months_to_payoff: int | None      # None = 未还清，靠注销
    payoff_date: str | None
    written_off: bool
    total_repaid: float
    total_interest: float
    final_balance: float


def simulate(plan: str, balance: float, annual_salary: float,
             salary_growth: float = 0.03, annual_rate: float = 0.065,
             first_repay_year: int = 2027, max_years: int = 45) -> Result:
    """按月模拟。4 月按年调整薪资，不足一个月按比例扣（简化：按月计息、按月扣款）。"""
    p = PLANS[plan]
    writeoff_year = first_repay_year + p["writeoff_years"]
    monthly_rate = annual_rate / 12.0
    bal = balance
    total_repaid = 0.0
    total_interest = 0.0
    salary = annual_salary
    year = first_repay_year
    month = 4  # 从首个应还款的 4 月开始

    for m in range(max_years * 12):
        if year >= writeoff_year:
            return Result(None, None, True, total_repaid, total_interest, bal)

        interest = bal * monthly_rate
        bal += interest
        total_interest += interest

        due = monthly_repayment(plan, salary / 12.0)
        pay = min(due, bal)      # 扣款不超过余额
        bal -= pay
        total_repaid += pay

        if bal <= 0.005:
            return Result(m + 1, f"{year}-{month:02d}", False, total_repaid, total_interest, 0.0)

        month += 1
        if month > 12:
            month = 1
            year += 1
            salary *= (1 + salary_growth)

    return Result(None, None, True, total_repaid, total_interest, bal)


if __name__ == "__main__":
    print("=" * 62)
    print("① 官方样例校验（必须与 gov.uk 一致）")
    print("=" * 62)
    for plan, salary, expect in [("Plan 1", 33000, 45.81), ("Plan 4", 36000, 16.56)]:
        got = monthly_repayment(plan, salary / 12)
        ok = abs(got - expect) < 0.01
        print(f"  {plan} 年薪 £{salary:,} → 每月 £{got:,.2f}  官方 £{expect}  {'✅' if ok else '❌ 不一致'}")

    print()
    print("=" * 62)
    print("② 场景模拟")
    print("=" * 62)
    cases = [
        ("Plan 2", 45000, 30000, "低薪：月扣款很小，可能一辈子还不完"),
        ("Plan 2", 45000, 40000, "中薪"),
        ("Plan 2", 45000, 60000, "高薪：能在注销前还清"),
        ("Plan 5", 60000, 35000, "Plan 5：门槛低但期限 40 年"),
        ("Postgraduate", 12000, 32000, "研究生贷款 6%"),
    ]
    for plan, bal, sal, note in cases:
        r = simulate(plan, bal, sal)
        if r.written_off:
            print(f"  {plan:13s} 余额 £{bal:>6,} 年薪 £{sal:>6,} → ❌ 未还清，{PLANS[plan]['writeoff_years']} 年后注销"
                  f"（累计已还 £{r.total_repaid:,.0f}，注销时余额 £{r.final_balance:,.0f}）  # {note}")
        else:
            print(f"  {plan:13s} 余额 £{bal:>6,} 年薪 £{sal:>6,} → ✅ {r.months_to_payoff} 个月（{r.payoff_date}）还清"
                  f"，累计还 £{r.total_repaid:,.0f}，利息 £{r.total_interest:,.0f}  # {note}")

    print()
    print("=" * 62)
    print("③ 多还款影响（App 核心卖点：这是 gov.uk 不给你的）")
    print("=" * 62)
    base = simulate("Plan 2", 45000, 55000)
    print(f"  基准：{base.months_to_payoff} 个月还清，利息 £{base.total_interest:,.0f}")
    for extra in (50, 100, 200):
        # 每月额外还款：用提高"收入"的等价方式模拟不便，改为直接循环
        bal = 45000.0
        monthly_rate = 0.065 / 12
        month = 0
        salary, year, mon = 55000.0, 2027, 4
        while bal > 0 and month < 45 * 12:
            bal += bal * monthly_rate
            pay = min(monthly_repayment("Plan 2", salary / 12) + extra, bal)
            bal -= pay
            month += 1
            if month % 12 == 0:
                salary *= 1.03
        saved_months = base.months_to_payoff - month
        print(f"  每月多还 £{extra:>3} → {month} 个月还清（提前 {saved_months} 个月 ≈ {saved_months/12:.1f} 年）")
