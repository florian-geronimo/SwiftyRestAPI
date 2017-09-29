//
//  APIGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

/// Multiline string representing the text data for an output file
typealias FileText = String

/// Implement this protocol to create a custom APIGenerator
protocol APIGenerator {

    init(api: API)

    func makeEndpointsFile() -> FileText

    func makeServiceFiles() -> [FileText]

}
