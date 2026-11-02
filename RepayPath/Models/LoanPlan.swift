import Foundation

/// 还款计划类型。门槛与规则来源：gov.uk/repaying-your-student-loan
/// 数据核对日期：2026-11-02
enum LoanPlan: String, CaseIterable, Identifiable, Codable {
    case plan1
    case plan2
    case plan4
    case plan5
    case postgraduate

    var id: String { rawValue }

    /// 2026/27 月度收入门槛（£）
    var monthlyThreshold: Double {
        switch self {
        case .plan1:        return 2241
        case .plan2:        return 2448
        case .plan4:        return 2816
        case .plan5:        return 2083
        case .postgraduate: return 1750
        }
    }

    /// 年度门槛（£）
    var yearlyThreshold: Double { monthlyThreshold * 12 }

    /// 超出门槛部分的还款比例
    var repaymentRate: Double {
        switch self {
        case .postgraduate: return 0.06
        default:            return 0.09
        }
    }

    /// 从"首次应还款的 4 月"起，多少年后注销
    var writeOffYears: Int {
        switch self {
        case .plan1:        return 25
        case .plan2:        return 30
        case .plan4:        return 30
        case .plan5:        return 40
        case .postgraduate: return 30
        }
    }

    var title: String {
        switch self {
        case .plan1:        return L10n.plan1
        case .plan2:        return L10n.plan2
        case .plan4:        return L10n.plan4
        case .plan5:        return L10n.plan5
        case .postgraduate: return L10n.postgraduate
        }
    }

    /// 面向用户的简短说明
    var summary: String {
        switch self {
        case .plan1:        return L10n.plan1Summary
        case .plan2:        return L10n.plan2Summary
        case .plan4:        return L10n.plan4Summary
        case .plan5:        return L10n.plan5Summary
        case .postgraduate: return L10n.postgraduateSummary
        }
    }
}
