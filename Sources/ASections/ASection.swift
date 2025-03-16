import AFormula
import AFunction
import AValue

public struct ASection: Codable, Sendable, Hashable, Identifiable {
    public var id = Int.random(in: .min ... .max)
    public var name: String
    public var rows: [ARow]
}

public extension [ASection] {
    @Sendable
    func newId() -> Int {
        let allIDs = self.reduce(Set<Int>()) { result, section in
            let rowIDs = section.rows.reduce(Set<Int>()) { partialResult, row in
                partialResult.union([row.id])
            }
            return result.union(rowIDs).union([section.id])
        }
        for _ in 0 ... 100 {
            let newValue = Int.random(in: .min ... .max)
            guard allIDs.contains(newValue)
            else { return newValue }
        }
        return Int.random(in: .min ... .max)
    }
}
