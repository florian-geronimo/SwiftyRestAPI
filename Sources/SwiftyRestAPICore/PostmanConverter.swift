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
      let name = jsonCategory["name"] as! String
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
        
        let relativePath = request["url"] as! String
        endpoints.append(API.Endpoint(name: dictPostmanEndpoint["name"] as! String,
                                  resourceName: dictPostmanEndpoint["name"] as! String ,
                                  isResourceArray: false,
                                  method: method,
                                  relativePath:relativePath,
                                  urlParameters:[]))
    }
    
    return endpoints

  }

}
