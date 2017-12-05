import Foundation

final class CodableModelGenerator: ModelGenerator {

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

  func makeModelFile() -> FileText {
      return """
      \(makeHeader(fileName: "\(modelName).swift"))

      import Foundation

      struct \(modelName): Codable {

      \(makeVariables(parameters: parameters))

      }
      """
  }

}

extension CodableModelGenerator {

    // MARK: Helper's
    
    private func makeParameters() -> [Parameter] {
        var parameters: [Parameter] = []
        for (key,value) in json {
          let type = findType(value: value)
          let parameter = Parameter(name: key, type: type, value: value)
          parameters.append(parameter)
        }
        return parameters
    }

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
}

extension CodableModelGenerator {

    enum Error: Swift.Error {
        case castError
    }

}
