//
//  Serialization.swift
//  jabTests
//
//  Created by Dino on 11/04/2019.
//

import XCTest
@testable import jab

class SerializationTests: XCTestCase {
    var serializer: JSONAPISerializer!
    
    override func setUp() {
        super.setUp()
        
        serializer = JSONAPISerializer()
    }
    
    override func tearDown() {
        super.tearDown()
        
        serializer = nil
    }
    
    func testObjectCanBeDeserialized() {
        let key = Key(identifier: "5", isWireless: 1, hasKeychain: 0, name: "Babini kljucevi")
        let car = Car(identifier: "12", color: "black", topSpeed: 252, isGood: 1, key: key)
        let serializer = JSONAPISerializer()
        
        XCTAssertNoThrow(try serializer.serialize(resource: car), "car should be able to be deserialized")
    }
    
    func testSerializedObjectCanBeDeserialized() {
        let key = Key(identifier: "5", isWireless: 1, hasKeychain: 0, name: "Babini kljucevi")
        let car = Car(identifier: "12", color: "black", topSpeed: 252, isGood: 1, key: key)
        let serializer = JSONAPISerializer()
        let deserializer = JSONAPIDeserializer()
        
        XCTAssertNoThrow(try serializer.serialize(resource: car), "car should be able to be deserialized")
        let serializedCar = try! serializer.serialize(resource: car)
        
        XCTAssertNoThrow(try deserializer.deserialize(data: serializedCar) as Car)
        let deserializedCar = try! deserializer.deserialize(data: serializedCar) as Car
        
        XCTAssertEqual(car, deserializedCar, "cars should be equal")
    }
}
