import Foundation
import Files
import Swiftline

public final class SwiftyRestAPI {

    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {

    }

    public func run_CREATE_EXAMPLE_API_INPUT() throws {
        let getUser = API.Endpoint(name: "getUser", method: .GET, relativePath: "/users/1", urlParameters: [])
        let getUsers = API.Endpoint(name: "getUsers", method: .GET, relativePath: "/users", urlParameters: [])
        let postUser = API.Endpoint(name: "postUser", method: .POST, relativePath: "/users/1", urlParameters: [])
        let category = API.Category(name: "Users", endpoints: [getUser, getUsers, postUser])
        let api = API(basePath: "http://www.icalialabs.com/", categories: [category])

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(api)
        let file = try FileSystem().createFile(at: "ApiInputExample.json")
        try file.write(data: data)
    }

    public func run_READ_EXAMPLE_API_INPUT() throws {
        let filePath = ask("What file?")
        let data = try File(path: filePath).read()
        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)
        print("SUCCESS")
        print(api)
    }

    public func run_CREATE_ENDPOINTS_FILE() throws {
        let data = try File(path: "ApiInputExample.json").read()
        let decoder = JSONDecoder()
        let api = try decoder.decode(API.self, from: data)

        let apiGenerator = RequestrAPIGenerator(api: api)
        let endpointsText = apiGenerator.makeEndpointsFile()
        let endpointsFile = try FileSystem().createFile(at: "Endpoints.swift")
        try endpointsFile.write(string: endpointsText)
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

public extension SwiftyRestAPI {

    enum Error: Swift.Error {
        case missingFileName
        case failedToCreateFile
        case missingFeatureConvert
    }

}
