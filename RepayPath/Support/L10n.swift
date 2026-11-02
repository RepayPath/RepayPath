import Foundation

/// 全部面向用户的文案集中在这里，便于本地化与审阅（英/中）
enum L10n {
    private static func t(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    // MARK: 计划
    static var plan1: String { t("plan.plan1") }
    static var plan2: String { t("plan.plan2") }
    static var plan4: String { t("plan.plan4") }
    static var plan5: String { t("plan.plan5") }
    static var postgraduate: String { t("plan.postgraduate") }

    static var plan1Summary: String { t("plan.plan1.summary") }
    static var plan2Summary: String { t("plan.plan2.summary") }
    static var plan4Summary: String { t("plan.plan4.summary") }
    static var plan5Summary: String { t("plan.plan5.summary") }
    static var postgraduateSummary: String { t("plan.postgraduate.summary") }

    // MARK: 通用
    static var appName: String { t("app.name") }
    static var tabPlan: String { t("tab.plan") }
    static var tabResult: String { t("tab.result") }
    static var tabCompare: String { t("tab.compare") }
    static var tabInfo: String { t("tab.info") }

    // MARK: 输入
    static var sectionLoan: String { t("input.section.loan") }
    static var labelPlan: String { t("input.plan") }
    static var labelBalance: String { t("input.balance") }
    static var labelSalary: String { t("input.salary") }
    static var labelGrowth: String { t("input.growth") }
    static var labelRate: String { t("input.rate") }
    static var labelFirstYear: String { t("input.firstYear") }
    static var hintBalance: String { t("input.balance.hint") }
    static var hintSalary: String { t("input.salary.hint") }
    static var hintRate: String { t("input.rate.hint") }
    static var hintFirstYear: String { t("input.firstYear.hint") }
    static var resetToTypical: String { t("input.reset") }

    // MARK: 结果
    static var resultMonthly: String { t("result.monthly") }
    static var resultPayoff: String { t("result.payoff") }
    static var resultNever: String { t("result.never") }
    static var resultNeverDetail: String { t("result.never.detail") }
    static var resultTotalRepaid: String { t("result.totalRepaid") }
    static var resultTotalInterest: String { t("result.totalInterest") }
    static var resultWriteOff: String { t("result.writeOff") }
    static var resultBalanceLeft: String { t("result.balanceLeft") }
    static var resultCardPaidTitle: String { t("result.card.paid") }
    static var resultCardWriteOffTitle: String { t("result.card.writeoff") }
    static var resultNoneYet: String { t("result.none") }

    // MARK: 对比
    static var compareTitle: String { t("compare.title") }
    static var compareSubtitle: String { t("compare.subtitle") }
    static var compareBase: String { t("compare.base") }
    static var compareExtra: String { t("compare.extra") }
    static var compareSaved: String { t("compare.saved") }
    static var compareEarliest: String { t("compare.earliest") }
    static var compareNoChange: String { t("compare.nochange") }
    static var compareLumpSum: String { t("compare.lump") }

    // MARK: 说明
    static var infoWhatThis: String { t("info.what") }
    static var infoWhatThisBody: String { t("info.what.body") }
    static var infoRules: String { t("info.rules") }
    static var infoThresholds: String { t("info.thresholds") }
    static var infoRates: String { t("info.rates") }
    static var infoWriteOff: String { t("info.writeoff") }
    static var infoWriteOffTitle: String { t("info.writeoff.title") }
    static var infoSources: String { t("info.sources") }
    static var infoDisclaimerTitle: String { t("info.disclaimer.title") }
    static var infoDisclaimer: String { t("info.disclaimer") }
    static var infoPrivacyTitle: String { t("info.privacy.title") }
    static var infoPrivacy: String { t("info.privacy") }
    static var infoVerified: String { t("info.verified") }

    // MARK: 对比（补充）
    static var comparePresets: String { t("compare.presets") }
    static var compareSavePrompt: String { t("compare.savePrompt") }
    static var compareSave: String { t("compare.save") }
    static var compareNoSaved: String { t("compare.noSaved") }
    static var compareExtraAmount: String { t("compare.extraAmount") }
    static var compareSavedMonths: String { t("compare.savedMonths") }

    // MARK: 图表
    static var chartTitle: String { t("chart.title") }
    static var chartEmpty: String { t("chart.empty") }
    static var chartLegendBalance: String { t("chart.legend.balance") }
    static var chartLegendRepaid: String { t("chart.legend.repaid") }
}
