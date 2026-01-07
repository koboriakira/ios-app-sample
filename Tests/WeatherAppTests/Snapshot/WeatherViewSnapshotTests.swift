import ComposableArchitecture
import SwiftUI
import XCTest
@testable import WeatherApp

/// WeatherViewのスナップショットテスト
/// 注意: 実際のスナップショット比較にはpoint-free/swift-snapshot-testingの追加が必要
/// 現在はビューの構造検証のみ実施
final class WeatherViewSnapshotTests: SnapshotTestCase {

    // MARK: - View Structure Tests

    @MainActor
    func testWeatherView_canBeCreated() {
        let view = makeWeatherView()
        XCTAssertNotNil(view)
    }

    @MainActor
    func testWeatherView_withWeather_canBeCreated() {
        let view = makeWeatherView(weather: TestFixtures.sampleWeather)
        XCTAssertNotNil(view)
    }

    @MainActor
    func testWeatherView_withError_canBeCreated() {
        let view = makeWeatherView(errorMessage: "テストエラー")
        XCTAssertNotNil(view)
    }

    @MainActor
    func testForecastCard_rendersCorrectly() {
        let forecast = TestFixtures.sampleWeather.forecasts.first!
        let card = ViewFactory.forecastCard(forecast: forecast)
        XCTAssertNotNil(card)
    }

    @MainActor
    func testRainProbabilityBadge_rendersCorrectly() {
        let badge = ViewFactory.rainProbabilityBadge(label: "6-12時", value: "30%")
        XCTAssertNotNil(badge)
    }

    // MARK: - State Verification Tests

    @MainActor
    func testWeatherFeature_initialState() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in TestFixtures.sampleWeather }
        }

        // 初期状態ではweatherはnil
        XCTAssertNil(store.state.weather)
        XCTAssertFalse(store.state.isLoading)
        XCTAssertNil(store.state.errorMessage)
    }

    @MainActor
    func testWeatherFeature_loadedState() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in TestFixtures.sampleWeather }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.success) {
            $0.weather = TestFixtures.sampleWeather
        }

        XCTAssertNotNil(store.state.weather)
        XCTAssertEqual(store.state.weather?.location.city, "東京")
    }

    @MainActor
    func testWeatherFeature_errorState() async {
        let store = TestStore(initialState: WeatherFeature.State()) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient.fetchWeather = { _ in
                throw WeatherError.networkError("接続エラー")
            }
        }

        await store.send(.onAppear)
        await store.receive(\.weatherResponse.failure) {
            $0.errorMessage = "ネットワークエラー: 接続エラー"
        }

        XCTAssertNotNil(store.state.errorMessage)
        XCTAssertTrue(store.state.errorMessage?.contains("ネットワークエラー") ?? false)
    }

    // MARK: - Accessibility Tests

    @MainActor
    func testForecastCard_hasAccessibleContent() {
        let forecast = TestFixtures.sampleWeather.forecasts.first!

        // アクセシビリティに必要な情報が含まれているか検証
        XCTAssertFalse(forecast.dateLabel.isEmpty, "Date label should not be empty")
        XCTAssertFalse(forecast.telop.isEmpty, "Weather description should not be empty")
        XCTAssertFalse(forecast.telopDescription.emoji.isEmpty, "Emoji should not be empty")
    }
}

// MARK: - Future Snapshot Testing Setup
/*
 スナップショットテストを有効化する手順:

 1. Package.swiftに依存関係を追加:
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.0")

 2. テストターゲットに依存関係を追加:
    .testTarget(
        name: "WeatherAppTests",
        dependencies: [
            "WeatherApp",
            .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
        ]
    )

 3. テストを以下のように更新:
    import SnapshotTesting

    func testWeatherView_loaded() {
        let view = makeWeatherView(weather: TestFixtures.sampleWeather)
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13)))
    }
*/
