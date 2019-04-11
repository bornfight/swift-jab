//
//  NestedRecursiveDeserialization.swift
//  jabTests
//
//  Created by Dino on 25/03/2019.
//

@testable import jab
import XCTest

fileprivate struct Programmer: Codable, Equatable, JSONAPIIdentifiable {
    static var jsonTypeIdentifier: String {
        return "programmers"
    }
    
    var identifier: String
    let name: String
    let favouriteIDE: IDE
    let isDarkModeUser: Int
}

fileprivate struct IDE: Codable, Equatable, JSONAPIIdentifiable {
    static var jsonTypeIdentifier: String {
        return "ides"
    }
    
    var identifier: String
    let name: String
    let language: Language
}

fileprivate struct Language: Codable, Equatable, JSONAPIIdentifiable {
    static var jsonTypeIdentifier: String {
        return "languages"
    }
    
    var identifier: String
    let name: String
    let compileTarget: CompileTarget
    let isForGoodProgrammersOnly: Int
    let users: [Programmer]
}

fileprivate struct CompileTarget: Codable, Equatable, JSONAPIIdentifiable {
    static var jsonTypeIdentifier: String {
        return "targets"
    }
    
    var identifier: String
    let name: String
}

class NestedRecursiveDeserialization: XCTestCase {
    lazy var bundle = Bundle(for: type(of: self))
    let jsonDecoder = { () -> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    lazy var jsonApiDeserializer: JSONAPIDeserializer = JSONAPIDeserializer(decoder: jsonDecoder)
    
    func testNestedRecursiveResourceSucessfulyBreaksRecursion() {
        guard let data = loadJsonData(forResource: "programmer_ide_language") else {
            fatalError("Could not load JSON data")
        }
        _ = try? jsonApiDeserializer.deserialize(data: data) as Programmer
        XCTAssertNoThrow(try jsonApiDeserializer.deserialize(data: data) as Programmer)
    }
    
    func testNestedRecursiveResourceSucessfulyLoadsProps() {
        guard let data = loadJsonData(forResource: "programmer_ide_language") else {
            fatalError("Could not load JSON data")
        }
        
        guard let programmer = try? jsonApiDeserializer.deserialize(data: data) as Programmer else {
            XCTAssertTrue(false, "could not decode Programmer")
            return
        }
        
        let expectedCompileTarget = CompileTarget(identifier: "1", name: "x86_64")
        let expectedLanguage = Language(identifier: "1", name: "Swift", compileTarget: expectedCompileTarget, isForGoodProgrammersOnly: 1, users: [])
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
