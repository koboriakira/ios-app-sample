import XCTest
import WeatherCore

final class WeatherErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func testNetworkError_hasCorrectDescription() {
        let error = WeatherError.networkError("Connection timeout")
        XCTAssertEqual(error.errorDescription, "ネットワークエラー: Connection timeout")
    }

    func testDecodingError_hasCorrectDescription() {
        let error = WeatherError.decodingError("Invalid JSON format")
        XCTAssertEqual(error.errorDescription, "データ解析エラー: Invalid JSON format")
    }

    func testInvalidCityCode_hasCorrectDescription() {
        let error = WeatherError.invalidCityCode
        XCTAssertEqual(error.errorDescription, "無効な都市コードです")
    }

    func testServerError_hasCorrectDescription() {
        let error = WeatherError.serverError(500)
        XCTAssertEqual(error.errorDescription, "サーバーエラー (コード: 500)")
    }

    func testUnknownError_hasCorrectDescription() {
        let error = WeatherError.unknown("Something went wrong")
        XCTAssertEqual(error.errorDescription, "不明なエラー: Something went wrong")
    }

    // MARK: - Equatable Tests

    func testNetworkError_equality() {
        let error1 = WeatherError.networkError("Test")
        let error2 = WeatherError.networkError("Test")
        let error3 = WeatherError.networkError("Different")

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testServerError_equality() {
        let error1 = WeatherError.serverError(500)
        let error2 = WeatherError.serverError(500)
        let error3 = WeatherError.serverError(404)

        XCTAssertEqual(error1, error2)
        XCTAssertNotEqual(error1, error3)
    }

    func testDifferentErrorTypes_notEqual() {
        let networkError = WeatherError.networkError("Test")
        let decodingError = WeatherError.decodingError("Test")

        XCTAssertNotEqual(networkError, decodingError)
    }
}
