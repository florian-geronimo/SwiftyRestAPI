//
//  MainWindowController.swift
//  SwiftyMac
//
//  Created by Daniel Lozano Valdés on 12/21/17.
//  Copyright © 2017 icalialabs. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.title = ""
        window?.styleMask = [window!.styleMask, .fullSizeContentView]
        window?.titlebarAppearsTransparent = true
    }

}
