import SwiftUI

struct InfoView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(L10n.infoWhatThisBody)
                        .font(.callout)
                } header: {
                    Text(L10n.infoWhatThis)
                }

                Section {
                    ForEach(LoanPlan.allCases) { plan in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(plan.title).font(.subheadline.weight(.semibold))
                            Text("\(Money.whole(plan.yearlyThreshold)) / yr  ·  \(Money.whole(plan.monthlyThreshold)) / mo")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                            Text("\(Money.percent(plan.repaymentRate)) · \(plan.writeOffYears) yr")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text(L10n.infoThresholds)
                } footer: {
                    Text(L10n.infoRates)
                }

                Section {
                    Text(L10n.infoWriteOff)
                        .font(.callout)
                } header: {
                    Text(L10n.infoWriteOffTitle)
                }

                Section {
                    Text(L10n.infoDisclaimer)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(L10n.infoDisclaimerTitle)
                }

                Section {
                    Text(L10n.infoPrivacy)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(L10n.infoPrivacyTitle)
                }

                Section {
                    Link("GOV.UK — Repaying your student loan",
                         destination: URL(string: "https://www.gov.uk/repaying-your-student-loan")!)
                    Text(L10n.infoVerified)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(L10n.infoSources)
                }
            }
            .navigationTitle(L10n.tabInfo)
        }
    }
}

#Preview {
    InfoView()
}
