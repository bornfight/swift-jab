//
//  RecursiveDeserialization.swift
//  jabTests
//
//  Created by Dino on 21/03/2019.
//

@testable import jab
import XCTest

class Person: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let name: String
    let age: Int
    let card: CreditCard
    
    init(identifier: String, name: String, age: Int, card: CreditCard) {
        self.identifier = identifier
        self.name = name
        self.age = age
        self.card = card
    }
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.identifier == rhs.identifier &&
            lhs.name == rhs.name &&
            lhs.age == rhs.age
    }
}

class CreditCard: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let bankName: String
    let expiryDate: String
    weak var owner: Person?
    
    init(identifier: String, bankName: String, expiryDate: String, owner: Person?) {
        self.identifier = identifier
        self.bankName = bankName
        self.expiryDate = expiryDate
        self.owner = owner
    }
    
    static func == (lhs: CreditCard, rhs: CreditCard) -> Bool {
        return lhs.bankName == rhs.bankName &&
            lhs.expiryDate == rhs.expiryDate &&
            lhs.identifier == rhs.identifier
    }
}

class RecursiveDeserialization: XCTestCase {
    lazy var bundle = Bundle(for: type(of: self))
    let jsonDecoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    lazy var jsonApiDeserializer: JSONAPIDeserializer = {
        let deserializer = JSONAPIDeserializer(decoder: jsonDecoder)
        deserializer.flatteningStrategy = .handleRecursiveCases
        return deserializer
    }()
    
    func testRecursiveResourceSucessfulyBreaksRecursion() {
        guard let data = loadJsonData(forResource: "person_card_single") else {
            fatalError("Could not load JSON data")
        }
        
        XCTAssertNoThrow(try jsonApiDeserializer.deserialize(data: data) as Person)
    }

    func testRecursiveResourceSucessfulyLoadsProps() {
        guard let data = loadJsonData(forResource: "person_card_single") else {
            fatalError("Could not load JSON data")
        }
        
        guard let person = try? jsonApiDeserializer.deserialize(data: data) as Person else {
            XCTAssertTrue(false, "Could not decode Person")
            return
        }
        let expectedCard = CreditCard(identifier: "2", bankName: "Honduras", expiryDate: "09/2024", owner: nil)
        let expectedOwner = Person(identifier: "1", name: "Franjo", age: 97, card: expectedCard)
        
        XCTAssertEqual(person, expectedOwner)
    }

    private func loadJsonData(forResource resource: String) -> Data? {
        guard let rootJsonURL = bundle.url(forResource: resource, withExtension: "json"),
              let rootJson = try? String(contentsOf: rootJsonURL),
              let data = rootJson.data(using: .utf8)
        else { return nil }
        
        return data
    }
}
