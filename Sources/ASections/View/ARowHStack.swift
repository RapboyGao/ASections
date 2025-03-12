import AValue

@available(iOS 16, macOS 13, tvOS 16, watchOS 9, *)
public struct ARowHStack: View {
    @Binding var row: ARow
    var convert: (Int, AValue?) throws -> Void
    var recalculate: () throws -> Void

    private var rowValue: AValue? {
        row.value
    }

    private func setRowValue(_ value: AValue?) {
        switch row.behavior {
        case .variable:
            row.value = value
            try? recalculate()
        case .computed:
            guard row.conversions.isEmpty
            else {
                try? convert(row.id, value)
                return
            }
        }
    }

    private var bindValue: Binding<AValue?> {
        Binding {
            rowValue
        } set: {
            setRowValue($0)
        }
    }

    private var allowInput: Bool {
        switch row.behavior {
        case .variable:
            return true
        case .computed:
            return !row.conversions.isEmpty
        }
    }

    private var valueType: AValueType? {
        switch row.behavior {
        case .variable(let aValueType):
            return aValueType
        case .computed:
            return rowValue?.type
        }
    }

    public var body: some View {
        HStack {
            Text(row.name)
            AValueInputContent(bindValue, $row.currentUnit, allowInput: allowInput, name: row.name, originalUnit: row.computationUnit, auxPoints: [], precision: .fractionLength(0...row.digits), designatedType: valueType)
        }
    }


    public init(row: Binding<ARow>, convert: @escaping (Int, AValue?) throws -> Void, recalculate: @escaping () throws -> Void) {
        self._row = row
        self.convert = convert
        self.recalculate = recalculate
    }
}
