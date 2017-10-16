//
//  RequestrModelGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

final class RequestrModelGenerator: ModelGenerator {

    struct Parameter {
        let name: String
        let type: Type
        let value: Any
    }

    let modelName: String

    let json: JSONDictionary

    lazy var parameters: [Parameter] = makeParameters()

    init(modelName: String, json: JSONDictionary) {
        self.modelName = modelName
        self.json = json
    }

    init(modelName: String, jsonData: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSONDictionary else {
            throw Error.castError
        }

        self.modelName = modelName
        self.json = json
    }

    // MARK: - Helper's

    private func makeParameters() -> [Parameter] {
        var parameters: [Parameter] = []
        for (key,value) in json {
          let type = findType(value: value)
          let parameter = Parameter(name: key, type: type, value: value)
          parameters.append(parameter)
        }
        return parameters
    }

}

// MARK: - Model Generation

extension RequestrModelGenerator {

    func makeModelFile() -> FileText {
        return """
        \(makeHeader(fileName: "\(modelName).swift"))

        import Foundation
        import Requestr

        struct \(modelName): JSONDeserializable {

        \(makeVariables(parameters: parameters))
        \(makeInit(parameters: parameters))

        }
        """
    }

    // MARK: Helper's

    private func makeVariables(parameters: [Parameter]) -> String {
        var string = ""
        for parameter in parameters {
            guard let type = parameter.type.text else {
                continue
            }
            string += """
                let \(parameter.name): \(type)


            """
        }
        return String(string.dropLast())
    }

    private func makeInit(parameters: [Parameter]) -> String {
        var string = """
            init(json: JSONDictionary) throws {

        """
        for parameter in parameters {
            string += """
                    \(parameter.name) = try json.decode(\"\(parameter.name)\")

            """
        }
        string += """
            }
        """
        return string
    }

}

extension RequestrModelGenerator {

    enum Error: Swift.Error {
        case castError
    }

}
