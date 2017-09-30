import Foundation
import Files
import Swiftline

public final class SwiftyRestAPI {

    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        try createModelFile()
    }

    public func run_ORIGINAL_CODE() throws {
      guard arguments.count > 1 else {
          throw Error.missingFeatureConvert
      }

      guard arguments[1] == "convert" else {
          throw Error.missingFeatureConvert
      }

      guard arguments.count > 2 else {
          throw Error.missingFileName
      }

        let fileName = arguments[2]
        //let feature = arguments[1]

        do {          
            try FileSystem().createFile(at: fileName)
            print("\(fileName) created at \(Folder.current)".f.Green )
        } catch {
            throw Error.failedToCreateFile
        }
    }
}

private extension SwiftyRestAPI {

    func createExampleApiInput() throws {
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

    func readExampleApiInput() throws {
        let filePath = ask("What file?")
        let data = try File(path: filePath).read()
        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)
        print("SUCCESS")
        print(api)
    }

    func createEndpointsFile() throws {
        let data = try File(path: "ApiInputExample.json").read()
        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let endpointsText = apiGenerator.makeEndpointsFile()
        let endpointsFile = try FileSystem().createFile(at: "Endpoints.swift")
        try endpointsFile.write(string: endpointsText)
    }

    func createServiceFiles() throws {
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

    func createModelSampleJson() throws {
        let person = Person.testPerson
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let personData = try encoder.encode(person)
        try FileSystem().createFile(at: "TestPerson.json", contents: personData)
    }

    func createModelFile() throws {
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
