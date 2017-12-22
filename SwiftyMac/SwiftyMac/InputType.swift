//
//  InputType.swift
//  SwiftyMac
//
//  Created by Daniel Lozano Valdés on 12/22/17.
//  Copyright © 2017 icalialabs. All rights reserved.
//

import Foundation

enum InputType: String {

	case postman = "Postman"
	case swiftyApi = "SwiftyAPI"

	static let allValues: [InputType] = [.postman, .swiftyApi]

}
