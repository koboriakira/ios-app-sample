import Foundation
@testable import WeatherApp

/// テスト用のフィクスチャデータ
enum TestFixtures {
    /// サンプルの天気データ
    static let sampleWeather = Weather(
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

    /// サンプルのAPIレスポンスJSON
    static let sampleAPIResponseJSON = """
    {
        "publicTime": "2026-01-07T17:00:00+09:00",
        "publicTimeFormatted": "2026/01/07 17:00:00",
        "publishingOffice": "気象庁",
        "title": "東京都 東京 の天気",
        "link": "https://www.jma.go.jp/bosai/forecast/#area_type=offices&area_code=130000",
        "description": {
            "publicTime": "2026-01-07T16:35:00+09:00",
            "publicTimeFormatted": "2026/01/07 16:35:00",
            "headlineText": "",
            "bodyText": "関東甲信地方は高気圧に緩やかに覆われています。",
            "text": "関東甲信地方は高気圧に緩やかに覆われています。"
        },
        "forecasts": [
            {
                "date": "2026-01-07",
                "dateLabel": "今日",
                "telop": "晴れ",
                "detail": {
                    "weather": "晴れ 夜 くもり",
                    "wind": "北の風",
                    "wave": "0.5メートル"
                },
                "temperature": {
                    "min": {
                        "celsius": "5",
                        "fahrenheit": "41"
                    },
                    "max": {
                        "celsius": "12",
                        "fahrenheit": "54"
                    }
                },
                "chanceOfRain": {
                    "T00_06": "10%",
                    "T06_12": "20%",
                    "T12_18": "10%",
                    "T18_24": "10%"
                },
                "image": {
                    "title": "晴れ",
                    "url": "https://www.jma.go.jp/bosai/forecast/img/100.svg",
                    "width": 80,
                    "height": 60
                }
            }
        ],
        "location": {
            "area": "関東",
            "prefecture": "東京都",
            "district": "東京地方",
            "city": "東京"
        },
        "copyright": {
            "title": "(C) 天気予報 API（livedoor 天気互換）",
            "link": "https://weather.tsukumijima.net/",
            "image": {
                "title": "天気予報 API（livedoor 天気互換）",
                "link": "https://weather.tsukumijima.net/",
                "url": "https://weather.tsukumijima.net/logo.png",
                "width": 120,
                "height": 120
            },
            "provider": [
                {
                    "link": "https://www.jma.go.jp/jma/",
                    "name": "気象庁",
                    "note": "気象庁 Japan Meteorological Agency"
                }
            ]
        }
    }
    """

    static var sampleAPIResponseData: Data {
        sampleAPIResponseJSON.data(using: .utf8)!
    }
}
