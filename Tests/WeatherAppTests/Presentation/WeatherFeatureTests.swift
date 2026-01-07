import ComposableArchitecture
import XCTest
@testable import WeatherApp

@MainActor
final class WeatherFeatureTests: XCTestCase {
    // MARK: - Initial State Tests

    func testInitialState() {
        let state = WeatherFeature.State()

        XCTAssertEqual(state.selectedCityCode, "130010")
        XCTAssertNil(state.weather)
        XCTAssertFalse(state.isLoading)
        XCTAssertNil(state.errorMessage)
    }

    func testAvailableCities_containsTokyo() {
        let tokyo = WeatherFeature.State.availableCities.first { $0.code == "130010" }
        XCTAssertNotNil(tokyo)
        XCTAssertEqual(tokyo?.name, "東京")
    }

    func testAvailableCities_isNotEmpty() {
        XCTAssertFalse(WeatherFeature.State.availableCities.isEmpty)
    }

    // MARK: - OnAppear Tests

    func testOnAppear_fetchesWeatherSuccessfully() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in TestFixtures.sampleWeather }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.success) {
            $0.weather = TestFixtures.sampleWeather
        }
    }

    func testOnAppear_handlesError() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in
                throw WeatherError.networkError("Connection failed")
            }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.failure) {
            $0.errorMessage = "ネットワークエラー: Connection failed"
        }
    }

    // MARK: - City Selection Tests

    func testCitySelected_updatesSelectedCityCode() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in TestFixtures.sampleWeather }
        }

        await store.send(.citySelected("270000")) {
            $0.selectedCityCode = "270000"
        }
        await store.receive(\.weatherResponse.success) {
            $0.weather = TestFixtures.sampleWeather
        }
    }

    func testCitySelected_fetchesWeatherWithNewCity() async {
        var requestedCityCode: String?
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { cityCode in
                requestedCityCode = cityCode
                return TestFixtures.sampleWeather
            }
        }

        await store.send(.citySelected("270000")) {
            $0.selectedCityCode = "270000"
        }
        await store.receive(\.weatherResponse.success) {
            $0.weather = TestFixtures.sampleWeather
        }

        XCTAssertEqual(requestedCityCode, "270000")
    }

    // MARK: - Refresh Button Tests

    func testRefreshButtonTapped_fetchesWeather() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in TestFixtures.sampleWeather }
        }

        await store.send(.refreshButtonTapped)
        await store.receive(\.weatherResponse.success) {
            $0.weather = TestFixtures.sampleWeather
        }
    }

    func testRefreshButtonTapped_usesCurrentCityCode() async {
        var requestedCityCode: String?
        let store = TestStore(
            initialState: WeatherFeature.State(selectedCityCode: "270000")
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { cityCode in
                requestedCityCode = cityCode
                return TestFixtures.sampleWeather
            }
        }

        await store.send(.refreshButtonTapped)
        await store.receive(\.weatherResponse.success) {
            $0.weather = TestFixtures.sampleWeather
        }

        XCTAssertEqual(requestedCityCode, "270000")
    }

    // MARK: - Weather Response Tests

    func testWeatherResponseSuccess_clearsError() async {
        let store = TestStore(
            initialState: WeatherFeature.State(errorMessage: "Previous error")
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in TestFixtures.sampleWeather }
        }

        await store.send(.refreshButtonTapped)
        await store.receive(\.weatherResponse.success) {
            $0.weather = TestFixtures.sampleWeather
            $0.errorMessage = nil
        }
    }

    func testWeatherResponseFailure_setsErrorMessage() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in
                throw WeatherError.serverError(500)
            }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.failure) {
            $0.errorMessage = "サーバーエラー (500)"
        }
    }

    // MARK: - Error Types Tests

    func testNetworkError_displaysCorrectMessage() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in
                throw WeatherError.networkError("Timeout")
            }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.failure) {
            $0.errorMessage = "ネットワークエラー: Timeout"
        }
    }

    func testInvalidCityCodeError_displaysCorrectMessage() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in
                throw WeatherError.invalidCityCode
            }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.failure) {
            $0.errorMessage = "無効な都市コードです"
        }
    }

    func testDecodingError_displaysCorrectMessage() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in
                throw WeatherError.decodingError("Invalid JSON")
            }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.failure) {
            $0.errorMessage = "データの解析に失敗しました: Invalid JSON"
        }
    }
}
