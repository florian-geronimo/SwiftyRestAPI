//
//  JSONType.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

enum JSONType: String, Codable {

    case string
    case int
    case double
    case boolean
    case array
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
        case .array, .dictionary, .null, .unknown:
            return nil
        }
    }

}
