import SwiftUI

struct PlanInputView: View {
    @EnvironmentObject private var state: AppState

    private var monthlyIncome: Double { state.input.annualSalary / 12 }
    private var monthlyDue: Double {
        Simulator.monthlyRepayment(plan: state.input.plan, monthlyIncome: monthlyIncome)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(L10n.labelPlan, selection: $state.input.plan) {
                        ForEach(LoanPlan.allCases) { plan in
                            Text(plan.title).tag(plan)
                        }
                    }
                    Text(state.input.plan.summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text(L10n.sectionLoan)
                }

                Section {
                    moneyRow(title: L10n.labelBalance, value: $state.input.balance)
                    Text(L10n.hintBalance)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    moneyRow(title: L10n.labelSalary, value: $state.input.annualSalary)
                    Text(L10n.hintSalary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Stepper(value: $state.input.firstRepayYear, in: 2000...2040) {
                        HStack {
                            Text(L10n.labelFirstYear)
                            Spacer()
                            Text(YearMonth.year(state.input.firstRepayYear))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                    }
                    Text(L10n.hintFirstYear)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(L10n.labelGrowth)
                            Spacer()
                            Text(Money.percent(state.input.salaryGrowth))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $state.input.salaryGrowth, in: 0...0.10, step: 0.005)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(L10n.labelRate)
                            Spacer()
                            Text(Money.percent(state.input.interestRate))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $state.input.interestRate, in: 0...0.12, step: 0.001)
                        Text(L10n.hintRate)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    HStack {
                        Text(L10n.resultMonthly)
                        Spacer()
                        Text(Money.cents(monthlyDue))
                            .font(.headline)
                            .monospacedDigit()
                            .foregroundStyle(AppTheme.accent)
                    }
                }

                Section {
                    Button(L10n.resetToTypical) {
                        state.input = .initial()
                    }
                }
            }
            .navigationTitle(L10n.tabPlan)
        }
    }

    /// 金额输入行：左侧固定标签，右侧 £ + 数字，输入时标签不会消失
    private func moneyRow(title: String, value: Binding<Double>) -> some View {
        HStack(spacing: 8) {
            Text(title)
            Spacer(minLength: 12)
            Text("£")
                .foregroundStyle(.secondary)
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
                .frame(minWidth: 90, maxWidth: 150)
        }
    }
}

#Preview {
    PlanInputView().environmentObject(AppState())
}
