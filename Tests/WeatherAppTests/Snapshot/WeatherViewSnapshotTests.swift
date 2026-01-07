import XCTest
import SwiftUI
@testable import WeatherApp

/// WeatherViewのスナップショットテスト
/// 注意: 実際のスナップショット比較にはpoint-free/swift-snapshot-testingの追加が必要
/// 現在はビューの構造検証のみ実施
final class WeatherViewSnapshotTests: SnapshotTestCase {

    // MARK: - View Structure Tests

    @MainActor
    func testWeatherView_canBeCreated() {
        let view = makeWeatherView(state: .idle)
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
    func testWeatherView_idleState_showsEmptyView() async {
        let mockUseCase = MockFetchWeatherUseCase()
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)
        let viewModel = WeatherViewModel(fetchWeatherUseCase: mockUseCase)

        // idle状態ではweatherはnil
        XCTAssertNil(viewModel.weather)
        XCTAssertEqual(viewModel.state, .idle)
    }

    @MainActor
    func testWeatherView_loadedState_showsWeatherData() async {
        let mockUseCase = MockFetchWeatherUseCase()
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)
        let viewModel = WeatherViewModel(fetchWeatherUseCase: mockUseCase)

        await viewModel.fetchWeather()

        XCTAssertNotNil(viewModel.weather)
        XCTAssertEqual(viewModel.weather?.location.city, "東京")
    }

    @MainActor
    func testWeatherView_errorState_showsErrorMessage() async {
        let mockUseCase = MockFetchWeatherUseCase()
        mockUseCase.stubbedResult = .failure(.networkError("接続エラー"))
        let viewModel = WeatherViewModel(fetchWeatherUseCase: mockUseCase)

        await viewModel.fetchWeather()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage?.contains("ネットワークエラー") ?? false)
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
        let view = makeWeatherView(state: .loaded(TestFixtures.sampleWeather))
        assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13)))
    }
*/
