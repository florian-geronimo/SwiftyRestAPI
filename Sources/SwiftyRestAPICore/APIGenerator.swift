//
//  APIGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

/// Multiline string representing the text data for an output file
public typealias FileText = String

public protocol APIGenerator {
    
    var api: API { get }
    
    var basePath: String { get }
    
    var allEndpoints: [API.Endpoint] { get }

    init(api: API)

    func makeEndpointsFile() -> FileText

    func makeServiceFiles() -> [FileText]

}
