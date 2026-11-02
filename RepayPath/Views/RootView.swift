import SwiftUI

struct RootView: View {
    @EnvironmentObject private var state: AppState
    @State private var selection: Int = 0

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
        .onAppear { applyCaptureTabIfNeeded() }
    }

    /// 仅用于截图/录屏流水线：Debug 构建时可通过环境变量直接指定初始 Tab。
    /// Release 构建里这个函数是空实现，二进制中不包含任何相关分支。
    #if DEBUG
    private func applyCaptureTabIfNeeded() {
        if let raw = ProcessInfo.processInfo.environment["RP_TAB"], let index = Int(raw) {
            selection = min(max(index, 0), 3)
        }
    }
    #else
    private func applyCaptureTabIfNeeded() {}
    #endif
}

#Preview {
    RootView().environmentObject(AppState())
}
