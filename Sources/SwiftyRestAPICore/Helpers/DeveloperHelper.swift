// MARK: - Development Helper's
import Foundation
import Files
import Swiftline

extension SwiftyRestAPI {

    func _postmanConverter() throws {
        let inputFileName = ask("What is the input postman API doc file name?".foreground.Yellow)
        let data = try File(path: inputFileName).read()
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        let api = PostmanConvertr.shared.convert(json: json!)
        let apiGenerator = AlamofireAPIGenerator(api: api )
        let serviceTexts = apiGenerator.makeServiceFiles()

        var outputFileNames: [String] = []
        for (idx, serviceText) in serviceTexts.enumerated() {
            let outputFileName = "Service\(idx).swift"
            let serviceFile = try FileSystem().createFile(at: outputFileName)
            try serviceFile.write(string: serviceText)
            outputFileNames += [outputFileName]
        }

        let outputFileName = "Endpoints.swift"

        let endpointsText = apiGenerator.makeEndpointsFile()
        let endpointsFile = try FileSystem().createFile(at: outputFileName)
        try endpointsFile.write(string: endpointsText)

        print("Created file \(outputFileName)".foreground.Green)
        print("Created files \(outputFileNames.joined(separator: ", "))".foreground.Green)

    }

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
