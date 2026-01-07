import ComposableArchitecture
import SwiftUI
import XCTest
@testable import WeatherApp

/// スナップショットテストのベースクラス
/// 実際のスナップショットライブラリ (point-free/swift-snapshot-testing) を
/// 追加した際に拡張可能な設計
///
/// 使用例:
/// ```swift
/// final class WeatherViewSnapshotTests: SnapshotTestCase {
///     func testWeatherView_loaded() {
///         let view = makeWeatherView(weather: TestFixtures.sampleWeather)
///         // assertSnapshot(matching: view, as: .image)
///     }
/// }
/// ```
class SnapshotTestCase: XCTestCase {

    /// テスト用のWeatherViewを生成（アイドル状態）
    @MainActor
    func makeWeatherView(
        selectedCityCode: String = "130010",
        weather: Weather? = nil,
        isLoading: Bool = false,
        errorMessage: String? = nil
    ) -> WeatherView {
        let store = Store(
            initialState: WeatherFeature.State(
                selectedCityCode: selectedCityCode,
                weather: weather,
                isLoading: isLoading,
                errorMessage: errorMessage
            )
        ) {
            WeatherFeature()
        } withDependencies: {
            $0.weatherClient = .previewValue
        }

        return WeatherView(store: store)
    }

    /// ホスティングコントローラーでラップ（UIKit統合用）
    #if canImport(UIKit)
    @MainActor
    func makeHostingController<Content: View>(for view: Content) -> UIViewController {
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = UIScreen.main.bounds
        return hostingController
    }
    #endif
}

// MARK: - Snapshot Test Helpers

extension SnapshotTestCase {
    /// 各状態のビューを生成するファクトリ
    struct ViewFactory {
        @MainActor
        static func forecastCard(forecast: DailyForecast) -> some View {
            ForecastCard(forecast: forecast)
                .padding()
                .background(Color(.systemBackground))
        }

        @MainActor
        static func rainProbabilityBadge(label: String, value: String) -> some View {
            RainProbabilityBadge(label: label, value: value)
                .padding()
        }
    }
}
