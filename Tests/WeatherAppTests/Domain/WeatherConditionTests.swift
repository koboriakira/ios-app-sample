import XCTest
@testable import WeatherApp

final class WeatherConditionTests: XCTestCase {

    // MARK: - from(telop:) Tests

    func testFromTelop_sunny() {
        let condition = WeatherCondition.from(telop: "晴れ")
        XCTAssertEqual(condition, .sunny)
    }

    func testFromTelop_cloudy() {
        let condition = WeatherCondition.from(telop: "曇り")
        XCTAssertEqual(condition, .cloudy)
    }

    func testFromTelop_rainy() {
        let condition = WeatherCondition.from(telop: "雨")
        XCTAssertEqual(condition, .rainy)
    }

    func testFromTelop_snowy() {
        let condition = WeatherCondition.from(telop: "雪")
        XCTAssertEqual(condition, .snowy)
    }

    func testFromTelop_sunnyToCloudy() {
        let condition = WeatherCondition.from(telop: "晴のち曇")
        XCTAssertEqual(condition, .sunnyToCloudy)
    }

    func testFromTelop_sunnyToCloudyWithSpace() {
        let condition = WeatherCondition.from(telop: "晴れ のち 曇り")
        XCTAssertEqual(condition, .sunnyToCloudy)
    }

    func testFromTelop_cloudyToSunny() {
        let condition = WeatherCondition.from(telop: "曇のち晴")
        XCTAssertEqual(condition, .cloudyToSunny)
    }

    func testFromTelop_sunnyToRainy() {
        let condition = WeatherCondition.from(telop: "晴のち雨")
        XCTAssertEqual(condition, .sunnyToRainy)
    }

    func testFromTelop_cloudyToRainy() {
        let condition = WeatherCondition.from(telop: "曇のち雨")
        XCTAssertEqual(condition, .cloudyToRainy)
    }

    func testFromTelop_unknown() {
        let condition = WeatherCondition.from(telop: "特殊な天気")
        XCTAssertEqual(condition, .unknown("特殊な天気"))
    }

    func testFromTelop_snowyPriority() {
        // 雪が含まれていれば雪を優先
        let condition = WeatherCondition.from(telop: "曇時々雪")
        XCTAssertEqual(condition, .snowy)
    }

    // MARK: - Emoji Tests

    func testEmoji_sunny() {
        XCTAssertEqual(WeatherCondition.sunny.emoji, "☀️")
    }

    func testEmoji_cloudy() {
        XCTAssertEqual(WeatherCondition.cloudy.emoji, "☁️")
    }

    func testEmoji_rainy() {
        XCTAssertEqual(WeatherCondition.rainy.emoji, "🌧️")
    }

    func testEmoji_snowy() {
        XCTAssertEqual(WeatherCondition.snowy.emoji, "❄️")
    }

    // MARK: - Description Tests

    func testDescription_sunny() {
        XCTAssertEqual(WeatherCondition.sunny.description, "晴れ")
    }

    func testDescription_unknown() {
        let condition = WeatherCondition.unknown("カスタム天気")
        XCTAssertEqual(condition.description, "カスタム天気")
    }
}
