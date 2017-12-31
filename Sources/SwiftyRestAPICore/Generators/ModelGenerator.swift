//
//  ModelGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

public typealias JSONDictionary = [String : Any]

public protocol ModelGenerator {

    var modelName: String { get }

    init(modelName: String, json: JSONDictionary)

    init(modelName: String, jsonData: Data) throws

    func makeModelFile() -> FileText

}
