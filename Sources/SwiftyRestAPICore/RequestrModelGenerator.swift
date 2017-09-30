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
        let type: JSONType
        let value: Any
    }

    let modelName: String
    let json: JSONDictionary

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

    // MARK: - File text generation

    func makeModelFile() -> FileText {

        let parameters = makeParameters(json: json)

        let text = """
        import Requestr
        struct \(modelName) : JSONDeserializable {
            \(makeVariables(parameters: parameters))
            \(makeInit(parameters: parameters))
        }
        """

        return text
    }

    // MARK: Helper's

    private func makeVariables(parameters: [Parameter]) -> String {
        var string = ""
        for parameter in parameters {
            string += "let \(parameter.name): \(parameter.type)\n"
        }
        return string
    }

    private func makeInit(parameters: [Parameter]) -> String {
        var string = "init(json: JSONDictionary) throws {\n"
        for parameter in parameters {
            string += "\(parameter.name) = try json.decode(\"\(parameter.name)\")\n"
        }
        string += "\n}"
        return string
    }

    private func makeParameters(json: JSONDictionary) -> [Parameter] {
      var parameters = [Parameter]()

       for (key,value) in json {
         var jsonType: JSONType!

         switch value {
         case is Int:
           jsonType = .int
         case is Double:
           jsonType = .double
         case is String:
           jsonType = .string
         case is [Any]:
           jsonType = .array
         case is [String:Any]:
           jsonType = .dictionary
         default:
           jsonType = .null
         }

         let parameter = Parameter(name: key,
                                   type: jsonType,
                                   value: value)

         parameters.append( parameter )
       }
       return parameters
    }
}

extension RequestrModelGenerator {

    enum Error: Swift.Error {
        case castError
    }
}
