import Foundation

public struct ARowIndex: Codable, Sendable, Hashable, Comparable {
    public var section: Int
    public var row: Int
    public static func < (leftSide: ARowIndex, rightSide: ARowIndex) -> Bool {
        if leftSide.section < rightSide.section {
            return true
        } else if leftSide.section == rightSide.section {
            return leftSide.row < rightSide.row
        } else {
            return false
        }
    }
}

extension [ASection] {
    public mutating func safe<T>(set index: ARowIndex, _ keyPath: WritableKeyPath<ARow, T>, to value: T) {
        guard indices.contains(index.section),
            self[index.section].rows.indices.contains(index.row)
        else { return }
        self[index.section].rows[index.row][keyPath: keyPath] = value
    }

    public func safeGet<T>(index: ARowIndex, _ keyPath: KeyPath<ARow, T>) -> T? {
        guard indices.contains(index.section),
            self[index.section].rows.indices.contains(index.row)
        else { return nil }
        return self[index.section].rows[index.row][keyPath: keyPath]
    }
}
