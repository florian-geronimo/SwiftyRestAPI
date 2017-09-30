import Foundation
import Files
import Swiftline

public final class SwiftyRestAPI {

    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        print("Welcome to SwiftyRestAPI generator!".foreground.Cyan)

        let modelGenerator = "Model Generator".foreground.Blue
        let apiGenerator = "API Generator".foreground.Blue
        let featureChoice = choose("What feature do you want to use?\n", choices: modelGenerator, apiGenerator)

        if featureChoice == modelGenerator {
            try choseModelGenerator()
        } else if featureChoice == apiGenerator {
            try choseApiGenerator()
        }
    }

    private func choseModelGenerator() throws {
        print("Model Generator".foreground.Red)

        let requestrModelGenerator = "Requestr Model Generator".foreground.Blue
        let generatorChoice = choose("Ok! Which model generator do you want to use?\n".foreground.Cyan, choices: requestrModelGenerator)

        guard generatorChoice == requestrModelGenerator else {
            return
        }

        let inputFileName = ask("What is the input JSON file name?".foreground.Cyan)
        let modelName = ask("What is this model's name?".foreground.Cyan)
        try createModelFile(inputFileName: inputFileName, modelName: modelName)

        print("Done!".foreground.Red)
    }

    private func choseApiGenerator() throws {
        print("API Generator".foreground.Red)

        let requestrApiGenerator = "Requestr API Generator".foreground.Blue
        let generatorChoice = choose("Ok! Which API generator do you want to use?\n".foreground.Cyan, choices: requestrApiGenerator)

        guard generatorChoice == requestrApiGenerator else {
            return
        }

        let inputFileName = ask("What is the input API doc file name?".foreground.Cyan)
        try createEndpointsFile(inputFileName: inputFileName)
        try createServiceFiles(inputFileName: inputFileName)

        print("Done!".foreground.Red)
    }

    // MARK: - Helper's

    private func createModelFile(inputFileName: String, modelName: String) throws {
        let inputData = try File(path: inputFileName).read()

        let modelGenerator = try RequestrModelGenerator(modelName: modelName, jsonData: inputData)
        let modelText = modelGenerator.makeModelFile()
        let modelFile = try FileSystem().createFile(at: "\(modelName).swift")
        try modelFile.write(string: modelText)
    }

    private func createEndpointsFile(inputFileName: String) throws {
        let data = try File(path: inputFileName).read()

        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let endpointsText = apiGenerator.makeEndpointsFile()
        let endpointsFile = try FileSystem().createFile(at: "Endpoints.swift")
        try endpointsFile.write(string: endpointsText)
    }

    private func createServiceFiles(inputFileName: String) throws {
        let data = try File(path: inputFileName).read()

        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let serviceTexts = apiGenerator.makeServiceFiles()

        for (idx, serviceText) in serviceTexts.enumerated() {
            let serviceFile = try FileSystem().createFile(at: "Service\(idx).swift")
            try serviceFile.write(string: serviceText)
        }
    }

}

private extension SwiftyRestAPI {

    func _createExampleApiInput() throws {
        let getUser = API.Endpoint(name: "getUser", resourceName: "User", isResourceArray: false, method: .GET, relativePath: "/users/1", urlParameters: [])
        let getUsers = API.Endpoint(name: "getUsers", resourceName: "User", isResourceArray: true, method: .GET, relativePath: "/users", urlParameters: [])
        let postUser = API.Endpoint(name: "postUser", resourceName: "User", isResourceArray: false, method: .POST, relativePath: "/users/1", urlParameters: [])

        let category = API.Category(name: "Users", endpoints: [getUser, getUsers, postUser])
        let api = API(basePath: "http://www.icalialabs.com/", categories: [category])

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(api)
        let file = try FileSystem().createFile(at: "ApiInputExample.json")
        try file.write(data: data)
    }

    func _readExampleApiInput() throws {
        let filePath = ask("What file?")
        let data = try File(path: filePath).read()
        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)
        print("SUCCESS")
        print(api)
    }

    func _createEndpointsFile() throws {
        let data = try File(path: "ApiInputExample.json").read()
        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let endpointsText = apiGenerator.makeEndpointsFile()
        let endpointsFile = try FileSystem().createFile(at: "Endpoints.swift")
        try endpointsFile.write(string: endpointsText)
    }

    func _createServiceFiles() throws {
        let data = try File(path: "ApiInputExample.json").read()
        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let serviceTexts = apiGenerator.makeServiceFiles()

        for (idx, serviceText) in serviceTexts.enumerated() {
            let serviceFile = try FileSystem().createFile(at: "Service\(idx).swift")
            try serviceFile.write(string: serviceText)
        }
    }

    func _createModelSampleJson() throws {
        let person = Person.testPerson
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let personData = try encoder.encode(person)
        try FileSystem().createFile(at: "TestPerson.json", contents: personData)
    }

    func _createModelFile() throws {
        let data = try File(path: "TestPerson.json").read()

        let modelGenerator = try RequestrModelGenerator(modelName: "Person", jsonData: data)
        let modelText = modelGenerator.makeModelFile()
        let modelFile = try FileSystem().createFile(at: "TestPerson.swift")
        try modelFile.write(string: modelText)
    }

}

public extension SwiftyRestAPI {

    enum Error: Swift.Error {
        case missingFileName
        case failedToCreateFile
        case missingFeatureConvert
    }

}
