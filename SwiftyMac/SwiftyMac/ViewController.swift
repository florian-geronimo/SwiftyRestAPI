//
//  ViewController.swift
//  SwiftyMac
//
//  Created by Daniel Lozano Valdés on 12/21/17.
//  Copyright © 2017 icalialabs. All rights reserved.
//

import Cocoa
import Files
import SwiftyRestAPI

class ViewController: NSViewController {

	// MARK: - Properties

    lazy var features: [String : Feature] = {
        return ["Model Generator" : .modelGenerator,
                "API Generator" : .apiGenerator]
    }()

	// MARK: Feature Selection

    var selectedFeature: Feature = .modelGenerator {
        didSet {
			updateFieldTitles()
            updateFieldsVisibility()
            updateFeatureTypePopUpButton()
        }
    }

	var selectedFeatureType: FeatureType = Feature.modelGenerator.featureTypes.first!

	var selectedInputType: InputType = .postman

	// MARK: File input, output

    var selectedInputFile: URL? {
        didSet {
            if let selectedInputFile = selectedInputFile {
                inputFileLabel.stringValue = selectedInputFile.lastPathComponent
            }
            updateFieldsVisibility()
        }
    }

	var selectedOutputDirectory: URL?

	// MARK: Other

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

	// MARK: Outlet's

	@IBOutlet weak var featureSelectTitleLabel: NSTextField!
	@IBOutlet weak var featureSelect: NSPopUpButton!
	@IBOutlet weak var featureTypeSelectTitleLabel: NSTextField!
	@IBOutlet weak var featureTypeSelect: NSPopUpButton!
	@IBOutlet weak var inputTypeSelectTitleLabel: NSTextField!
	@IBOutlet weak var inputTypeSelect: NSPopUpButton!
	
    @IBOutlet weak var inputFileButton: NSButton!
    @IBOutlet weak var inputFileLabel: NSTextField!
    @IBOutlet weak var modelNameTextField: NSTextField!
    @IBOutlet weak var createButton: NSButton!
	@IBOutlet weak var informationLabel: NSTextField!

    @IBOutlet weak var visualEffectView: NSVisualEffectView!

	// MARK: - NSViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    func setup() {
		setupPopUpButtons()
        setupVisualEffectBackgroundView()

		updateFieldTitles()
        updateFieldsVisibility()
        updateFeatureTypePopUpButton()
    }

    func setupVisualEffectBackgroundView() {
        visualEffectView.state = .active
        visualEffectView.material = .ultraDark
        visualEffectView.blendingMode = .behindWindow
    }

    func setupPopUpButtons() {
        featureSelect.addItems(withTitles: Feature.allFeatures.map { $0.rawValue })
		inputTypeSelect.addItems(withTitles: InputType.allValues.map { $0.rawValue })
    }

    func updateFeatureTypePopUpButton() {
        featureTypeSelect.removeAllItems()
        featureTypeSelect.addItems(withTitles: selectedFeature.featureTypes.map { $0.rawValue })
    }

	func updateFieldTitles() {
		switch selectedFeature {
		case .apiGenerator:
			featureTypeSelectTitleLabel.stringValue = "Which API generator do you want to use?"
		case .modelGenerator:
			featureTypeSelectTitleLabel.stringValue = "Which model generator do you want to use?"
		}
	}

    func updateFieldsVisibility() {
        inputFileLabel.isHidden = selectedInputFile == nil
        modelNameTextField.isHidden = !(selectedFeature == .modelGenerator)

		inputTypeSelectTitleLabel.isHidden = !(selectedFeature == .apiGenerator)
		inputTypeSelect.isHidden = !(selectedFeature == .apiGenerator)
    }

}

// MARK: - Actions

extension ViewController {

    @IBAction func featureSelectDidChange(_ sender: NSPopUpButton) {
        guard let selectedTitle = sender.titleOfSelectedItem, let selectedFeature = Feature(rawValue: selectedTitle) else {
            return
        }

        self.selectedFeature = selectedFeature
		self.selectedFeatureType = selectedFeature.featureTypes.first!
    }

    @IBAction func featureTypeSelectDidChange(_ sender: NSPopUpButton) {
		guard let selectedTitle = sender.titleOfSelectedItem, let selectedFeatureType = FeatureType(rawValue: selectedTitle) else {
			return
		}

		self.selectedFeatureType = selectedFeatureType
    }

	@IBAction func inputTypeSelectDidChange(_ sender: NSPopUpButton) {
		guard let selectedTitle = sender.titleOfSelectedItem, let selectedInputType = InputType(rawValue: selectedTitle) else {
			return
		}

		self.selectedInputType = selectedInputType
	}

    @IBAction func didSelectChooseInputFile(_ sender: Any) {
		presentOpenPanel(forDirectory: false) { (url) in
			guard let url = url else {
				return
			}
			self.selectedInputFile = url
		}
    }

    @IBAction func didSelectCreate(_ sender: Any) {
		print("FEATURE: \(selectedFeature)")
		print("FEATURE TYPE: \(selectedFeatureType)")
		print("INPUT TYPE: \(selectedInputType)")
		print("INPUT FILE: \(selectedInputFile!)")
		runFeature(selectedFeature)
    }

}

// MARK: - SwiftyRestAPI

extension ViewController {

	// MARK: Feature

	func runFeature(_ feature: Feature) {
		guard let inputFile = selectedInputFile else {
			print("Missing input file. Aborting.")
			return
		}

		presentOpenPanel(forDirectory: true) { (url) in
			guard let selectedOutputDirectory = url else {
				print("Missing output directory. Aborting.")
				return
			}
			self.selectedOutputDirectory = selectedOutputDirectory
			self._runFeature(feature, inputFile: inputFile, outputDirectory: selectedOutputDirectory)
		}
	}

