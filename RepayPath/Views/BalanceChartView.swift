import SwiftUI
import Charts

/// 余额下降曲线 + 累计已还。数据全部来自本地模拟结果。
struct BalanceChartView: View {
    let points: [YearPoint]

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
                    ForEach(points) { p in
                        AreaMark(
                            x: .value("Year", p.year),
                            y: .value("Balance", p.balance)
                        )
                        .foregroundStyle(AppTheme.accent.opacity(0.18))
                        .interpolationMethod(.monotone)

                        LineMark(
                            x: .value("Year", p.year),
                            y: .value("Balance", p.balance)
                        )
                        .foregroundStyle(AppTheme.accent)
                        .interpolationMethod(.monotone)

                        LineMark(
                            x: .value("Year", p.year),
                            y: .value("Repaid", p.cumulativeRepaid)
                        )
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .interpolationMethod(.monotone)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4))
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text(shortMoney(v))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .frame(height: 220)

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
