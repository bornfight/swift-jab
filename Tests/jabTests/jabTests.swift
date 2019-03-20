import XCTest
@testable import jab

//     JSON SCHEMA
//
//        PERSON
//    {
//        "name": "Severina",
//        "surname": "Severinic",
//        "age": "109"
//    }
//
//        CAR
//    {
//        "color": "red",
//        "top_speed": "240",
//        "is_good": 1
//    }
//
//        KEY
//    {
//        "is_wireless": 1,
//        "has_keychain": 1,
//        "name": "Dragutin Tadijanovic"
//    }
//
//    Person -> Car is a one to many relationship
//    Car -> Person is a one to one relationship
//    Car -> Key is a one to one relationship
//    Key -> Car is a one to one relationship
//

struct Car: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let color: String
    let topSpeed: Int
    let isGood: Int
    let key: Key
    
    init(identifier: String, color: String, topSpeed: Int, isGood: Int, key: Key) {
        self.identifier = identifier
        self.color = color
        self.topSpeed = topSpeed
        self.isGood = isGood
        self.key = key
    }
}

struct Key: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let isWireless: Int
    let hasKeychain: Int
    let name: String
    
    init(identifier: String, isWireless: Int, hasKeychain: Int, name: String) {
        self.identifier = identifier
        self.isWireless = isWireless
        self.hasKeychain = hasKeychain
        self.name = name
    }
}

final class jabTests: XCTestCase {
    lazy var bundle = Bundle(for: type(of: self))
    let jsonDecoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    lazy var jsonApiDeserializer = JSONAPIDeserializer(decoder: jsonDecoder)
    
    func testResourceCollectionHavingSomeIncludedDataCanBeDeserialized() {
        guard let data = loadJsonData(forResource: "cars_keys") else {
            fatalError("Could not load JSON data")
        }
        
        XCTAssertNoThrow(try jsonApiDeserializer.deserializeCollection(data: data) as Paginated<Car>)
    }
    
    func testResourceSingleHavingSomeIncludedDataCanBeDeserialized() {
        guard let data = loadJsonData(forResource: "car_single") else {
            fatalError("Could not load JSON data")
        }
        
        XCTAssertNoThrow(try jsonApiDeserializer.deserialize(data: data) as Car)
    }
    
    func testResourceSingleHavingSomeIncludedDataHasCorrectProps() {
        guard let data = loadJsonData(forResource: "car_single") else {
            fatalError("Could not load JSON data")
        }
        
        do {
            let deserialized: Car = try jsonApiDeserializer.deserialize(data: data)
            let expectedKey = Key(identifier: "4", isWireless: 1, hasKeychain: 1, name: "Kljucevi Dragutina Tadijanovica")
            let expectedCar = Car(identifier: "1", color: "red", topSpeed: 240, isGood: 1, key: expectedKey)
            XCTAssertEqual(deserialized, expectedCar, "Deserialized car should match expected values")
        } catch {
            XCTAssertTrue(false, "Error deserializing: \(error.localizedDescription)")
        }
    }
    
    func testResourceSingleMissingIncludedDataFailsAtDecoding() {
        guard let data = loadJsonData(forResource: "car_single_missing_includes") else {
            fatalError("Could not load JSON data")
        }
        
        XCTAssertThrowsError(try jsonApiDeserializer.deserialize(data: data) as Car)
    }
    
    private func loadJsonData(forResource resource: String) -> Data? {
        guard let rootJsonURL = bundle.url(forResource: resource, withExtension: "json"),
              let rootJson = try? String(contentsOf: rootJsonURL),
              let data = rootJson.data(using: .utf8)
        else { return nil }
        
        return data
    }

    static var allTests = [
        ("testResourceCollectionHavingSomeIncludedDataCanBeDeserialized", testResourceCollectionHavingSomeIncludedDataCanBeDeserialized),
        ("testResourceSingleHavingSomeIncludedDataCanBeDeserialized", testResourceSingleHavingSomeIncludedDataCanBeDeserialized),
        ("testResourceSingleHavingSomeIncludedDataHasCorrectProps", testResourceSingleHavingSomeIncludedDataHasCorrectProps),
        ("testResourceSingleMissingIncludedDataFailsAtDecoding", testResourceSingleMissingIncludedDataFailsAtDecoding)
    ]
}
