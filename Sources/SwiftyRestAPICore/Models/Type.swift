import Foundation

public indirect enum Type {

    case string
    case int
    case double
    case boolean
    case array(Type)
    case dictionary
    case null
    case unknown

    var text: String? {
        switch self {
        case .string:
            return "String"
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .boolean:
            return "Bool"
        case let .array(type):
            return "[\(type.text ?? "")]"
        case .dictionary, .null, .unknown:
            return nil
        }
    }

}
