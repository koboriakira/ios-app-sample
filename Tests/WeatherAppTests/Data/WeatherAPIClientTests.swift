import XCTest
@testable import WeatherApp

final class WeatherAPIClientTests: XCTestCase {
    private var sut: WeatherAPIClient!
    private var mockHTTPClient: MockHTTPClient!

    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
        sut = WeatherAPIClient(httpClient: mockHTTPClient)
    }

    override func tearDown() {
        sut = nil
        mockHTTPClient = nil
        super.tearDown()
    }

    // MARK: - Request Tests

    func testFetchWeather_makesCorrectRequest() async throws {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        // When
        _ = try await sut.fetchWeather(cityCode: "130010")

        // Then
        XCTAssertEqual(mockHTTPClient.requestCallCount, 1)
        XCTAssertNotNil(mockHTTPClient.lastRequest)

        let request = mockHTTPClient.lastRequest!
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertTrue(request.url?.absoluteString.contains("130010") ?? false)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    func testFetchWeather_constructsCorrectURL() async throws {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        // When
        _ = try await sut.fetchWeather(cityCode: "270000")

        // Then
        let expectedURLSuffix = "/270000"
        XCTAssertTrue(mockHTTPClient.lastRequest?.url?.absoluteString.hasSuffix(expectedURLSuffix) ?? false)
    }

    // MARK: - Success Cases

    func testFetchWeather_success_parsesResponse() async throws {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        // When
        let response = try await sut.fetchWeather(cityCode: "130010")

        // Then
        XCTAssertEqual(response.location.city, "東京")
        XCTAssertEqual(response.location.prefecture, "東京都")
        XCTAssertEqual(response.location.area, "関東")
        XCTAssertFalse(response.forecasts.isEmpty)
    }

    func testFetchWeather_success_parsesForecast() async throws {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        // When
        let response = try await sut.fetchWeather(cityCode: "130010")

        // Then
        let forecast = response.forecasts.first!
        XCTAssertEqual(forecast.dateLabel, "今日")
        XCTAssertEqual(forecast.telop, "晴れ")
    }

    // MARK: - Error Cases

    func testFetchWeather_networkError_throwsNetworkError() async {
        // Given
        let networkError = NSError(domain: "Network", code: -1009, userInfo: nil)
        mockHTTPClient.stubError(networkError)

        // When/Then
        do {
            _ = try await sut.fetchWeather(cityCode: "130010")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            if case .networkError = error {
                // Success
            } else {
                XCTFail("Expected networkError, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchWeather_serverError_throwsServerError() async {
        // Given
        mockHTTPClient.stubHTTPError(statusCode: 500)

        // When/Then
        do {
            _ = try await sut.fetchWeather(cityCode: "130010")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .serverError(500))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchWeather_404Error_throwsServerError() async {
        // Given
        mockHTTPClient.stubHTTPError(statusCode: 404)

        // When/Then
        do {
            _ = try await sut.fetchWeather(cityCode: "invalid")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            XCTAssertEqual(error, .serverError(404))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testFetchWeather_invalidJSON_throwsDecodingError() async {
        // Given
        let invalidJSON = "{ invalid json }".data(using: .utf8)!
        mockHTTPClient.stubSuccess(data: invalidJSON)

        // When/Then
        do {
            _ = try await sut.fetchWeather(cityCode: "130010")
            XCTFail("Expected error to be thrown")
        } catch let error as WeatherError {
            if case .decodingError = error {
                // Success
            } else {
                XCTFail("Expected decodingError, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Custom Base URL Tests

    func testFetchWeather_customBaseURL_usesCorrectURL() async throws {
        // Given
        let customClient = WeatherAPIClient(
            httpClient: mockHTTPClient,
            baseURL: "https://custom.api.com/weather"
        )
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        // When
        _ = try await customClient.fetchWeather(cityCode: "130010")

        // Then
        XCTAssertTrue(mockHTTPClient.lastRequest?.url?.absoluteString.starts(with: "https://custom.api.com/weather") ?? false)
    }
}
