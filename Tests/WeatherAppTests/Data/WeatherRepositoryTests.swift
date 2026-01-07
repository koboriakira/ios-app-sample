import XCTest
@testable import WeatherApp

/// テスト用のモックAPIクライアント
final class MockWeatherAPIClient: WeatherAPIClientProtocol, @unchecked Sendable {
    var stubbedResponse: WeatherAPIResponse?
    var stubbedError: Error?
    var fetchWeatherCallCount = 0
    var lastRequestedCityCode: String?

    func fetchWeather(cityCode: String) async throws -> WeatherAPIResponse {
        fetchWeatherCallCount += 1
        lastRequestedCityCode = cityCode

        if let error = stubbedError {
            throw error
        }

        guard let response = stubbedResponse else {
            fatalError("stubbedResponse must be set")
        }

        return response
    }

    /// JSONからレスポンスを設定
    func stubWithJSON(_ json: String) throws {
        let data = json.data(using: .utf8)!
        stubbedResponse = try JSONDecoder().decode(WeatherAPIResponse.self, from: data)
    }
}

final class WeatherRepositoryTests: XCTestCase {
    private var sut: WeatherRepository!
    private var mockAPIClient: MockWeatherAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockWeatherAPIClient()
        sut = WeatherRepository(apiClient: mockAPIClient)
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        super.tearDown()
    }

    // MARK: - Success Cases

    func testFetchWeather_success_returnsDomainModel() async throws {
        // Given
        try mockAPIClient.stubWithJSON(TestFixtures.sampleAPIResponseJSON)

        // When
        let weather = try await sut.fetchWeather(cityCode: "130010")

        // Then
        XCTAssertEqual(weather.location.city, "東京")
        XCTAssertEqual(weather.location.prefecture, "東京都")
        XCTAssertEqual(weather.location.area, "関東")
    }

    func testFetchWeather_success_transformsForecasts() async throws {
        // Given
        try mockAPIClient.stubWithJSON(TestFixtures.sampleAPIResponseJSON)

        // When
        let weather = try await sut.fetchWeather(cityCode: "130010")

        // Then
        XCTAssertFalse(weather.forecasts.isEmpty)
        let forecast = weather.forecasts.first!
        XCTAssertEqual(forecast.dateLabel, "今日")
        XCTAssertEqual(forecast.telop, "晴れ")
        XCTAssertEqual(forecast.telopDescription, .sunny)
    }

    func testFetchWeather_success_transformsTemperature() async throws {
        // Given
        try mockAPIClient.stubWithJSON(TestFixtures.sampleAPIResponseJSON)

        // When
        let weather = try await sut.fetchWeather(cityCode: "130010")

        // Then
        let forecast = weather.forecasts.first!
        XCTAssertNotNil(forecast.temperature.min)
        XCTAssertNotNil(forecast.temperature.max)
        XCTAssertEqual(forecast.temperature.min?.celsius, "5")
        XCTAssertEqual(forecast.temperature.max?.celsius, "12")
    }

    func testFetchWeather_success_transformsChanceOfRain() async throws {
        // Given
        try mockAPIClient.stubWithJSON(TestFixtures.sampleAPIResponseJSON)

        // When
        let weather = try await sut.fetchWeather(cityCode: "130010")

        // Then
        let forecast = weather.forecasts.first!
        XCTAssertEqual(forecast.chanceOfRain.t00_06, "10%")
        XCTAssertEqual(forecast.chanceOfRain.t06_12, "20%")
        XCTAssertEqual(forecast.chanceOfRain.t12_18, "10%")
        XCTAssertEqual(forecast.chanceOfRain.t18_24, "10%")
    }

    func testFetchWeather_callsAPIClientWithCorrectCityCode() async throws {
        // Given
        try mockAPIClient.stubWithJSON(TestFixtures.sampleAPIResponseJSON)

        // When
        _ = try await sut.fetchWeather(cityCode: "270000")

        // Then
        XCTAssertEqual(mockAPIClient.fetchWeatherCallCount, 1)
        XCTAssertEqual(mockAPIClient.lastRequestedCityCode, "270000")
    }

    // MARK: - Error Cases

    func testFetchWeather_apiClientError_propagatesError() async {
        // Given
        mockAPIClient.stubbedError = WeatherError.networkError("Connection failed")

        // When/Then
        do {
            _ = try await sut.fetchWeather(cityCode: "130010")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .networkError("Connection failed"))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
