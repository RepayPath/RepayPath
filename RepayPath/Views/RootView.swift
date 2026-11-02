import SwiftUI

struct RootView: View {
    @EnvironmentObject private var state: AppState
    @State private var selection: Int = 0

    /// 仅 Debug 构建使用：录屏流水线通过环境变量控制展示哪个页面
    #if DEBUG
    @State private var autoTimer: Timer?
    #endif

    var body: some View {
        TabView(selection: $selection) {
            PlanInputView()
                .tabItem { Label(L10n.tabPlan, systemImage: "slider.horizontal.3") }
                .tag(0)

            ResultView()
                .tabItem { Label(L10n.tabResult, systemImage: "doc.text.magnifyingglass") }
                .tag(1)

            CompareView()
                .tabItem { Label(L10n.tabCompare, systemImage: "arrow.left.arrow.right") }
                .tag(2)

            InfoView()
                .tabItem { Label(L10n.tabInfo, systemImage: "info.circle") }
                .tag(3)
        }
        .onAppear { applyCaptureModeIfNeeded() }
        .onDisappear {
            #if DEBUG
            autoTimer?.invalidate()
            autoTimer = nil
            #endif
        }
    }

    /// Debug 专用：RP_TAB=auto 时每 4 秒自动切一页（供连续录屏）；
    /// RP_TAB=0..3 时固定停在某一页（供截图）。
    /// Release 构建里这个函数是空实现，二进制中不含任何相关分支。
    #if DEBUG
    private func applyCaptureModeIfNeeded() {
        guard let raw = ProcessInfo.processInfo.environment["RP_TAB"] else { return }
        if raw == "auto" {
            selection = 0
            autoTimer?.invalidate()
            autoTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.35)) {
                    selection = (selection + 1) % 4
                }
            }
        } else if let index = Int(raw) {
            selection = min(max(index, 0), 3)
        }
    }
    #else
    private func applyCaptureModeIfNeeded() {}
    #endif
}

#Preview {
    RootView().environmentObject(AppState())
}
