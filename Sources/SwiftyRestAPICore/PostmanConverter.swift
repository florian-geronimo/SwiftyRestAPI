import Foundation

class PostmanConvertr {

  static let shared = PostmanConvertr()

  func convert(json: JSONDictionary) -> API {
     let basePath = getBasePath(json: json)
     let categories = getCategories(json: json)
     return API(basePath: basePath, categories: categories )
  }

  private func getBasePath(json: JSONDictionary) -> String {
    return ""
  }

  private func getCategories(json: JSONDictionary) -> [API.Category] {
    var categories = [API.Category]()

    let jsonCategories = json["item"] as! [[String:Any]]
    for jsonCategory in jsonCategories {
      let name = (jsonCategory["name"] as! String).trimmingCharacters(in: .whitespaces)

      let endpoints = getEndpoints(item: jsonCategory["item"] as! [[String:Any]])
      let category = API.Category(name: name, endpoints: endpoints)
      categories.append(category)
    }
    return categories
  }

  private func getEndpoints(item:[[String:Any]]) -> [API.Endpoint] {
    var endpoints = [API.Endpoint]()

    for dictPostmanEndpoint in item {
        let request = dictPostmanEndpoint["request"] as! [String:Any]
        let method = HTTPMethod(rawValue: request["method"] as! String)!
        let name = (dictPostmanEndpoint["name"] as! String).replacingOccurrences(of: " ", with: "")
        let relativePath = request["url"] as! String

        let endpoint = API.Endpoint(name: name,
                                  resourceName: name,
                                  isResourceArray: false,
                                  method: method,
                                  relativePath:relativePath,
                                  urlParameters:[])
        endpoints.append(endpoint)
    }

    return endpoints

  }


}
