import ComposableArchitecture
import XCTest
@testable import WeatherApp

/// 統合テスト: 複数レイヤーを跨いだテスト
/// 実際のAPIは呼ばず、モックHTTPClientを使用してE2Eに近いテストを実現
final class WeatherIntegrationTests: XCTestCase {
    private var mockHTTPClient: MockHTTPClient!

    override func setUp() {
        super.setUp()
        mockHTTPClient = MockHTTPClient()
    }

    override func tearDown() {
        mockHTTPClient = nil
        super.tearDown()
    }

    // MARK: - Full Flow Integration Tests

    /// APIClient -> Repository -> UseCase の統合テスト
    func testFullFlow_fetchWeather_success() async throws {
        // Given: モックHTTPClientにAPIレスポンスを設定
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        // 実際の依存関係チェーンを構築
        let apiClient = WeatherAPIClient(httpClient: mockHTTPClient)
        let repository = WeatherRepository(apiClient: apiClient)
        let useCase = FetchWeatherUseCase(repository: repository)

        // When: ユースケースを実行
        let weather = try await useCase.execute(cityCode: "130010")

        // Then: 正しくドメインモデルに変換されている
        XCTAssertEqual(weather.location.city, "東京")
        XCTAssertEqual(weather.location.prefecture, "東京都")
        XCTAssertFalse(weather.forecasts.isEmpty)

        let forecast = weather.forecasts.first!
        XCTAssertEqual(forecast.telop, "晴れ")
        XCTAssertEqual(forecast.telopDescription, .sunny)
    }

    /// エラーケースの統合テスト
    func testFullFlow_networkError_propagatesToUseCase() async {
        // Given
        let networkError = NSError(domain: NSURLErrorDomain, code: -1009)
        mockHTTPClient.stubError(networkError)

        let apiClient = WeatherAPIClient(httpClient: mockHTTPClient)
        let repository = WeatherRepository(apiClient: apiClient)
        let useCase = FetchWeatherUseCase(repository: repository)

        // When/Then
        do {
            _ = try await useCase.execute(cityCode: "130010")
            XCTFail("Expected error")
        } catch let error as WeatherError {
            if case .networkError = error {
                // Success: エラーが正しく伝播
            } else {
                XCTFail("Expected networkError, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - TCA Feature Integration Tests

    /// WeatherFeature統合テスト
    @MainActor
    func testWeatherFeature_fetchWeather_updatesState() async {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        let apiClient = WeatherAPIClient(httpClient: mockHTTPClient)

        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { cityCode in
                let response = try await apiClient.fetchWeather(cityCode: cityCode)
                return response.toDomain()
            }
        }

        // When
        await store.send(.onAppear)

        // Then
        await store.receive(\.weatherResponse.success) {
            $0.weather = Weather(
                location: Location(area: "関東", prefecture: "東京都", city: "東京"),
                description: "関東甲信地方は高気圧に緩やかに覆われています。",
                forecasts: [
                    DailyForecast(
                        date: "2026-01-07",
                        dateLabel: "今日",
                        telop: "晴れ",
                        telopDescription: .sunny,
                        temperature: Temperature(
                            min: TemperatureValue(celsius: "5", fahrenheit: "41"),
                            max: TemperatureValue(celsius: "12", fahrenheit: "54")
                        ),
                        chanceOfRain: ChanceOfRain(
                            t00_06: "10%",
                            t06_12: "20%",
                            t12_18: "10%",
                            t18_24: "10%"
                        ),
                        imageUrl: URL(string: "https://www.jma.go.jp/bosai/forecast/img/100.svg")
                    )
                ]
            )
        }
    }

    /// 都市変更の統合テスト
    @MainActor
    func testWeatherFeature_changeCity_fetchesNewWeather() async {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        let apiClient = WeatherAPIClient(httpClient: mockHTTPClient)

        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { cityCode in
                let response = try await apiClient.fetchWeather(cityCode: cityCode)
                return response.toDomain()
            }
        }

        // When
        await store.send(.citySelected("270000")) {
            $0.selectedCityCode = "270000"
        }

        // Then
        await store.receive(\.weatherResponse.success) {
            $0.weather = Weather(
                location: Location(area: "関東", prefecture: "東京都", city: "東京"),
                description: "関東甲信地方は高気圧に緩やかに覆われています。",
                forecasts: [
                    DailyForecast(
                        date: "2026-01-07",
                        dateLabel: "今日",
                        telop: "晴れ",
                        telopDescription: .sunny,
                        temperature: Temperature(
                            min: TemperatureValue(celsius: "5", fahrenheit: "41"),
                            max: TemperatureValue(celsius: "12", fahrenheit: "54")
                        ),
                        chanceOfRain: ChanceOfRain(
                            t00_06: "10%",
                            t06_12: "20%",
                            t12_18: "10%",
                            t18_24: "10%"
                        ),
                        imageUrl: URL(string: "https://www.jma.go.jp/bosai/forecast/img/100.svg")
                    )
                ]
            )
        }

        XCTAssertEqual(mockHTTPClient.requestCallCount, 1)

        // URLに正しい都市コードが含まれている
        let requestURL = mockHTTPClient.lastRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(requestURL.contains("270000"))
    }
}
