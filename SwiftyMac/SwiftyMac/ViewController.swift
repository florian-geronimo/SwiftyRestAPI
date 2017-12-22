//
//  ViewController.swift
//  SwiftyMac
//
//  Created by Daniel Lozano Valdés on 12/21/17.
//  Copyright © 2017 icalialabs. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    lazy var features: [String : Feature] = {
        return ["Model Generator" : .modelGenerator,
                "API Generator" : .apiGenerator]
    }()

    var selectedFeature: Feature = .modelGenerator {
        didSet {
            updateFieldsVisibility()
            updateFeatureTypePopUpButton()
        }
    }

    var selectedInputFile: URL? {
        didSet {
            if let selectedInputFile = selectedInputFile {
                inputFileLabel.stringValue = selectedInputFile.relativeString
            }
            updateFieldsVisibility()
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var featureSelect: NSPopUpButton!
    @IBOutlet weak var featureTypeSelect: NSPopUpButton!

    @IBOutlet weak var mainStackView: NSStackView!
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
        setupVisualEffectBackgroundView()
        setupFeaturePopUpButton()

        updateFieldsVisibility()
        updateFeatureTypePopUpButton()
    }

    func setupVisualEffectBackgroundView() {
        visualEffectView.state = .active
        visualEffectView.material = .mediumLight
        // visualEffectView.blendingMode = .behindWindow
    }

    func setupFeaturePopUpButton() {
        featureSelect.addItems(withTitles: Feature.allFeatures.map { $0.rawValue })
    }

    func updateFeatureTypePopUpButton() {
        featureTypeSelect.removeAllItems()
        featureTypeSelect.addItems(withTitles: selectedFeature.featureTypes.map { $0.rawValue })
    }

    func updateFieldsVisibility() {
        inputFileLabel.isHidden = selectedInputFile == nil
        modelNameTextField.isHidden = selectedFeature != .modelGenerator

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
    }

    @IBAction func featureTypeSelectDidChange(_ sender: NSPopUpButton) {

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
