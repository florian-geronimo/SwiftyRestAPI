//
//  RequestrModelGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

final class RequestrModelGenerator: ModelGenerator {

    enum ModelGeneratorError: Error {
        case castError
    }

    struct Parameter {
        let name: String
        let type: JSONType
        let value: Any
    }

    let modelName: String

    let json: JSONDictionary

    init(modelName: String, json: JSONDictionary) {
        self.modelName = modelName
        self.json = json
    }

    init(modelName: String, jsonData: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? JSONDictionary else {
            throw ModelGeneratorError.castError
        }

        self.modelName = modelName
        self.json = json
    }

    // El output de aqui sera un String largo, con muchos \n que representara el archivo swift.
    // Esta clase no se preocupa por convertir ese string en un archivo y guardarlo, eso se hara en otro lado.
    // Este modulo solo toma un JSON y lo convierte en un ARCHIVO/STRING .swift (Checa Place.swift en dropbox para que veas un ejemplo de un modelo con Requestr)
    func makeModelFile() -> FileText {
        var text = ""
        text += ""
        text += ""
        return text
    }

}
