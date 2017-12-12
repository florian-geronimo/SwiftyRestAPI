import Foundation

final class AlamofireAPIGenerator: APIGenerator {

    let api: API

    lazy var basePath: String = {
        return api.basePath
    }()

    lazy var allEndpoints: [API.Endpoint] = {
        return api.categories.flatMap { $0.endpoints }
    }()

    // MARK: - API Generator

    init(api: API) {
        self.api = api
    }

}

// MARK: - Service Files

extension AlamofireAPIGenerator {

    func makeServiceFiles() -> [FileText] {
        return api.categories.map(makeServiceFile)
    }

    private func makeServiceFile(for category: API.Category) -> FileText {
        return """
        \(makeHeader(fileName: fileName(for: category)))

        import Foundation
        import Alamofire

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
        return "func \(endpoint.name)(completion: @escaping (\(resourceName)) -> Void)"
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
          let resourceName = endpoint.resourceName
            string += """
                \(methodSignatureForEndpoint(endpoint)) {
                    let endpoint = Endpoint.\(endpoint.name)

                    Alamofire.request(endpoint.fullPath, method: .\(endpoint.method.rawValue.lowercased())).response { response in
                        let decoder = JSONDecoder()
                        let \(resourceName.lowercased()) = try decoder.decode(\(resourceName).self, from: response)
                        completion(\(resourceName.lowercased()))
                    }
                }


            """
        }
        return String(string.dropLast().dropLast())
    }

}
