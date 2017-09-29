//
//  RequestrModelGenerator.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/29/17.
//

import Foundation

final class RequestrModelGenerator: ModelGenerator {

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
            throw Error.castError
        }

        self.modelName = modelName
        self.json = json
    }

    // El output de aqui sera un String largo, con muchos \n que representara el archivo swift.
    // Esta clase no se preocupa por convertir ese string en un archivo y guardarlo, eso se hara en otro lado.
    // Este modulo solo toma un JSON y lo convierte en un ARCHIVO/STRING .swift (Checa Place.swift en dropbox para que veas un ejemplo de un modelo con Requestr)
    func makeModelFile() -> FileText {
        // Tendras que loopear sobre todos los key, values en el JSON dict
        // Crear un Parameter (el struct que tengo aqui arriba) para cada key, value. Que tendra:
        // El nombre del parametro (el key del dict)
        // El tipo, aqui puedes usar un SWITCH, ya que el value es un Any, y tratar de castear con todos los tipos validos en JSON (ve el JSONType) para averiguar que tipo es.
        // Y guarda el valor como un Any tambien por si se necesita despues.

        // Despues tendras un arreglo de Parameter's (El struct que hice arriba)
        // Con ese arreglo de parameteros deberias de poder crear un archivo que se parezca al que puse en dropbox, Place.swift
        // Checa tambien el link a natalie.swift que te mande para idea de como generar un string bien largo como un archivo.
        // Aunque como estamos usando Swift4 esta mas facil hacer un multiline string

        // Todo este proceso lo puedes separar en 2-3 pasos/metodos ... y ya en este metodo, que tienes que implementar, segun el protocolo, ya regresar el STRING final ...
        // No te preocupes por crear el archivo, ese se crea en otro lado.
        var text = ""
        text += ""
        text += ""
        return text
    }

}

extension RequestrModelGenerator {

    enum Error: Swift.Error {
        case castError
    }

}
