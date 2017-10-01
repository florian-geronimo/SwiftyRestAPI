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

    private func runCLIApp() throws {
        print("Welcome to SwiftyRestAPI generator!".foreground.Red.background.Yellow.style.Bold)

        let modelGenerator = "Model Generator".foreground.Blue.style.Underline
        let apiGenerator = "API Generator".foreground.Blue.style.Underline
        let featureChoice = choose("What feature do you want to use?\n".foreground.Yellow, choices: modelGenerator, apiGenerator)

        if featureChoice == modelGenerator {
            try choseModelGenerator()
        } else if featureChoice == apiGenerator {
            try choseApiGenerator()
        }
    }

    private func choseModelGenerator() throws {
        print("Model Generator".foreground.Red.background.Yellow.style.Bold)

        let requestrModelGenerator = "Requestr Model Generator".foreground.Blue.style.Underline
        let generatorChoice = choose("Ok! Which model generator do you want to use?\n".foreground.Yellow, choices: requestrModelGenerator)

        guard generatorChoice == requestrModelGenerator else {
            return
        }

        let inputFileName = ask("What is the input JSON file name?".foreground.Yellow)
        let modelName = ask("What is this model's name?".foreground.Yellow)
        try createModelFile(inputFileName: inputFileName, modelName: modelName)

        print("Done!".foreground.Red)
    }

    private func choseApiGenerator() throws {
        print("API Generator".foreground.Red.background.Yellow.style.Bold)

        let requestrApiGenerator = "Requestr API Generator".foreground.Blue.style.Underline
        let generatorChoice = choose("Ok! Which API generator do you want to use?\n".foreground.Yellow, choices: requestrApiGenerator)

        guard generatorChoice == requestrApiGenerator else {
            return
        }

        let inputFileName = ask("What is the input API doc file name?".foreground.Yellow)
        try createEndpointsFile(inputFileName: inputFileName)
        try createServiceFiles(inputFileName: inputFileName)

        print("Finished!".foreground.Red)
    }

    // MARK: - Helper's

    private func createModelFile(inputFileName: String, modelName: String) throws {
        let outputFileName = "\(modelName).swift"
        let inputData = try File(path: inputFileName).read()

        let modelGenerator = try RequestrModelGenerator(modelName: modelName, jsonData: inputData)
        let modelText = modelGenerator.makeModelFile()
        let modelFile = try FileSystem().createFile(at: outputFileName)
        try modelFile.write(string: modelText)

        print("Created file \(outputFileName)".foreground.Red)
    }

    private func createEndpointsFile(inputFileName: String) throws {
        let outputFileName = "Endpoints.swift"
        let data = try File(path: inputFileName).read()

        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let endpointsText = apiGenerator.makeEndpointsFile()
        let endpointsFile = try FileSystem().createFile(at: outputFileName)
        try endpointsFile.write(string: endpointsText)

        print("Created file \(outputFileName)".foreground.Red)
    }

    private func createServiceFiles(inputFileName: String) throws {
        let data = try File(path: inputFileName).read()

        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let serviceTexts = apiGenerator.makeServiceFiles()

        var outputFileNames: [String] = []
        for (idx, serviceText) in serviceTexts.enumerated() {
            let outputFileName = "Service\(idx).swift"
            let serviceFile = try FileSystem().createFile(at: outputFileName)
            try serviceFile.write(string: serviceText)
            outputFileNames += [outputFileName]
        }

        print("Created files \(outputFileNames.joined(separator: ", "))".foreground.Red)
    }

}

// MARK: - Development Helper's

private extension SwiftyRestAPI {

    func _createExampleApiInput() throws {
        let getUser = API.Endpoint(name: "getUser", resourceName: "User", isResourceArray: false, method: .GET, relativePath: "/users/1", urlParameters: [])
        let postUser = API.Endpoint(name: "postUser", resourceName: "User", isResourceArray: false, method: .POST, relativePath: "/users/1", urlParameters: [])
        let usersCategory = API.Category(name: "Users", endpoints: [getUser, postUser])

        let getPlaces = API.Endpoint(name: "getPlaces", resourceName: "Place", isResourceArray: true, method: .GET, relativePath: "/places", urlParameters: [])
        let postPlace = API.Endpoint(name: "postPlace", resourceName: "Place", isResourceArray: false, method: .POST, relativePath: "/places/1", urlParameters: [])
        let putPlace = API.Endpoint(name: "putPlace", resourceName: "Place", isResourceArray: false, method: .PUT, relativePath: "/places/1", urlParameters: [])
        let placesCategory = API.Category(name: "Places", endpoints: [getPlaces, postPlace, putPlace])

        let api = API(basePath: "http://www.icalialabs.com/", categories: [usersCategory, placesCategory])

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(api)
        let file = try FileSystem().createFile(at: "ApiInput.json")
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
        try FileSystem().createFile(at: "Person.json", contents: personData)
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
