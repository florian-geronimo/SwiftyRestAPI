import Foundation

public class PostmanConvertr {

  public static let shared = PostmanConvertr()

  public func convert(json: JSONDictionary) -> API {
     let basePath = getBasePath(json: json)
     let categories = getCategories(json: json)
     return API(basePath: basePath, categories: categories )
  }

  private func getBasePath(json: JSONDictionary) -> String {
     let jsonCategories = json["item"] as! [[String:Any]]
     let jsonCategory = jsonCategories[0]
     let jsonItems = jsonCategory["item"] as! [[String:Any]]
     let jsonItem = jsonItems[0]
     let request = jsonItem["request"] as! [String:Any]

     let url = request["url"] as! String
     return String.getBasePath(url:url)

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

  private func getEndpoints(item: [[String:Any]]) -> [API.Endpoint] {
    var endpoints = [API.Endpoint]()

    for dictPostmanEndpoint in item {
        let request = dictPostmanEndpoint["request"] as! [String:Any]
        let method = HTTPMethod(rawValue: request["method"] as! String)!
        let name = (dictPostmanEndpoint["name"] as! String).replacingOccurrences(of: " ", with: "").lowercaseFirst()
        let relativePath = (request["url"] as! String)

        let endpoint = API.Endpoint(name: name,
                                  resourceName: name.capitalizeFirst(),
                                  isResourceArray: false,
                                  method: method,
                                  relativePath: String.getEndpoint(url: relativePath),
                                  urlParameters:[])
        endpoints.append(endpoint)
    }

    return endpoints

  }
}

extension String {
    func capitalizeFirst() -> String {
        var result = self
        let substr1 = String(self[startIndex]).uppercased()
        result.replaceSubrange(...startIndex, with: substr1)

        return result
    }

    func lowercaseFirst() -> String {
        var result = self
        let substr1 = String(self[startIndex]).lowercased()
        result.replaceSubrange(...startIndex, with: substr1)

        return result
    }

    static func getBasePath(url: String) -> String {
        var ocurrance = 0
        let index = url.index { (character) -> Bool in
            if character == "/" {
                ocurrance += 1
                if ocurrance == 3 {
                    return true
                }
            }
            return false
        }

        let basePath = String(url[..<index!])

        return basePath
    }

    static func getEndpoint(url: String) -> String {
        var ocurrance = 0
        let index = url.index { (character) -> Bool in
            if character == "/" {
                ocurrance += 1
                if ocurrance == 3 {
                    return true
                }
            }
            return false
        }
        let basePath = String(url[index!...])

        return basePath
    }

}
