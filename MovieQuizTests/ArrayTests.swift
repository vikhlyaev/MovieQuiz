import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // When
        let array = Array(1...5)
        // Given
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() throws {
        // When
        let array = Array(1...5)
        // Given
        let value = array[safe: 20]
        // Then
        XCTAssertNil(value)
    }
}

