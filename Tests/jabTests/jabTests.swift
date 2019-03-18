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

class Car: Codable {
    let color: String
    let topSpeed: Int
    let isGood: Int
    let key: Key
}

class Key: Codable {
    let isWireless: Int
    let hasKeychain: Int
    let name: String
}

final class jabTests: XCTestCase {
    lazy var bundle = Bundle(for: type(of: self))
    let jsonDecoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    lazy var jsonApiDeserializer = JSONAPIDeserializer(decoder: jsonDecoder)
    
    func testResourceCollectionHavingSomeIncludedData() {
        guard let data = loadJsonData(forResource: "cars_keys", withExtension: "json") else {
            fatalError("Could not load JSON data")
        }
        
        do {
            let deserialized: Paginated<Car> = try jsonApiDeserializer.deserializeCollection(data: data)
            XCTAssertTrue(true)
        } catch {
            XCTAssertTrue(false, "error deserializing: \(error.localizedDescription)")
        }
    }
    
    func testResourceSingleHavingSomeIncludedData() {
        
    }
    
    private func loadJsonData(forResource resource: String, withExtension extension: String) -> Data? {
        guard let rootJsonURL = bundle.url(forResource: "cars_keys", withExtension: "json"),
              let rootJson = try? String(contentsOf: rootJsonURL),
              let data = rootJson.data(using: .utf8)
        else { return nil }
        
        return data
    }

    static var allTests = [
        ("testExample", testResourceCollectionHavingSomeIncludedData),
    ]
}
