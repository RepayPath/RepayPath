import SwiftUI

struct ResultView: View {
    @EnvironmentObject private var state: AppState

    private var result: SimulationResult { state.result }
    private var points: [YearPoint] { state.points() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroCard
                    conclusionCard
                    BalanceChartView(points: points)
                    statsGrid
                    Text(L10n.infoVerified)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 110)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L10n.tabResult)
        }
    }

    private var heroCard: some View {
        VStack(spacing: 6) {
            Text(L10n.resultMonthly)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(Money.cents(result.monthlyRepaymentNow))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(AppTheme.accent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(RoundedRectangle(cornerRadius: 18).fill(AppTheme.cardBackground))
    }

    private var conclusionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: result.isPaidOff ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(result.isPaidOff ? .green : .orange)
                Text(result.isPaidOff ? L10n.resultCardPaidTitle : L10n.resultCardWriteOffTitle)
                    .font(.headline)
            }

            if result.isPaidOff, let y = result.payoffYear, let m = result.payoffMonth, let months = result.monthsToPayOff {
                Text(YearMonth.label(year: y, month: m))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(YearMonth.duration(months: months) + " · " + L10n.resultTotalRepaid + " " + Money.whole(result.totalRepaid))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text(YearMonth.label(year: result.writeOffYear, month: 4))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(String(format: L10n.resultNeverDetail,
                            Money.whole(result.balanceAtWriteOff)))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 18).fill(AppTheme.cardBackground))
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statTile(L10n.resultTotalInterest, Money.whole(result.totalInterest))
            statTile(L10n.resultWriteOff, YearMonth.year(result.writeOffYear))
            statTile(L10n.resultTotalRepaid, Money.whole(result.totalRepaid))
            statTile(L10n.resultBalanceLeft,
                     result.isPaidOff ? Money.whole(0) : Money.whole(result.balanceAtWriteOff))
        }
    }

    private func statTile(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AppTheme.cardBackground))
    }
}

#Preview {
    ResultView().environmentObject(AppState())
}
