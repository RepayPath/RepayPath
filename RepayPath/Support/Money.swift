import Foundation

/// 金额与数字格式化（全 App 统一）
enum Money {
    static let locale = Locale(identifier: "en_GB")

    /// £45,000
    static func whole(_ value: Double) -> String {
        formatter(fractionDigits: 0).string(from: NSNumber(value: value)) ?? "£0"
    }

    /// £45.81
    static func cents(_ value: Double) -> String {
        formatter(fractionDigits: 2).string(from: NSNumber(value: value)) ?? "£0.00"
    }

    /// 45,000（用于输入框回显）
    static func plain(_ value: Double) -> String {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "0"
    }

    private static func formatter(fractionDigits: Int) -> NumberFormatter {
        let f = NumberFormatter()
        f.locale = locale
        f.numberStyle = .currency
        f.currencyCode = "GBP"
        f.minimumFractionDigits = fractionDigits
        f.maximumFractionDigits = fractionDigits
        return f
    }

    /// 把 "45,000" / "£45,000" / "45000.5" 解析成 Double；失败返回 nil
    static func parse(_ text: String) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: "£", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }
        return Double(cleaned)
    }

    /// 百分比：6.5%
    static func percent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }
}
