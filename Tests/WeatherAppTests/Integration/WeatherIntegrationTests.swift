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

    /// ViewModel統合テスト
    @MainActor
    func testViewModelIntegration_fetchWeather_updatesState() async {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        let apiClient = WeatherAPIClient(httpClient: mockHTTPClient)
        let repository = WeatherRepository(apiClient: apiClient)
        let useCase = FetchWeatherUseCase(repository: repository)
        let viewModel = WeatherViewModel(fetchWeatherUseCase: useCase)

        // When
        await viewModel.fetchWeather()

        // Then
        XCTAssertNotNil(viewModel.weather)
        XCTAssertEqual(viewModel.weather?.location.city, "東京")
        XCTAssertFalse(viewModel.isLoading)

        if case .loaded(let weather) = viewModel.state {
            XCTAssertEqual(weather.forecasts.first?.telop, "晴れ")
        } else {
            XCTFail("Expected loaded state")
        }
    }

    /// 都市変更の統合テスト
    @MainActor
    func testViewModelIntegration_changeCity_fetchesNewWeather() async {
        // Given
        mockHTTPClient.stubSuccess(data: TestFixtures.sampleAPIResponseData)

        let apiClient = WeatherAPIClient(httpClient: mockHTTPClient)
        let repository = WeatherRepository(apiClient: apiClient)
        let useCase = FetchWeatherUseCase(repository: repository)
        let viewModel = WeatherViewModel(fetchWeatherUseCase: useCase)

        // When
        await viewModel.changeCity(to: "270000")

        // Then
        XCTAssertEqual(viewModel.selectedCityCode, "270000")
        XCTAssertEqual(mockHTTPClient.requestCallCount, 1)

        // URLに正しい都市コードが含まれている
        let requestURL = mockHTTPClient.lastRequest?.url?.absoluteString ?? ""
        XCTAssertTrue(requestURL.contains("270000"))
    }
}
