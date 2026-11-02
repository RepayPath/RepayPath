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
            Text(L10n.chartTitle)
                .font(.headline)

            if points.count < 2 {
                Text(L10n.chartEmpty)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 30)
            } else {
                Chart {
                    // 三个独立 ForEach = 三个独立序列，避免 Charts 把不同序列连成一条锯齿线
                    ForEach(points) { p in
                        AreaMark(
                            x: .value("Year", p.year),
                            y: .value("Balance", p.balance)
                        )
                        .foregroundStyle(AppTheme.accent.opacity(0.15))
                        .interpolationMethod(.monotone)
                    }

                    ForEach(points) { p in
                        LineMark(
                            x: .value("Year", p.year),
                            y: .value("Balance", p.balance)
                        )
                        .foregroundStyle(AppTheme.accent)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                        .interpolationMethod(.monotone)
                    }

                    ForEach(points) { p in
                        LineMark(
                            x: .value("Year", p.year),
                            y: .value("Repaid", p.cumulativeRepaid)
                        )
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .interpolationMethod(.monotone)
                    }
                }
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
                .frame(height: 210)
                .padding(.vertical, 4)

                HStack(spacing: 16) {
                    legend(color: AppTheme.accent, text: L10n.chartLegendBalance)
                    legend(color: .orange, text: L10n.chartLegendRepaid)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.cardBackground))
    }

    /// 每 5 年一个刻度，起止年份必显示
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

    private func legend(color: Color, text: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
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
