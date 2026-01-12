import XCTest
import WeatherCore

final class WeatherModelTests: XCTestCase {

    // MARK: - Weather Tests

    func testWeather_initialization() {
        let location = Location(area: "関東", prefecture: "東京都", city: "東京")
        let weather = Weather(
            location: location,
            description: "晴れ",
            forecasts: []
        )

        XCTAssertEqual(weather.location.city, "東京")
        XCTAssertEqual(weather.description, "晴れ")
        XCTAssertTrue(weather.forecasts.isEmpty)
    }

    func testWeather_equatable() {
        let weather1 = TestFixtures.sampleWeather
        let weather2 = TestFixtures.sampleWeather
        let weather3 = TestFixtures.emptyWeather

        XCTAssertEqual(weather1, weather2)
        XCTAssertNotEqual(weather1, weather3)
    }

    // MARK: - Location Tests

    func testLocation_initialization() {
        let location = Location(area: "関東", prefecture: "東京都", city: "東京")

        XCTAssertEqual(location.area, "関東")
        XCTAssertEqual(location.prefecture, "東京都")
        XCTAssertEqual(location.city, "東京")
    }

    // MARK: - DailyForecast Tests

    func testDailyForecast_id() {
        let forecast = DailyForecast(
            date: "2026-01-07",
            dateLabel: "今日",
            telop: "晴れ",
            telopDescription: .sunny,
            temperature: Temperature(min: nil, max: nil),
            chanceOfRain: ChanceOfRain(t00_06: "0%", t06_12: "0%", t12_18: "0%", t18_24: "0%"),
            imageUrl: nil
        )

        XCTAssertEqual(forecast.id, "2026-01-07")
    }

    // MARK: - Temperature Tests

    func testTemperatureValue_displayCelsius() {
        let temp = TemperatureValue(celsius: "25", fahrenheit: "77")
        XCTAssertEqual(temp.displayCelsius, "25°C")
    }

    func testTemperature_withBothValues() {
        let min = TemperatureValue(celsius: "5", fahrenheit: "41")
        let max = TemperatureValue(celsius: "12", fahrenheit: "54")
        let temp = Temperature(min: min, max: max)

        XCTAssertEqual(temp.min?.celsius, "5")
        XCTAssertEqual(temp.max?.celsius, "12")
    }

    func testTemperature_withNilValues() {
        let temp = Temperature(min: nil, max: nil)

        XCTAssertNil(temp.min)
        XCTAssertNil(temp.max)
    }

    // MARK: - ChanceOfRain Tests

    func testChanceOfRain_periods() {
        let rain = ChanceOfRain(
            t00_06: "10%",
            t06_12: "20%",
            t12_18: "30%",
            t18_24: "40%"
        )

        let periods = rain.periods
        XCTAssertEqual(periods.count, 4)
        XCTAssertEqual(periods[0].label, "0-6時")
        XCTAssertEqual(periods[0].value, "10%")
        XCTAssertEqual(periods[1].label, "6-12時")
        XCTAssertEqual(periods[1].value, "20%")
        XCTAssertEqual(periods[2].label, "12-18時")
        XCTAssertEqual(periods[2].value, "30%")
        XCTAssertEqual(periods[3].label, "18-24時")
        XCTAssertEqual(periods[3].value, "40%")
    }
}
