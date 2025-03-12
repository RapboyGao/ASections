import AFunction
import AValue
import SwiftUI

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct ASectionsView: View {
    @Binding var sections: [ASection]
    var functions: [Int: @Sendable ([AValue]) throws -> AValue]

    public var body: some View {
        ForEach($sections) { bindSection in
            Section(bindSection.name.wrappedValue) {
                ForEach(bindSection.rows) { bindRow in
                    ARowHStack(row: bindRow) { id, value in
                        try sections.convert(rowId: id, newValue: value, functions)
                    } recalculate: {
                        try sections.evaluateSelf(functions)
                    }
                }
            }
        }
        .task {
            try? sections.evaluateSelf()
        }
    }

    public init(_ bindSections: Binding<[ASection]>) {
        self._sections = bindSections
        self.functions = AFunction.functionInstances
    }

    public init(_ bindSections: Binding<[ASection]>, functions: [Int: @Sendable ([AValue]) throws -> AValue]) {
        self._sections = bindSections
        self.functions = functions
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
private struct Example: View {
    @State private var sections = [ASection].createExample()

    var body: some View {
        List {
            ASectionsView($sections)
        }
    }
}

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *) #Preview {
    Example()
}
