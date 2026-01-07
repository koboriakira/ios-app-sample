import Foundation
import SwiftUI

/// 天気画面の状態
public enum WeatherViewState: Equatable {
    case idle
    case loading
    case loaded(Weather)
    case error(String)
}

/// 天気画面のViewModel
/// Presentation層のロジックを担当し、ViewとUseCaseを繋ぐ
@MainActor
public final class WeatherViewModel: ObservableObject {
    @Published public private(set) var state: WeatherViewState = .idle
    @Published public var selectedCityCode: String = "130010"

    private let fetchWeatherUseCase: FetchWeatherUseCaseProtocol

    /// 利用可能な都市リスト
    public let availableCities: [(code: String, name: String)] = [
        ("130010", "東京"),
        ("270000", "大阪"),
        ("140010", "横浜"),
        ("230010", "名古屋"),
        ("016010", "札幌"),
        ("400010", "福岡"),
        ("040010", "仙台"),
        ("340010", "広島"),
        ("170010", "新潟"),
        ("260010", "京都")
    ]

    public init(fetchWeatherUseCase: FetchWeatherUseCaseProtocol) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
    }

    /// 天気データを取得
    public func fetchWeather() async {
        state = .loading

        do {
            let weather = try await fetchWeatherUseCase.execute(cityCode: selectedCityCode)
            state = .loaded(weather)
        } catch let error as WeatherError {
            state = .error(error.errorDescription ?? "エラーが発生しました")
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// 都市を変更して天気を再取得
    public func changeCity(to code: String) async {
        selectedCityCode = code
        await fetchWeather()
    }

    /// 現在の天気データ（loaded状態の場合のみ）
    public var weather: Weather? {
        if case .loaded(let weather) = state {
            return weather
        }
        return nil
    }

    /// エラーメッセージ（error状態の場合のみ）
    public var errorMessage: String? {
        if case .error(let message) = state {
            return message
        }
        return nil
    }

    /// ローディング中かどうか
    public var isLoading: Bool {
        state == .loading
    }
}
