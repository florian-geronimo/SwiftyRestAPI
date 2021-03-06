//
//  RequestrAPIGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

public class RequestrAPIGenerator: APIGenerator {

    public  let api: API

    public lazy var basePath: String = {
        return api.basePath
    }()

    public lazy var allEndpoints: [API.Endpoint] = {
        return api.categories.flatMap { $0.endpoints }
    }()

    // MARK: - API Generator

    public required init(api: API) {
        self.api = api
    }

}

// MARK: - Endpoints File

extension RequestrAPIGenerator {

    // MARK: Helper's

    private func makeBaseURL(with baseURL: String) -> String {
        return """
            static let baseURL = "\(baseURL)"
        """
    }

    private func makeEnumCases(for endpoints: [API.Endpoint]) -> String {
        var string = ""
        for endpoint in endpoints {
            string += """
                case \(endpoint.name)

            """
        }
        return String(string.dropLast())
    }

    private func makeFullPathComputedProperty(for endpoints: [API.Endpoint]) -> String {
        var string = ""
        string += """
            var fullPath: String {
                let path: String
                switch self {

        """
        for endpoint in endpoints {
            string += """
                        case .\(endpoint.name):
                            path = "\(endpoint.relativePath)"

            """
        }
        string += """
                }
                return Endpoint.baseURL + path
            }
        """
        return string
    }

}

// MARK: - Service Files

extension RequestrAPIGenerator {

    public func makeServiceFiles() -> [FileText] {
        return api.categories.map(makeServiceFile)
    }

    private func makeServiceFile(for category: API.Category) -> FileText {
        return """
        \(makeHeader(fileName: fileName(for: category)))

        import Foundation
        import Requestr

        \(makeServiceProtocol(for: category))

        \(makeServiceApiClass(for: category))

        \(makeProtocolImplementationExtension(for: category))

        """
    }

    // MARK: Helper's

    private func fileName(for category: API.Category) -> String {
        return "\(category.name)Service.swift"
    }

    private func protocolName(for category: API.Category) -> String {
        return "\(category.name)Service"
    }

    private func className(for category: API.Category) -> String {
        return "\(category.name)ApiService"
    }

    private func methodSignatureForEndpoint(_ endpoint: API.Endpoint) -> String {
        var resourceName = endpoint.resourceName
        if endpoint.isResourceArray {
            resourceName.insert("[", at: resourceName.startIndex)
            resourceName.insert("]", at: resourceName.endIndex)
        }
        return "func \(endpoint.name)(completion: @escaping (ApiResult<\(resourceName)>) -> Void)"
    }

    private func makeServiceProtocol(for category: API.Category) -> String {
        return """
        protocol \(protocolName(for: category)) {

        \(makeServiceProtocolMethods(for: category))

        }
        """
    }

    private func makeServiceProtocolMethods(for category: API.Category) -> String {
        var string = ""
        for endpoint in category.endpoints {
            string += """
                \(methodSignatureForEndpoint(endpoint))


            """
        }
        return String(string.dropLast().dropLast())
    }

    private func makeServiceApiClass(for category: API.Category) -> String {
        return """
        class \(className(for: category)) {

            let apiClient: ApiClient

            init(apiClient: ApiClient) {
                self.apiClient = apiClient
            }

        }

        """
    }

    private func makeProtocolImplementationExtension(for category: API.Category) -> String {
        return """
        extension \(className(for: category)): \(protocolName(for: category)) {

        \(makeProtocolImplementationExtensionMethods(for: category))

        }
        """
    }

    private func makeProtocolImplementationExtensionMethods(for category: API.Category) -> String {
        var string = ""
        for endpoint in category.endpoints {
            string += """
                \(methodSignatureForEndpoint(endpoint)) {
                    let endpoint = Endpoint.\(endpoint.name)
                    apiClient.\(endpoint.method.rawValue)(endpoint.fullPath) { (result) in
                        completion(Result(apiResult: result))
                    }
                }


            """
        }
        return String(string.dropLast().dropLast())
    }

}
