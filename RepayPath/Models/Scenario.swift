import Foundation

/// 用户保存的一套方案（如「留在英国」「回国工作」）
struct Scenario: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var input: LoanInput
    var createdAt: Date = Date()

    var result: SimulationResult { Simulator.simulate(input) }
}
