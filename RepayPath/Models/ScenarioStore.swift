import Foundation
import Combine

/// 方案存储：只写本机 UserDefaults，不上传、不联网。
final class ScenarioStore: ObservableObject {
    @Published private(set) var scenarios: [Scenario] = []

    private let storageKey = "repaypath.scenarios.v1"

    init() { load() }

    func add(_ scenario: Scenario) {
        scenarios.append(scenario)
        persist()
    }

    func remove(at offsets: IndexSet) {
        scenarios.remove(atOffsets: offsets)
        persist()
    }

    func remove(id: UUID) {
        scenarios.removeAll { $0.id == id }
        persist()
    }

    func rename(id: UUID, to name: String) {
        guard let idx = scenarios.firstIndex(where: { $0.id == id }) else { return }
        scenarios[idx].name = name
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(scenarios) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([Scenario].self, from: data) else { return }
        scenarios = saved
    }
}
