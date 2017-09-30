//
//  TestData.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/30/17.
//

import Foundation

struct Person: Codable {

    let name: String
    let age: Int
    let height: Double
    let isAdult: Bool

    static var testPerson: Person {
        return Person(name: "Daniel Lozano", age: 28, height: 1.80, isAdult: true)
    }

}
