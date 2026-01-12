import Foundation
import WeatherCore

/// テスト用のフィクスチャデータ
public enum TestFixtures {
    /// サンプルの天気データ
    public static let sampleWeather = Weather(
        location: Location(
            area: "関東",
            prefecture: "東京都",
            city: "東京"
        ),
        description: "関東甲信地方は高気圧に緩やかに覆われていますが、湿った空気の影響を受けています。",
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
                imageUrl: URL(string: "https://example.com/sunny.png")
            ),
            DailyForecast(
                date: "2026-01-08",
                dateLabel: "明日",
                telop: "曇のち雨",
                telopDescription: .cloudyToRainy,
                temperature: Temperature(
                    min: TemperatureValue(celsius: "3", fahrenheit: "37"),
                    max: TemperatureValue(celsius: "10", fahrenheit: "50")
                ),
                chanceOfRain: ChanceOfRain(
                    t00_06: "20%",
                    t06_12: "40%",
                    t12_18: "60%",
                    t18_24: "80%"
                ),
                imageUrl: URL(string: "https://example.com/cloudy_rain.png")
            )
        ]
    )

    /// 空の天気データ（フォールバック用）
    public static let emptyWeather = Weather(
        location: Location(area: "", prefecture: "", city: ""),
        description: "",
        forecasts: []
    )
}
