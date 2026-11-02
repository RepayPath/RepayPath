import SwiftUI
import Charts

/// 余额下降曲线 + 累计已还。数据全部来自本地模拟结果。
struct BalanceChartView: View {
    let points: [YearPoint]

    private var firstYear: Int { points.first?.year ?? 0 }
    private var lastYear: Int { points.last?.year ?? 1 }
    private var maxValue: Double {
        let m = points.map { max($0.balance, $0.cumulativeRepaid) }.max() ?? 0
        return max(m, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L10n.chartTitle)
                    .font(.headline)
                Spacer()
            }

            // 图例放在图上，避免被底部 Tab 栏遮挡
            HStack(spacing: 16) {
                legend(color: AppTheme.accent, text: L10n.chartLegendBalance, dashed: false)
                legend(color: .orange, text: L10n.chartLegendRepaid, dashed: true)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            if points.count < 2 {
                Text(L10n.chartEmpty)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 30)
            } else {
                Chart {
                    // 面积：仅余额
                    ForEach(points) { p in
                        AreaMark(
                            x: .value("Year", p.year),
                            y: .value("Balance", p.balance)
                        )
                        .foregroundStyle(AppTheme.accent.opacity(0.15))
                        .interpolationMethod(.monotone)
                    }

                    // 两条线用 series 维度区分，颜色由 chartForegroundStyleScale 指定
                    ForEach(points) { p in
                        LineMark(
                            x: .value("Year", p.year),
                            y: .value("Balance", p.balance)
                        )
                        .foregroundStyle(by: .value("Series", "Balance"))
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.monotone)

                        LineMark(
                            x: .value("Year", p.year),
                            y: .value("Repaid", p.cumulativeRepaid)
                        )
                        .foregroundStyle(by: .value("Series", "Repaid"))
                        .lineStyle(StrokeStyle(lineWidth: 1.8, dash: [5, 4]))
                        .interpolationMethod(.monotone)
                    }
                }
                .chartForegroundStyleScale([
                    "Balance": AppTheme.accent,
                    "Repaid": Color.orange
                ])
                .chartLegend(.hidden)
                .chartXScale(domain: firstYear...max(lastYear, firstYear + 1))
                .chartYScale(domain: 0...(maxValue * 1.08))
                .chartXAxis {
                    AxisMarks(values: yearTicks) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        AxisValueLabel {
                            if let y = value.as(Int.self) {
                                Text(String(y)).font(.caption2)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(shortMoney(v)).font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.cardBackground))
    }

    private var yearTicks: [Int] {
        var ticks: [Int] = []
        var y = firstYear
        while y <= lastYear {
            ticks.append(y)
            y += 5
        }
        if ticks.last != lastYear { ticks.append(lastYear) }
        return ticks
    }

    private func legend(color: Color, text: String, dashed: Bool) -> some View {
        HStack(spacing: 5) {
            if dashed {
                Rectangle()
                    .fill(color)
                    .frame(width: 14, height: 1.5)
            } else {
                Circle().fill(color).frame(width: 7, height: 7)
            }
            Text(text)
        }
    }

    private func shortMoney(_ v: Double) -> String {
        if v >= 1000 {
            return "£" + String(format: "%.0fk", v / 1000)
        }
        return "£" + String(format: "%.0f", v)
    }
}
