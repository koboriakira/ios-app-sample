import XCTest
import SwiftUI
@testable import WeatherApp

/// スナップショットテストのベースクラス
/// 実際のスナップショットライブラリ (point-free/swift-snapshot-testing) を
/// 追加した際に拡張可能な設計
///
/// 使用例:
/// ```swift
/// final class WeatherViewSnapshotTests: SnapshotTestCase {
///     func testWeatherView_loaded() {
///         let view = makeWeatherView(state: .loaded(TestFixtures.sampleWeather))
///         // assertSnapshot(matching: view, as: .image)
///     }
/// }
/// ```
class SnapshotTestCase: XCTestCase {

    /// テスト用のWeatherViewを生成
    @MainActor
    func makeWeatherView(state: WeatherViewState) -> WeatherView {
        let mockUseCase = MockFetchWeatherUseCase()
        mockUseCase.stubbedResult = .success(TestFixtures.sampleWeather)

        let viewModel = WeatherViewModel(fetchWeatherUseCase: mockUseCase)

        // 状態を直接設定するためのヘルパー（テスト用）
        switch state {
        case .idle:
            break // 初期状態
        case .loading:
            break // ローディング状態はasyncで設定
        case .loaded:
            Task {
                await viewModel.fetchWeather()
            }
        case .error:
            mockUseCase.stubbedResult = .failure(.networkError("Test error"))
            Task {
                await viewModel.fetchWeather()
            }
        }

        return WeatherView(viewModel: viewModel)
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
