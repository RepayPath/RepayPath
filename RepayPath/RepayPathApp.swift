import SwiftUI

/// 全局状态：一套贷款参数 + 已保存方案。
/// 全部计算在本地完成，App 不发起任何网络请求。
final class AppState: ObservableObject {
    @Published var input: LoanInput = .initial()
    @Published var store = ScenarioStore()
    @Published var extraMonthly: Double = 50

    var result: SimulationResult { Simulator.simulate(input) }

    func result(extraMonthly extra: Double) -> SimulationResult {
        Simulator.simulate(input, extraMonthly: extra)
    }

    func points(extraMonthly extra: Double = 0) -> [YearPoint] {
        Simulator.yearlyPoints(input, extraMonthly: extra)
    }
}

@main
struct RepayPathApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(state)
                .tint(AppTheme.accent)
        }
    }
}

enum AppTheme {
    static let accent = Color(red: 0.11, green: 0.42, blue: 0.36)   // 深青绿，与旧项目完全不同
    static let cardBackground = Color(.secondarySystemBackground)
}
