//
//  API.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

struct API {

    let basePath: String

    let categories: [Category]

    struct Category {

        let name: String

        let endpoints: [API.Endpoint]

    }

    struct Endpoint {

        let name: String

        let method: HTTPMethod

        let relativePath: String

        let urlParameters: [URLParameter]

    }

}
