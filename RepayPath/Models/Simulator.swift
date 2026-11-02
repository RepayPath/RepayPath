import Foundation

/// 核心计算引擎。全部本地、纯函数、无网络。
/// 规则依据：gov.uk/repaying-your-student-loan（核对日期 2026-11-02）
enum Simulator {

    /// 每月应扣款（未取整）。官方示例：Plan 1 年薪 £33,000 → £45.81
    static func monthlyRepayment(plan: LoanPlan, monthlyIncome: Double) -> Double {
        let excess = monthlyIncome - plan.monthlyThreshold
        guard excess > 0 else { return 0 }
        return excess * plan.repaymentRate
    }

    /// 按月模拟还款全过程
    static func simulate(_ input: LoanInput,
                         extraMonthly: Double = 0,
                         lumpSum: Double = 0) -> SimulationResult {
        let writeOffYear = input.firstRepayYear + input.plan.writeOffYears
        let monthlyRate = input.interestRate / 12.0

        var balance = max(0, input.balance - max(0, lumpSum))
        var salary = input.annualSalary
        var totalRepaid = 0.0
        var totalInterest = 0.0
        var year = input.firstRepayYear
        var month = 4                       // 从首个应还款的 4 月起算
        let maxMonths = 60 * 12             // 安全上限，正常不会触达

        let monthlyNow = monthlyRepayment(plan: input.plan, monthlyIncome: salary / 12.0)

        for step in 0..<maxMonths {
            if year >= writeOffYear {
                return SimulationResult(
                    monthsToPayOff: nil, payoffYear: nil, payoffMonth: nil,
                    writeOffYear: writeOffYear,
                    totalRepaid: totalRepaid, totalInterest: totalInterest,
                    balanceAtWriteOff: balance, monthlyRepaymentNow: monthlyNow
                )
            }

            // 1) 计息
            let interest = balance * monthlyRate
            balance += interest
            totalInterest += interest

            // 2) 扣款（不超过余额）
            let due = monthlyRepayment(plan: input.plan, monthlyIncome: salary / 12.0) + max(0, extraMonthly)
            let paid = min(due, balance)
            balance -= paid
            totalRepaid += paid

            // 3) 是否还清
            if balance <= 0.005 {
                return SimulationResult(
                    monthsToPayOff: step + 1, payoffYear: year, payoffMonth: month,
                    writeOffYear: writeOffYear,
                    totalRepaid: totalRepaid, totalInterest: totalInterest,
                    balanceAtWriteOff: 0, monthlyRepaymentNow: monthlyNow
                )
            }

            month += 1
            if month > 12 {
                month = 1
                year += 1
                salary *= (1 + input.salaryGrowth)     // 每年 4 月起按增长率调整
            }
        }

        return SimulationResult(
            monthsToPayOff: nil, payoffYear: nil, payoffMonth: nil,
            writeOffYear: writeOffYear,
            totalRepaid: totalRepaid, totalInterest: totalInterest,
            balanceAtWriteOff: balance, monthlyRepaymentNow: monthlyNow
        )
    }

    /// 按年采样，供曲线图使用
    static func yearlyPoints(_ input: LoanInput,
                             extraMonthly: Double = 0,
                             lumpSum: Double = 0) -> [YearPoint] {
        let writeOffYear = input.firstRepayYear + input.plan.writeOffYears
        let monthlyRate = input.interestRate / 12.0
        var balance = max(0, input.balance - max(0, lumpSum))
        var salary = input.annualSalary
        var cumulative = 0.0
        var year = input.firstRepayYear
        var month = 4
        var points: [YearPoint] = [YearPoint(year: year, balance: balance, cumulativeRepaid: 0)]

        for _ in 0..<(60 * 12) {
            if year >= writeOffYear || balance <= 0.005 { break }
            let interest = balance * monthlyRate
            balance += interest
            let due = monthlyRepayment(plan: input.plan, monthlyIncome: salary / 12.0) + max(0, extraMonthly)
            let paid = min(due, balance)
            balance -= paid
            cumulative += paid

            month += 1
            if month > 12 {
                month = 1
                year += 1
                salary *= (1 + input.salaryGrowth)
                points.append(YearPoint(year: year, balance: max(0, balance), cumulativeRepaid: cumulative))
            }
        }
        if let last = points.last, last.year != year {
            points.append(YearPoint(year: year, balance: max(0, balance), cumulativeRepaid: cumulative))
        }
        return points
    }

    /// 多还模拟：每月多还 amount
    static func whatIf(_ input: LoanInput, extraMonthly: Double) -> SimulationResult {
        simulate(input, extraMonthly: extraMonthly)
    }
}
