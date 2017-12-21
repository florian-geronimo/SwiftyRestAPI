//
//  Feature.swift
//  SwiftyMac
//
//  Created by Daniel Lozano Valdés on 12/21/17.
//  Copyright © 2017 icalialabs. All rights reserved.
//

import Foundation

enum Feature: String {

    case modelGenerator = "Model Generator"
    case apiGenerator = "API Generator"

    static let allFeatures: [Feature] = [.modelGenerator, .apiGenerator]

    var featureTypes: [FeatureType] {
        switch self {
        case .modelGenerator:
            return [.codable, .requestr]
        case .apiGenerator:
            return [.requestr, .alamoFire]
        }
    }

}
