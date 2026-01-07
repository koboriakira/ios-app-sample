import XCTest
@testable import WeatherApp

@MainActor
final class WeatherViewModelTests: XCTestCase {
    private var sut: WeatherViewModel!
    private var mockUseCase: MockFetchWeatherUseCase!

    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchWeatherUseCase()
        sut = WeatherViewModel(fetchWeatherUseCase: mockUseCase)
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_isIdle() {
        XCTAssertEqual(sut.state, .idle)
    }

    func testInitialCityCode_isTokyo() {
        XCTAssertEqual(sut.selectedCityCode, "130010")
    }

    func testAvailableCities_isNotEmpty() {
        XCTAssertFalse(sut.availableCities.isEmpty)
    }

    func testAvailableCities_containsTokyo() {
        let tokyo = sut.availableCities.first { $0.code == "130010" }
        XCTAssertNotNil(tokyo)
        XCTAssertEqual(tokyo?.name, "東京")
    }

    // MARK: - fetchWeather Tests

    func testFetchWeather_setsStateToLoading() async {
        // Given
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)
        mockUseCase.delay = 100_000_000 // 0.1秒の遅延

        // When
        let task = Task {
            await sut.fetchWeather()
        }

        // 少し待ってからチェック
        try? await Task.sleep(nanoseconds: 10_000_000)

        // Then
        XCTAssertEqual(sut.state, .loading)

        await task.value
    }

    func testFetchWeather_success_setsStateToLoaded() async {
        // Given
        let expectedWeather = TestFixtures.sampleWeather
        mockUseCase.stubbedResult = .success(expectedWeather)

        // When
        await sut.fetchWeather()

        // Then
        XCTAssertEqual(sut.state, .loaded(expectedWeather))
    }

    func testFetchWeather_success_weatherPropertyReturnsData() async {
        // Given
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)

        // When
        await sut.fetchWeather()

        // Then
        XCTAssertNotNil(sut.weather)
        XCTAssertEqual(sut.weather?.location.city, "東京")
    }

    func testFetchWeather_callsUseCaseWithSelectedCityCode() async {
        // Given
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)
        sut.selectedCityCode = "270000"

        // When
        await sut.fetchWeather()

        // Then
        XCTAssertEqual(mockUseCase.executeCallCount, 1)
        XCTAssertEqual(mockUseCase.lastRequestedCityCode, "270000")
    }

    func testFetchWeather_error_setsStateToError() async {
        // Given
        mockUseCase.stubbedResult = .failure(.networkError("Connection failed"))

        // When
        await sut.fetchWeather()

        // Then
        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("ネットワークエラー"))
        } else {
            XCTFail("Expected error state")
        }
    }

    func testFetchWeather_error_errorMessageReturnsMessage() async {
        // Given
        mockUseCase.stubbedResult = .failure(.networkError("Connection failed"))

        // When
        await sut.fetchWeather()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.errorMessage?.contains("ネットワークエラー") ?? false)
    }

    // MARK: - changeCity Tests

    func testChangeCity_updatesCityCode() async {
        // Given
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)

        // When
        await sut.changeCity(to: "270000")

        // Then
        XCTAssertEqual(sut.selectedCityCode, "270000")
    }

    func testChangeCity_fetchesWeatherWithNewCity() async {
        // Given
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)

        // When
        await sut.changeCity(to: "270000")

        // Then
        XCTAssertEqual(mockUseCase.lastRequestedCityCode, "270000")
    }

    // MARK: - Computed Properties Tests

    func testWeather_whenNotLoaded_returnsNil() {
        XCTAssertNil(sut.weather)
    }

    func testErrorMessage_whenNotError_returnsNil() {
        XCTAssertNil(sut.errorMessage)
    }

    func testIsLoading_whenIdle_returnsFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func testIsLoading_whenLoading_returnsTrue() async {
        // Given
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)
        mockUseCase.delay = 100_000_000

        // When
        let task = Task {
            await sut.fetchWeather()
        }

        try? await Task.sleep(nanoseconds: 10_000_000)

        // Then
        XCTAssertTrue(sut.isLoading)

        await task.value
    }

    func testIsLoading_whenLoaded_returnsFalse() async {
        // Given
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)

        // When
        await sut.fetchWeather()

        // Then
        XCTAssertFalse(sut.isLoading)
    }
}
