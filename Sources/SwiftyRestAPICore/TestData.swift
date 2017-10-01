//
//  TestData.swift
//  SwiftyRestAPIPackageDescription
//
//  Created by Daniel Lozano Valdés on 9/30/17.
//

import Foundation

struct Person: Codable {

    let firstName: String
    let lastName: String
    let age: Int
    let height: Double
    let isAdult: Bool

    static var testPerson: Person {
        return Person(firstName: "Daniel", lastName: "Lozano", age: 28, height: 1.80, isAdult: true)
    }

}
