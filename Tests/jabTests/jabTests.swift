import XCTest
@testable import jab

final class jabTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(jab().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
