import AFormula
import AFunction
import AValue

extension [ASection] {
    @Sendable
    mutating func evaluateSelf(_ functions: [Int: @Sendable ([AValue]) throws -> AValue] = AFunction.functionInstances) throws {
        // 构建初始的评估器，包含所有行的初始值
        var evaluator = AFormulaEvaluator(rowValues: [:], functions)

        // 遍历所有section中的所有行，计算computed行的值
        for sectionIndex in self.indices {
            for rowIndex in self[sectionIndex].rows.indices {
                let row = self[sectionIndex].rows[rowIndex]
                switch row.behavior {
                case .variable:
                    evaluator.rowValues[row.id] = row.value
                case .computed:
                    guard let formula = row.computation
                    else {
                        self[sectionIndex].rows[rowIndex].value = nil
                        continue
                    }
                    let value = try evaluator.evaluate(formula: formula)
                    self[sectionIndex].rows[rowIndex].value = value
                    evaluator.rowValues[row.id] = value
                }
            }
        }
    }

    // 查找指定ID的row索引, 在换算中使用
    @Sendable
    private func findRow(by id: Int) -> ARowIndex? {
        for (sectionIndex, section) in self.enumerated() {
            if let rowIndex = section.rows.firstIndex(where: { $0.id == id }) {
                return ARowIndex(section: sectionIndex, row: rowIndex)
            }
        }
        return nil
    }

    // 转换指定row的值
    @Sendable
    public mutating func convert(rowId: Int, newValue: AValue?, _ functions: [Int: @Sendable ([AValue]) throws -> AValue] = AFunction.functionInstances) throws {
        // 查找指定row的索引
        guard let rowIndex = findRow(by: rowId) else {
            throw ConversionError.rowNotFound(id: rowId)
        }

        // 获取row
        guard let row = safeGet(index: rowIndex, \.self)
        else {
            throw ConversionError.conversionOriginNotFound(row: rowIndex)
        }
        // 确保row的行为是computed
        guard case .computed = row.behavior else {
            throw ConversionError.invalidOperation
        }

        // 初次评估所有行，获取评估器
        var evaluator = AFormulaEvaluator(rowValues: [:], functions)
        // 缓存所有行的索引
        var rowIndexCache = [Int: ARowIndex]()
        sectionLoop: for (sectionIndex, section) in self.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                guard rowId != row.id
                else { break sectionLoop } // 节省运算时间, 评估到当前行就结束
                rowIndexCache[row.id] = ARowIndex(section: sectionIndex, row: rowIndex)
                switch row.behavior {
                case .variable:
                    evaluator.rowValues[row.id] = row.value
                case .computed:
                    guard let computation = row.computation else { continue }
                    let value = try? evaluator.evaluate(formula: computation)
                    evaluator.rowValues[row.id] = value
                }
            }
        }
        evaluator.rowValues[rowId] = newValue
        // 应用转换
        try self.applyConversions(rowIndex: rowIndex, newValue: newValue, evaluator: evaluator, rowIndexCache: rowIndexCache)
        // 重新计算
        try self.evaluateSelf()
    }

    // 递归应用转换
    @Sendable
    private mutating func applyConversions(rowIndex: ARowIndex, newValue: AValue?, evaluator: AFormulaEvaluator, rowIndexCache: [Int: ARowIndex]) throws {
        guard let conversions = self.safeGet(index: rowIndex, \.conversions)
        else {
            throw ConversionError.conversionOriginNotFound(row: rowIndex)
        }

        var evaluator = evaluator

        // 遍历row的所有转换公式
        for conversion in conversions {
            // 评估转换公式的值
            let evaluatedValue = try evaluator.evaluate(formula: conversion.formula)

            // 获取转换目标行的索引
            guard let targetRowIndex = rowIndexCache[conversion.id] else {
                throw ConversionError.rowNotFound(id: conversion.id)
            }

            // 检查转换顺序是否有效，防止再次applyConversions死循环
            guard targetRowIndex < rowIndex else {
                throw ConversionError.invalidConversionOrder
            }

            // 设置新公式
            evaluator.rowValues[conversion.id] = evaluatedValue

            // 如果转换的目标行也是computed类型，则递归应用转换
            guard let computedRowBehavior = self.safeGet(index: targetRowIndex, \.behavior)
            else {
                throw ConversionError.targetNotFound(row: targetRowIndex)
            }
            switch computedRowBehavior {
            case .variable:
                self.safe(set: targetRowIndex, \.value, to: evaluatedValue)
            case .computed:
                try self.applyConversions(rowIndex: targetRowIndex, newValue: evaluatedValue, evaluator: evaluator, rowIndexCache: rowIndexCache)
            }
            return
        }

        // 如果没有找到匹配的转换，则抛出转换失败错误
        throw ConversionError.conversionFailed
    }
}
