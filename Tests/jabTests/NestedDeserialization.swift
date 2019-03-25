//
//  NestedDeserialization.swift
//  jabTests
//
//  Created by Dino on 21/03/2019.
//

@testable import jab
import XCTest

struct Programmer: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let name: String
    let favouriteIDE: IDE
    let isDarkModeUser: Int
}

struct IDE: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let name: String
    let language: Language
}

struct Language: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let name: String
    let compileTarget: CompileTarget
    let isForGoodProgrammersOnly: Int
}

struct CompileTarget: Codable, Equatable, JSONAPIIdentifiable {
    var identifier: String
    let name: String
}

class NestedDeserialization: XCTestCase {
    lazy var bundle = Bundle(for: type(of: self))
    let jsonDecoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    lazy var jsonApiDeserializer: JSONAPIDeserializer = JSONAPIDeserializer(decoder: jsonDecoder)
    
    func testRecursiveResourceSucessfulyBreaksRecursion() {
        guard let data = loadJsonData(forResource: "programmer_ide") else {
            fatalError("Could not load JSON data")
        }
        
        XCTAssertNoThrow(try jsonApiDeserializer.deserialize(data: data) as Programmer)
    }
    
    func testRecursiveResourceSucessfulyLoadsProps() {
        guard let data = loadJsonData(forResource: "programmer_ide") else {
            fatalError("Could not load JSON data")
        }
        
        guard let programmer = try? jsonApiDeserializer.deserialize(data: data) as Programmer else {
            XCTAssertTrue(false, "could not decode Programmer")
            return
        }
        let expectedCompileTarget = CompileTarget(identifier: "1", name: "x86_64")
        let expectedLanguage = Language(identifier: "1", name: "Swift", compileTarget: expectedCompileTarget, isForGoodProgrammersOnly: 1)
        let expectedIDE = IDE(identifier: "1", name: "Xcode", language: expectedLanguage)
        let expectedProgrammer = Programmer(identifier: "1", name: "Dino", favouriteIDE: expectedIDE, isDarkModeUser: 1)
        
        XCTAssertEqual(programmer, expectedProgrammer)
    }
    
    private func loadJsonData(forResource resource: String) -> Data? {
        guard let rootJsonURL = bundle.url(forResource: resource, withExtension: "json"),
            let rootJson = try? String(contentsOf: rootJsonURL),
            let data = rootJson.data(using: .utf8)
            else { return nil }
        
        return data
    }

}
