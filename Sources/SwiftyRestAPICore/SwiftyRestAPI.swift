import Foundation
import Files
import Swiftline

public final class SwiftyRestAPI {

    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
       try runCLIApp()
    }

    // MARK: - CLI App

  private

    func runCLIApp() throws {
        print("Welcome to SwiftyRestAPI generator!".foreground.Yellow.style.Bold)
        try chooseGenerator()
    }

    func chooseGenerator() throws {

      //Generator options
      let modelGenerator = "Model Generator".foreground.Red.style.Underline
      let apiGenerator = "API Generator".foreground.Red.style.Underline

      //Asks for a generator
      let featureChoice = choose("What feature do you want to use?\n".foreground.Yellow , choices: modelGenerator, apiGenerator)

      if featureChoice == modelGenerator {
          try chooseModelGenerator()
      } else if featureChoice == apiGenerator {
          try chooseApiGenerator()
      }
    }

    func chooseApiGenerator() throws {
        print("API Generator".foreground.Yellow.style.Bold)

        //Api generator options
        let requestrApiGenerator = "Requestr API Generator".foreground.Red.style.Underline
        let alamofireApiGenerator = "Alamofire API Generator".foreground.Red.style.Underline

        //Asks for a Api generator
        let generatorChoice = choose("Ok! Which API generator do you want to use?\n".foreground.Yellow, choices: requestrApiGenerator, alamofireApiGenerator)

        //Asks for the input type
        let fileType = chooseInputType()

        //Asks for the input file name
        let fileName = ask("What is the input API doc file name?".foreground.Yellow)

        //Converts the input file to a API instance
        let api: API
        switch fileType {
        case .postman:
          let data = try File(path: fileName).read()
          let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
          api = PostmanConvertr.shared.convert(json: json!)
        case .swifty:
          api = try fileNameToAPI(inputFileName: fileName )
        }

        //Creates files with the corresponding generator
        switch generatorChoice {
        case requestrApiGenerator:
          try createEndpointsFile(api: api)
          try createServiceFiles(api: api)
        case alamofireApiGenerator:
          try createEndpointsFile(api: api)
          try createAlamofireServiceFiles(api: api)
        default: return
        }

        print("Finished!".foreground.Red)
    }

    func chooseModelGenerator() throws {
        print("Model Generator".foreground.Yellow.style.Bold)

        //Model generator options
        let requestrModelGenerator = "Requestr Model Generator".foreground.Red.style.Underline
        let codableModelGenerator = "Codable Model Generator".foreground.Red.style.Underline

        //Asks for a model generator
        let generatorChoice = choose("Ok! Which model generator do you want to use?\n".foreground.Yellow, choices: requestrModelGenerator, codableModelGenerator)

        //Asks for the input file name and the model name
        let inputFileName = ask("What is the input JSON file name?".foreground.Yellow)
        let modelName = ask("What is this model's name?".foreground.Yellow)

        switch generatorChoice {
        case requestrModelGenerator:
          try createRequestrModelFile(inputFileName: inputFileName, modelName: modelName)
        case codableModelGenerator:
          try createCodableModelFile(inputFileName: inputFileName, modelName: modelName)
        default: return
        }

        print("Done!".foreground.Green)
    }

    func chooseInputType() -> InputTypes {
      let postmanChoice = "Postman API json file".foreground.Red.style.Underline
      let swiftyRestAPIChoice = "Swifty API json file".foreground.Red.style.Underline
      let inputChoice = choose("Ok! What is the input API doc file type?\n".foreground.Yellow, choices: postmanChoice, swiftyRestAPIChoice)

      switch inputChoice {
      case postmanChoice:
        return .postman
      case swiftyRestAPIChoice:
        return .swifty
      default:
        return .swifty
      }

    }

    func fileNameToAPI(inputFileName: String) throws -> API {
      let data = try File(path: inputFileName).read()
      let decoder = JSONDecoder()
      let api = try decoder.decode(API.self, from: data)
      return api
    }

    // MARK: - Helper's

    func createRequestrModelFile(inputFileName: String, modelName: String) throws {
        let outputFileName = "\(modelName).swift"
        let inputData = try File(path: inputFileName).read()

        let modelGenerator = try RequestrModelGenerator(modelName: modelName, jsonData: inputData)
        let modelText = modelGenerator.makeModelFile()
        let modelFile = try FileSystem().createFile(at: outputFileName)
        try modelFile.write(string: modelText)

        print("Created file \(outputFileName)".foreground.Red)
    }

     func createCodableModelFile(inputFileName: String, modelName: String) throws {
        let outputFileName = "\(modelName).swift"
        let inputData = try File(path: inputFileName).read()

        let modelGenerator = try CodableModelGenerator(modelName: modelName, jsonData: inputData)
        let modelText = modelGenerator.makeModelFile()
        let modelFile = try FileSystem().createFile(at: outputFileName)
        try modelFile.write(string: modelText)

        print("Created file \(outputFileName)".foreground.Green)
    }

     func createEndpointsFile(api: API) throws {
        let outputFileName = "Endpoints.swift"
        let apiGenerator = RequestrAPIGenerator(api: api)
        let endpointsText = apiGenerator.makeEndpointsFile()
        let endpointsFile = try FileSystem().createFile(at: outputFileName)
        try endpointsFile.write(string: endpointsText)

        print("Created file \(outputFileName)".foreground.Green)
    }

     func createServiceFiles(api: API) throws {
        let apiGenerator = AlamofireAPIGenerator(api: api)
        let serviceTexts = apiGenerator.makeServiceFiles()

        var outputFileNames: [String] = []
        for (idx, serviceText) in serviceTexts.enumerated() {
            let outputFileName = "Service\(idx).swift"
            let serviceFile = try FileSystem().createFile(at: outputFileName)
            try serviceFile.write(string: serviceText)
            outputFileNames += [outputFileName]
        }

        print("Created files \(outputFileNames.joined(separator: ", "))".foreground.Green)
    }

     func createAlamofireServiceFiles(api: API) throws {
        let apiGenerator = AlamofireAPIGenerator(api: api)
        let serviceTexts = apiGenerator.makeServiceFiles()

        var outputFileNames: [String] = []
        for (idx, serviceText) in serviceTexts.enumerated() {
            let outputFileName = "Service\(idx).swift"
            let serviceFile = try FileSystem().createFile(at: outputFileName)
            try serviceFile.write(string: serviceText)
            outputFileNames += [outputFileName]
        }

        print("Created files \(outputFileNames.joined(separator: ", "))".foreground.Green)
    }

}


public extension SwiftyRestAPI {

    enum Error: Swift.Error {
        case missingFileName
        case failedToCreateFile
        case missingFeatureConvert
    }

}
