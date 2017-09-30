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

        var parameters = makeParameters(json: json)

        var text = """
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
            string += """
            let \(parameter.name): \(parameter.type)
            """
        }
        return string
    }

    private func makeInit(parameters: [Parameter]) -> String {
        var string = "init(json: JSONDictionary) throws {\n"
        for parameter in parameters {
            string += """
              \(parameter.name) = try json.decode(\"\(parameter.name)\")
            """
        }
        string += "\n}"
        return string
    }

    private func makeParameters(json: JSONDictionary) -> [Parameter] {
      var parameters = [Parameter]()

       for key in json {
         var jsonType: JSONType!

         switch key["JSONType"] {
         case let someInt as Int:
           jsonType = .int
         case let someDouble as Double:
           jsonType = .double
         case let someString as String:
           jsonType = .string
         case let someArray as Array:
           jsonType = .array
         case let someDictionary as Dictionary:
           jsonType = .dictionary
         default:
           jsonType = .null
         }

         guard let name = key["name"] as! String else {
             return Error.castError
         }

         guard let value = key["value"] as! Any else {
             return Error.castError
         }

         let parameter = Parameter(name: name,
                                   JSONType: jsonType,
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
