import SwiftUI

struct RootView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        TabView {
            PlanInputView()
                .tabItem { Label(L10n.tabPlan, systemImage: "slider.horizontal.3") }

            ResultView()
                .tabItem { Label(L10n.tabResult, systemImage: "doc.text.magnifyingglass") }

            CompareView()
                .tabItem { Label(L10n.tabCompare, systemImage: "arrow.left.arrow.right") }

            InfoView()
                .tabItem { Label(L10n.tabInfo, systemImage: "info.circle") }
        }
    }
}

#Preview {
    RootView().environmentObject(AppState())
}
