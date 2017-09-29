//
//  RequestrAPIGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

final class RequestrAPIGenerator: APIGenerator {

    let api: API

    init(api: API) {
        self.api = api
    }

    func makeEndpointsFile() -> FileText {
        var text = ""
        text += ""
        text += ""
        return text
    }

    func makeServiceFiles() -> [FileText] {
        var text = ""
        text += ""
        text += ""
        return [text]
    }

}

// Output should look like this:
//enum Endpoint {
//
//    static let baseURL = ""
//
//    case places
//    case search
//    case quotes
//
//    var fullPath: String {
//        let path: String
//        switch self {
//        case .places:
//            path = "/v2/places"
//        case .search:
//            path = "/v2/search"
//        case .quotes:
//            path = "/v2/quotes"
//        }
//        return Endpoint.baseURL + path
//    }
//
//}
