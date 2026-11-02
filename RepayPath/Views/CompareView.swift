import SwiftUI

struct CompareView: View {
    @EnvironmentObject private var state: AppState
    @State private var newName: String = ""

    private let presets: [Double] = [25, 50, 100, 200]
    private var base: SimulationResult { state.result }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(L10n.compareExtra)
                            Spacer()
                            Text(Money.whole(state.extraMonthly) + " / mo")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $state.extraMonthly, in: 0...300, step: 10)
                    }
                    row(title: label(for: state.extraMonthly),
                        result: state.result(extraMonthly: state.extraMonthly))
                } header: {
                    Text(L10n.compareTitle)
                } footer: {
                    Text(L10n.compareSubtitle)
                }

                Section(header: Text(L10n.comparePresets)) {
                    ForEach(presets, id: \.self) { extra in
                        row(title: label(for: extra), result: state.result(extraMonthly: extra))
                    }
                }

                Section {
                    HStack {
                        TextField(L10n.compareSavePrompt, text: $newName)
                        Button(L10n.compareSave) {
                            saveCurrent()
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section {
                    if state.store.scenarios.isEmpty {
                        Text(L10n.compareNoSaved)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(state.store.scenarios) { sc in
                            savedRow(sc)
                        }
                        .onDelete { idx in
                            state.store.remove(at: idx)
                        }
                    }
                } header: {
                    Text(L10n.compareSaved)
                }
            }
            .navigationTitle(L10n.tabCompare)
        }
    }

    private func row(title: String, result: SimulationResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline.weight(.medium))
            if result.isPaidOff, let y = result.payoffYear, let m = result.payoffMonth {
                HStack {
                    Text(YearMonth.label(year: y, month: m))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let saved = savedMonths(result) {
                        Text(saved > 0 ? String(format: L10n.compareSavedMonths, saved) : L10n.compareNoChange)
                            .font(.caption2)
                            .foregroundStyle(saved > 0 ? .green : .secondary)
                    }
                }
            } else {
                Text(L10n.resultNever)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func savedMonths(_ r: SimulationResult) -> Int? {
        guard let baseMonths = base.monthsToPayOff, let thisMonths = r.monthsToPayOff else { return nil }
        return baseMonths - thisMonths
    }

    private func savedRow(_ sc: Scenario) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(sc.name).font(.subheadline.weight(.medium))
            let r = sc.result
            if r.isPaidOff, let y = r.payoffYear, let m = r.payoffMonth {
                Text(YearMonth.label(year: y, month: m) + " · " + Money.whole(r.totalInterest) + " " + L10n.resultTotalInterest)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(L10n.resultNever).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func label(for extra: Double) -> String {
        extra == 0 ? L10n.compareBase : String(format: L10n.compareExtraAmount, Money.whole(extra))
    }

    private func saveCurrent() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        state.store.add(Scenario(name: trimmed, input: state.input))
        newName = ""
    }
}

#Preview {
    CompareView().environmentObject(AppState())
}
