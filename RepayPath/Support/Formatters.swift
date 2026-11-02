import Foundation

/// 日期/年份展示格式
enum YearMonth {
    /// 2057 年 4 月 → 本地化后： "April 2057"
    static func label(year: Int, month: Int) -> String {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        let cal = Calendar(identifier: .gregorian)
        guard let date = cal.date(from: comps) else { return String(year) }
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return f.string(from: date)
    }

    /// 只到年份： "2057"
    static func year(_ year: Int) -> String {
        String(year)
    }

    /// 把月数转成「X 年 Y 个月」
    static func duration(months: Int) -> String {
        let y = months / 12
        let m = months % 12
        if y == 0 { return "\(m) mo" }
        if m == 0 { return "\(y) yr" }
        return "\(y) yr \(m) mo"
    }
}
