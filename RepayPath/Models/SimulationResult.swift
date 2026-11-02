import Foundation

/// 单笔贷款的输入参数
struct LoanInput: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var plan: LoanPlan
    var balance: Double              // 当前余额 £
    var annualSalary: Double         // 税前年薪 £
    var salaryGrowth: Double         // 年薪年增长率，如 0.03
    var interestRate: Double         // 年利率，如 0.065（用户可调）
    var firstRepayYear: Int          // 首次应还款的年份（该年 4 月起算）

    static func initial() -> LoanInput {
        LoanInput(
            plan: .plan2,
            balance: 45_000,
            annualSalary: 55_000,
            salaryGrowth: 0.03,
            interestRate: 0.065,
            firstRepayYear: Calendar.current.component(.year, from: Date())
        )
    }
}

/// 模拟结果
struct SimulationResult: Codable, Equatable {
    var monthsToPayOff: Int?         // nil = 未还清，最终被注销
    var payoffYear: Int?             // 还清年份
    var payoffMonth: Int?            // 还清月份（1-12）
    var writeOffYear: Int            // 注销年份
    var totalRepaid: Double          // 累计还款
    var totalInterest: Double        // 累计利息
    var balanceAtWriteOff: Double    // 注销时的余额（未还清时 > 0）
    var monthlyRepaymentNow: Double  // 当前每月应扣

    var isPaidOff: Bool { monthsToPayOff != nil }
}

/// 曲线上的一个采样点（按年）
struct YearPoint: Identifiable {
    var id: Int { year }
    var year: Int
    var balance: Double
    var cumulativeRepaid: Double
}
