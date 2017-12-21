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
            updateFeatureTypePopUpButton()
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
    @IBOutlet weak var fileNameTextField: NSTextField!
    @IBOutlet weak var modelNameTextField: NSTextField!

    @IBOutlet weak var visualEffectView: NSVisualEffectView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Setup

    func setup() {
        setupFeaturePopUpButton()
        updateFeatureTypePopUpButton()
        setupVisualEffectBackgroundView()
    }

    func setupFeaturePopUpButton() {
        featureSelect.addItems(withTitles: Feature.allFeatures.map { $0.rawValue })
    }

    func updateFeatureTypePopUpButton() {
        featureTypeSelect.removeAllItems()
        featureTypeSelect.addItems(withTitles: selectedFeature.featureTypes.map { $0.rawValue })
    }

    func setupVisualEffectBackgroundView() {
        visualEffectView.state = .active
        visualEffectView.material = .mediumLight
        // visualEffectView.blendingMode = .behindWindow
    }
    
}

// MARK: - Actions

extension ViewController {

    @IBAction func featureSelectDidChange(_ sender: NSPopUpButton) {
        guard let selectedTitle = sender.titleOfSelectedItem, let selectedFeature = Feature(rawValue: selectedTitle) else {
            return
        }

        print(selectedFeature.rawValue)
        self.selectedFeature = selectedFeature
    }

    @IBAction func featureTypeSelectDidChange(_ sender: NSPopUpButton) {

    }

    @IBAction func didSelectChooseInputFile(_ sender: Any) {
        openInputFile()
    }

}

// MARK: - Document Handling

extension ViewController {

    func openInputFile() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.allowedFileTypes = ["swift"]

        guard let window = view.window else {
            return
        }

        openPanel.beginSheetModal(for: window) { (response) in
            guard response == NSApplication.ModalResponse.OK else {
                return
            }

            let file = openPanel.url
            print(file)
        }
    }

//
//    func saveDocument(_ sender: AnyObject?) {
//        guard editedImage != nil else {
//            return
//        }
//
//        let savePanel = NSSavePanel()
//        savePanel.allowedFileTypes = ["jpg"]
//        savePanel.beginSheetModal(for: view.window!) { (result: Int) -> Void in
//            guard result == NSModalResponseOK else{
//                return
//            }
//
//            let fileURL = savePanel.url
//            _ = self.saveEditedImageToURL(fileURL)
//        }
//    }

}