	func _runFeature(_ feature: Feature, inputFile: URL, outputDirectory: URL) {
		do {
			switch feature {
			case .apiGenerator:
				try runApiGenerator(with: selectedInputType, inputFile: inputFile, outputDirectory: outputDirectory)
			case .modelGenerator:
				try runModelGenerator(with: selectedInputType, inputFile: inputFile, outputDirectory: outputDirectory)
			}
		} catch {
			print("ERROR = \(error)")
		}
	}

	// MARK: API Generator

	func runApiGenerator(with input: InputType, inputFile: URL, outputDirectory: URL) throws {
		let api: API

		switch input {
		case .postman:
			let data = try File(path: inputFile.relativePath).read()
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
			api = PostmanConvertr.shared.convert(json: json!)
		case .swiftyApi:
			api = try fileToAPI(inputPath: inputFile.relativePath)
		}

		try createEndpointsFile(with: api, outputDirectory: outputDirectory)
		try createServiceFiles(with: api, featureType: selectedFeatureType, outputDirectory: outputDirectory)
	}

	func createEndpointsFile(with api: API, outputDirectory: URL) throws {
		let outputFileName = "Endpoints.swift"
		let outputFilePath = outputDirectory.relativePath + "/" + outputFileName

		let apiGenerator = RequestrAPIGenerator(api: api)
		let endpointsText = apiGenerator.makeEndpointsFile()

		let endpointsFile = try FileSystem().createFile(at: outputFilePath)
		try endpointsFile.write(string: endpointsText)

		let message = "Created file \(endpointsFile.path)"
		print(message)
		informationLabel.stringValue = message
	}

	func createServiceFiles(with api: API, featureType: FeatureType, outputDirectory: URL) throws {
		switch selectedFeatureType {
		case .requestr:
			try _createServiceFiles(api: api, outputDirectory: outputDirectory, generatorType: RequestrAPIGenerator.self)
		case .alamoFire:
			try _createServiceFiles(api: api, outputDirectory: outputDirectory, generatorType: AlamofireAPIGenerator.self)
		default:
			print("Invalid feature type. Aborting.")
			return
		}
	}

	func _createServiceFiles<T: APIGenerator>(api: API, outputDirectory: URL, generatorType: T.Type) throws {
		let apiGenerator = T(api: api)
		let serviceTexts = apiGenerator.makeServiceFiles()

		var outputFilePaths: [String] = []

		for (idx, serviceText) in serviceTexts.enumerated() {
			let outputFileName = "Service\(idx).swift"
			let outputFilePath = outputDirectory.relativePath + "/" + outputFileName

			let serviceFile = try FileSystem().createFile(at: outputFilePath)
			try serviceFile.write(string: serviceText)
			outputFilePaths += [outputFilePath]
		}

		let message = "Created files \(outputFilePaths.joined(separator: ", "))"
		print(message)
		informationLabel.stringValue = message
	}

	// MARK: Model Generator

	func runModelGenerator(with input: InputType, inputFile: URL, outputDirectory: URL) throws {
		let modelName = modelNameTextField.stringValue

		switch selectedFeatureType {
		case .requestr:
			try createModelFile(inputFile: inputFile, outputDirectory: outputDirectory, modelName: modelName, generatorType: RequestrModelGenerator.self)
		case .codable:
			try createModelFile(inputFile: inputFile, outputDirectory: outputDirectory, modelName: modelName, generatorType: CodableModelGenerator.self)
		default:
			print("Invalid feature type. Aborting")
			return
		}
	}

	func createModelFile<T: ModelGenerator>(inputFile: URL, outputDirectory: URL, modelName: String, generatorType: T.Type) throws {
		let outputFileName = "\(modelName).swift"
		let outputFilePath = outputDirectory.relativePath + "/" + outputFileName

		let inputData = try File(path: inputFile.relativePath).read()
		let modelGenerator: ModelGenerator = try T(modelName: modelName, jsonData: inputData)
		let modelText = modelGenerator.makeModelFile()
		let modelFile = try FileSystem().createFile(at: outputFilePath)
		try modelFile.write(string: modelText)

		let message = "Created file \(modelFile.path)"
		print(message)
		informationLabel.stringValue = message
	}

	// MARK: Helper's

	func fileToAPI(inputPath: String) throws -> API {
		let data = try File(path: inputPath).read()
		let decoder = JSONDecoder()
		let api = try decoder.decode(API.self, from: data)
		return api
	}

}

// MARK: - Document Handling

extension ViewController {

	func presentOpenPanel(forDirectory: Bool, _ completion: @escaping ((URL?) -> Void)) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false

		if forDirectory {
			openPanel.canChooseDirectories = true
			openPanel.canChooseFiles = false
		} else {
			openPanel.canChooseDirectories = false
			openPanel.allowedFileTypes = ["swift", "json"]
		}

        guard let window = view.window else {
            return
        }

        openPanel.beginSheetModal(for: window) { (response) in
            guard response == NSApplication.ModalResponse.OK else {
                return
            }

            let fileUrl = openPanel.url
            completion(fileUrl)
        }
    }


    func presentSavePanel(_ completion: @escaping ((URL?) -> Void)) {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["swift", "json"]

        guard let window = view.window else {
            return
        }

        savePanel.beginSheetModal(for: window) { (response) in
            guard response == NSApplication.ModalResponse.OK else {
                return
            }

            let fileUrl = savePanel.url
            completion(fileUrl)
        }
    }

}
