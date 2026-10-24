import XCTest
@testable import Gondar

final class GondarTests: XCTestCase {
    func testMixpanelPropertiesPreserveValueTypes() throws {
        let parameters: [String: ParameterValueType] = [
            "name": .string("game"), "count": .int(3),
            "score": .double(2.5), "completed": .bool(true)
        ]
        let properties = try XCTUnwrap(parameters.typeMixpanelProperties)
        XCTAssertEqual(properties.count, 4)
        XCTAssertEqual(properties["name"] as? String, "game")
        XCTAssertEqual(properties["count"] as? Int, 3)
        XCTAssertEqual(properties["score"] as? Double, 2.5)
        XCTAssertEqual(properties["completed"] as? Bool, true)
    }

    func testOptionalMixpanelPropertiesOmitMissingValues() throws {
        let parameters: [String: ParameterValueType?] = [
            "name": .string("game"), "count": .int(3),
            "score": .double(2.5), "completed": .bool(false), "missing": nil
        ]
        let properties = try XCTUnwrap(parameters.typeMixpanelProperties)
        XCTAssertEqual(properties.count, 4)
        XCTAssertNil(properties["missing"])
        XCTAssertEqual(properties["name"] as? String, "game")
        XCTAssertEqual(properties["count"] as? Int, 3)
        XCTAssertEqual(properties["score"] as? Double, 2.5)
        XCTAssertEqual(properties["completed"] as? Bool, false)
    }

    func testEmptyMixpanelPropertiesAreNil() {
        XCTAssertNil([String: ParameterValueType]().typeMixpanelProperties)
        XCTAssertNil([String: ParameterValueType?]().typeMixpanelProperties)
        let parameters: [String: ParameterValueType?] = ["missing": nil]
        XCTAssertNil(parameters.typeMixpanelProperties)
    }
}
