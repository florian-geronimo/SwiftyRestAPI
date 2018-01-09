import Foundation
import Files
import Swiftline

public final class SwiftyRestAPI {

	enum Error: Swift.Error {
		case missingFileName
		case failedToCreateFile
		case missingFeatureConvert
	}

    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        try runCLIApp()
    }

}

// MARK: - CLI APP

public extension SwiftyRestAPI {

	func runCLIApp() throws {
		print("Welcome to SwiftyRestAPI generator!".foreground.Yellow.style.Bold)
		try chooseGenerator()
	}

	// MARK: API Generator CLI

	func chooseGenerator() throws {
		let modelGenerator = "Model Generator".foreground.Red.style.Bold
		let apiGenerator = "API Generator".foreground.Red.style.Bold

		let featureChoice = choose("What feature do you want to use?\n".foreground.Yellow.style.Bold, choices: modelGenerator, apiGenerator)

		if featureChoice == modelGenerator {
			try chooseModelGenerator()
		} else if featureChoice == apiGenerator {
			try chooseApiGenerator()
		}
	}

	func chooseApiGenerator() throws {
		print("\nAPI Generator".foreground.Yellow.style.Bold)

		let requestrApiGenerator = "Requestr API Generator".foreground.Red.style.Bold
		let alamofireApiGenerator = "Alamofire API Generator".foreground.Red.style.Bold

		let generatorChoice = choose("Ok! Which API generator do you want to use?\n".foreground.Yellow.style.Bold, choices: requestrApiGenerator, alamofireApiGenerator)

		let fileType = chooseInputType()
		let fileName = ask("What is the input API doc file name?".foreground.Yellow.style.Bold)

		let api: API

		switch fileType {
		case .postman:
			let data = try File(path: fileName).read()
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
			api = PostmanConvertr.shared.convert(json: json!)
		case .swifty:
			api = try fileNameToAPI(inputFileName: fileName )
		}

		switch generatorChoice {
		case requestrApiGenerator:
			print("Using Requestr Generator ...".foreground.Green.style.Bold)
			try createEndpointsFile(api: api)
			try createRequestrServiceFiles(api: api)
		case alamofireApiGenerator:
			print("Using Alamofire Generator ...".foreground.Green.style.Bold)
			try createEndpointsFile(api: api)
			try createAlamofireServiceFiles(api: api)
		default:
			return
		}

		print("Finished!".foreground.Green.style.Bold)
	}

	func chooseInputType() -> InputType {
		print("\nInput Types".foreground.Yellow.style.Bold)

		let postmanChoice = "Postman API json file".foreground.Red.style.Bold
		let swiftyRestAPIChoice = "Swifty API json file".foreground.Red.style.Bold
		let inputChoice = choose("Ok! What is the input API doc file type?\n".foreground.Yellow.style.Bold, choices: postmanChoice, swiftyRestAPIChoice)

		switch inputChoice {
		case postmanChoice:
			return .postman
		case swiftyRestAPIChoice:
			return .swifty
		default:
			return .swifty
		}
	}

	// MARK: Model Generator CLI

	func chooseModelGenerator() throws {
		print("Model Generator".foreground.Yellow.style.Bold)

		let requestrModelGenerator = "Requestr Model Generator".foreground.Red.style.Bold
		let codableModelGenerator = "Codable Model Generator".foreground.Red.style.Bold

		let generatorChoice = choose("Ok! Which model generator do you want to use?\n".foreground.Yellow.style.Bold, choices: requestrModelGenerator, codableModelGenerator)

		let inputFileName = ask("What is the input JSON file name?".foreground.Yellow.style.Bold)
		let modelName = ask("What is this model's name?".foreground.Yellow.style.Bold)

		switch generatorChoice {
		case requestrModelGenerator:
			try createModelFile(inputFileName: inputFileName, modelName: modelName, generatorType: RequestrModelGenerator.self)
		case codableModelGenerator:
			try createModelFile(inputFileName: inputFileName, modelName: modelName, generatorType: CodableModelGenerator.self)
		default:
			return
		}

		print("Done!".foreground.Green)
	}

}

// MARK: - File Generation

public extension SwiftyRestAPI {

	// MARK: API Generation

	func createEndpointsFile(api: API) throws {
		let outputFileName = "Endpoints.swift"
		let apiGenerator = RequestrAPIGenerator(api: api)
		let endpointsText = apiGenerator.makeEndpointsFile()
		let endpointsFile = try FileSystem().createFile(at: outputFileName)
		try endpointsFile.write(string: endpointsText)

		print("Created file \(outputFileName)".foreground.Green)
	}

	func createRequestrServiceFiles(api: API) throws {
		try _createServiceFiles(api: api, generatorType: RequestrAPIGenerator.self)
	}

	func createAlamofireServiceFiles(api: API) throws {
		try _createServiceFiles(api: api, generatorType: AlamofireAPIGenerator.self)
	}

	func _createServiceFiles<T: APIGenerator>(api: API, generatorType: T.Type) throws {
		let apiGenerator = T(api: api)
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

	// MARK: Model Generation

	func createModelFile<T: ModelGenerator>(inputFileName: String, modelName: String, generatorType: T.Type) throws {
		print("Using Model Generator ...".foreground.Green.style.Bold)

		let outputFileName = "\(modelName).swift"
		let inputData = try File(path: inputFileName).read()
		let modelGenerator: ModelGenerator = try T(modelName: modelName, jsonData: inputData)
		let modelText = modelGenerator.makeModelFile()
		let modelFile = try FileSystem().createFile(at: outputFileName)
		try modelFile.write(string: modelText)

		print("Created file \(outputFileName)".foreground.Green.style.Bold)
	}

}

// MARK: - Helper's

public extension SwiftyRestAPI {

	func fileNameToAPI(inputFileName: String) throws -> API {
		let data = try File(path: inputFileName).read()
		let decoder = JSONDecoder()
		let api = try decoder.decode(API.self, from: data)
		return api
	}

}
