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

    lazy var features: [String : Feature] = {
        return ["Model Generator" : .modelGenerator,
                "API Generator" : .apiGenerator]
    }()

    var selectedFeature: Feature = .modelGenerator {
        didSet {
			updateFieldTitles()
            updateFieldsVisibility()
            updateFeatureTypePopUpButton()
        }
    }

	var selectedFeatureType: FeatureType = Feature.modelGenerator.featureTypes.first!

	var selectedInputType: InputType = .postman

    var selectedInputFile: URL? {
        didSet {
            if let selectedInputFile = selectedInputFile {
                inputFileLabel.stringValue = selectedInputFile.lastPathComponent
            }
            updateFieldsVisibility()
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

	@IBOutlet weak var featureSelectTitleLabel: NSTextField!
	@IBOutlet weak var featureSelect: NSPopUpButton!
	@IBOutlet weak var featureTypeSelectTitleLabel: NSTextField!
	@IBOutlet weak var featureTypeSelect: NSPopUpButton!
	@IBOutlet weak var inputTypeSelectTitleLabel: NSTextField!
	@IBOutlet weak var inputTypeSelect: NSPopUpButton!
	
    @IBOutlet weak var inputFileButton: NSButton!
    @IBOutlet weak var inputFileLabel: NSTextField!
    @IBOutlet weak var fileNameTextField: NSTextField!
    @IBOutlet weak var modelNameTextField: NSTextField!
    @IBOutlet weak var createButton: NSButton!
    @IBOutlet weak var createLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    @IBOutlet weak var visualEffectView: NSVisualEffectView!

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

        createLabel.isHidden = true
        progressIndicator.isHidden = true
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
        presentOpenPanel { (url) in
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
		print("INPUT FILE: \(selectedInputFile)")
		runFeature(selectedFeature)
    }

}

// MARK: - Creation

extension ViewController {

	func runFeature(_ feature: Feature) {
		guard let inputFile = selectedInputFile else {
			print("Missing input file")
			return
		}

		do {
			switch feature {
			case .apiGenerator:
				try runApiGenerator(with: selectedInputType, file: inputFile)
			case .modelGenerator:
				try runModelGenerator(with: selectedInputType)
			}
		} catch {
			print("ERROR = \(error)")
		}
	}

	func runApiGenerator(with input: InputType, file: URL) throws {
		let api: API

		switch input {
		case .postman:
			let data = try File(path: file.absoluteString).read()
			let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
			api = PostmanConvertr.shared.convert(json: json!)
		case .swiftyApi:
			api = try fileToAPI(inputPath: file.absoluteString)
		}

		try createEndpointsFile(with: api)
		try createServiceFiles(with: api, featureType: selectedFeatureType)
	}

	func createEndpointsFile(with api: API) throws {
		let outputFileName = "Endpoints.swift"
		let apiGenerator = RequestrAPIGenerator(api: api)
		let endpointsText = apiGenerator.makeEndpointsFile()
		let endpointsFile = try FileSystem().createFile(at: outputFileName)
		try endpointsFile.write(string: endpointsText)

		// print("Created file \(outputFileName)".foreground.Green)
	}

	func createServiceFiles(with api: API, featureType: FeatureType) throws {
		switch selectedFeatureType {
		case .requestr:
			try _createServiceFiles(api: api, generatorType: RequestrAPIGenerator.self)
		case .alamoFire:
			try _createServiceFiles(api: api, generatorType: AlamofireAPIGenerator.self)
		default:
			print("Invalid feature type. Aborting.")
			return
		}
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

		// print("Created files \(outputFileNames.joined(separator: ", "))".foreground.Green)
	}

	func runModelGenerator(with input: InputType) throws {
		guard let inputFilePath = selectedInputFile?.relativePath else {
			print("Invalid input file path. Aborting")
			return
		}

		let modelName = modelNameTextField.stringValue

		switch selectedFeatureType {
		case .requestr:
			try createModelFile(filePath: inputFilePath, modelName: modelName, generatorType: RequestrModelGenerator.self)
		case .codable:
			try createModelFile(filePath: inputFilePath, modelName: modelName, generatorType: CodableModelGenerator.self)
		default:
			print("Invalid feature type. Aborting")
			return
		}
	}

	func createModelFile<T: ModelGenerator>(filePath: String, modelName: String, generatorType: T.Type) throws {
		let outputFileName = "\(modelName).swift"
		let inputData = try File(path: filePath).read()
		let modelGenerator: ModelGenerator = try T(modelName: modelName, jsonData: inputData)
		let modelText = modelGenerator.makeModelFile()
		let modelFile = try FileSystem().createFile(at: outputFileName)
		try modelFile.write(string: modelText)

		print("Created file \(modelFile.path)")
	}

	// MARK: Helper's

	func fileToAPI(inputPath: String) throws -> API {
		let data = try File(path: inputPath).read()
		let decoder = JSONDecoder()
		let api = try decoder.decode(API.self, from: data)
		return api
	}

}

// MARK: - SwiftyRestAPI

extension ViewController {

    func generateWithUrl(_ url: URL) {

    }

}

// MARK: - Document Handling

extension ViewController {

    func presentOpenPanel(_ completion: @escaping ((URL?) -> Void)) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["swift", "json"]

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
