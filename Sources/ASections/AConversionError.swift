import AValue

public enum ConversionError: Error {
    case rowNotFound(id: Int) // 行未找到错误
    case conversionOriginNotFound(row: ARowIndex) // 行未找到错误
    case targetNotFound(row: ARowIndex) // 行未找到错误
    case typeMismatch(expected: AValueType, actual: AValueType) // 类型不匹配错误
    case invalidOperation // 无效操作错误
    case conversionFailed // 转换失败错误
    case invalidConversionOrder // 无效的转换顺序错误
}
