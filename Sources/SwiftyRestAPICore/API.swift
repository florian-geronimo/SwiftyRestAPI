//
//  API.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

struct API: Codable {

    let basePath: String

    let categories: [Category]

    struct Category: Codable {
        let name: String
        let endpoints: [API.Endpoint]
    }

    struct Endpoint: Codable {
        let name: String
        let method: HTTPMethod
        let relativePath: String
        let urlParameters: [URLParameter]
    }

}

extension API {

    enum Error: Swift.Error {
        case error
    }

}
