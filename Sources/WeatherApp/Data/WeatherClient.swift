import ComposableArchitecture
import Foundation

/// TCA用の天気クライアント
/// 天気データの取得を担当する
@DependencyClient
public struct WeatherClient: Sendable {
    /// 都市コードから天気データを取得
    public var fetchWeather: @Sendable (_ cityCode: String) async throws -> Weather
}

// MARK: - DependencyKey

extension WeatherClient: DependencyKey {
    /// 本番環境用の実装
    public static let liveValue = WeatherClient(
        fetchWeather: { cityCode in
            let apiClient = WeatherAPIClient()
            let response = try await apiClient.fetchWeather(cityCode: cityCode)
            return response.toDomain()
        }
    )

    /// テスト用のモック実装
    public static let testValue = WeatherClient(
        fetchWeather: unimplemented("\(Self.self).fetchWeather")
    )

    /// プレビュー用の実装
    public static let previewValue = WeatherClient(
        fetchWeather: { _ in
            Weather(
                location: Location(area: "関東", prefecture: "東京都", city: "東京"),
                description: "本日は晴れでしょう",
                forecasts: [
                    DailyForecast(
                        date: "2024-01-01",
                        dateLabel: "今日",
                        telop: "晴れ",
                        telopDescription: .sunny,
                        temperature: Temperature(
                            min: TemperatureValue(celsius: "5", fahrenheit: "41"),
                            max: TemperatureValue(celsius: "12", fahrenheit: "54")
                        ),
                        chanceOfRain: ChanceOfRain(t00_06: "0%", t06_12: "0%", t12_18: "10%", t18_24: "20%"),
                        imageUrl: nil
                    )
                ]
            )
        }
    )
}

// MARK: - DependencyValues Extension

extension DependencyValues {
    public var weatherClient: WeatherClient {
        get { self[WeatherClient.self] }
        set { self[WeatherClient.self] = newValue }
    }
}
