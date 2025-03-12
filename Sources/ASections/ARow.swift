import AFormula
import AFunction
import AValue

public struct ARow: Codable, Sendable, Hashable, Identifiable {
    public var id: Int
    public var name: String
    public var behavior: Behavior
    public var computation: AFormula?
    public var conversions: [Conversion]
    public var style: Style
    /// - 小数点后保留几位数
    /// - 默认为5
    public var digits: Int
    public var value: AValue?
    public var computationUnit: AUnit?
    public var currentUnit: AUnit?

    public func row() -> AFormula {
        .variable(id: id)
    }

    public init(
        id: Int = Int.random(in: .min ... .max),
        name: String,
        behavior: Behavior,
        formula: AFormula? = nil,
        conversions: [Conversion],
        style: Style,
        digits: Int = 5,
        value: AValue? = nil,
        computationUnit: AUnit? = nil,
        currentUnit: AUnit? = nil
    ) {
        self.id = id
        self.name = name
        self.behavior = behavior
        self.computation = formula
        self.conversions = conversions
        self.style = style
        self.digits = digits
        self.value = value
        self.computationUnit = computationUnit
        self.currentUnit = currentUnit
    }

    public init(
        name: String,
        id: Int,
        behavior: Behavior,
        formula: AFormula?,
        conversions: [Conversion],
        style: Style,
        digits: Int,
        value: AValue?,
        computationUnit: AUnit?,
        currentUnit: AUnit?
    ) {
        self.id = id
        self.name = name
        self.behavior = behavior
        self.computation = formula
        self.conversions = conversions
        self.style = style
        self.digits = digits
        self.value = value
        self.computationUnit = computationUnit
        self.currentUnit = currentUnit
    }
}

public extension ARow {
    enum Behavior: Codable, Hashable, Sendable {
        case variable(AValueType)
        case computed
    }

    enum Style: Codable, Hashable, Sendable, CaseIterable {
        case normal
        case emphasized
        case hidden
    }

    /// Conversion是一个Setter，可以利用formula反过来计算
    struct Conversion: Codable, Hashable, Sendable, Identifiable {
        /// 换算对象
        public var id: Int
        public var formula: AFormula
    }
}

// MARK: - 简单版本构建ARow工具

public extension ARow {
    static func variable(id: Int = .random(in: .min ... .max), name: String, type valueType: AValueType, unit: AUnit?) -> ARow {
        ARow(id: id, name: name, behavior: .variable(valueType), conversions: [], style: .normal, value: valueType.baseValue(), computationUnit: unit)
    }

    static func computed(id: Int = .random(in: .min ... .max), name: String, unit: AUnit?, style: Style = .normal, createFormula: @escaping () -> AFormula) -> ARow {
        ARow(name: name, id: id, behavior: .computed, formula: createFormula(), conversions: [], style: style, digits: 5, value: nil, computationUnit: unit, currentUnit: nil)
    }

    static func conversion(id: Int = .random(in: .min ... .max), name: String, unit: AUnit?, style: Style = .normal, createFormula: @escaping () -> AFormula, createConversions: @escaping () -> [Conversion]) -> ARow {
        ARow(name: name, id: id, behavior: .computed, formula: createFormula(), conversions: createConversions(), style: style, digits: 5, value: nil, computationUnit: unit, currentUnit: nil)
    }
}
