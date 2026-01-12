@preconcurrency import Foundation

/// 天気予報のドメインモデル
public struct Weather: Equatable, Sendable {
    public let location: Location
    public let description: String
    public let forecasts: [DailyForecast]

    public init(location: Location, description: String, forecasts: [DailyForecast]) {
        self.location = location
        self.description = description
        self.forecasts = forecasts
    }
}

/// 地域情報
public struct Location: Equatable, Sendable {
    public let area: String
    public let prefecture: String
    public let city: String

    public init(area: String, prefecture: String, city: String) {
        self.area = area
        self.prefecture = prefecture
        self.city = city
    }
}

/// 日別天気予報
public struct DailyForecast: Equatable, Sendable, Identifiable {
    public var id: String { date }

    public let date: String
    public let dateLabel: String
    public let telop: String
    public let telopDescription: WeatherCondition
    public let temperature: Temperature
    public let chanceOfRain: ChanceOfRain
    public let imageUrl: URL?

    public init(
        date: String,
        dateLabel: String,
        telop: String,
        telopDescription: WeatherCondition,
        temperature: Temperature,
        chanceOfRain: ChanceOfRain,
        imageUrl: URL?
    ) {
        self.date = date
        self.dateLabel = dateLabel
        self.telop = telop
        self.telopDescription = telopDescription
        self.temperature = temperature
        self.chanceOfRain = chanceOfRain
        self.imageUrl = imageUrl
    }
}

/// 天気の状態を表す列挙型
public enum WeatherCondition: Equatable, Sendable {
    case sunny
    case cloudy
    case rainy
    case snowy
    case sunnyToCloudy
    case sunnyToRainy
    case cloudyToSunny
    case cloudyToRainy
    case unknown(String)

    public var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snowy: return "❄️"
        case .sunnyToCloudy: return "🌤️"
        case .sunnyToRainy: return "🌦️"
        case .cloudyToSunny: return "⛅"
        case .cloudyToRainy: return "🌧️"
        case .unknown: return "🌈"
        }
    }

    public var description: String {
        switch self {
        case .sunny: return "晴れ"
        case .cloudy: return "曇り"
        case .rainy: return "雨"
        case .snowy: return "雪"
        case .sunnyToCloudy: return "晴れのち曇り"
        case .sunnyToRainy: return "晴れのち雨"
        case .cloudyToSunny: return "曇りのち晴れ"
        case .cloudyToRainy: return "曇りのち雨"
        case .unknown(let original): return original
        }
    }

    /// telopから天気状態を解析
    public static func from(telop: String) -> WeatherCondition {
        let normalized = telop.replacingOccurrences(of: " ", with: "")

        if normalized.contains("雪") {
            return .snowy
        } else if normalized.contains("晴") && normalized.contains("曇") {
            if normalized.hasPrefix("晴") {
                return .sunnyToCloudy
            } else {
                return .cloudyToSunny
            }
        } else if normalized.contains("晴") && normalized.contains("雨") {
            return .sunnyToRainy
        } else if normalized.contains("曇") && normalized.contains("雨") {
            return .cloudyToRainy
        } else if normalized.contains("晴") {
            return .sunny
        } else if normalized.contains("曇") {
            return .cloudy
        } else if normalized.contains("雨") {
            return .rainy
        } else {
            return .unknown(telop)
        }
    }
}

/// 気温
public struct Temperature: Equatable, Sendable {
    public let min: TemperatureValue?
    public let max: TemperatureValue?

    public init(min: TemperatureValue?, max: TemperatureValue?) {
        self.min = min
        self.max = max
    }
}

/// 気温の値
public struct TemperatureValue: Equatable, Sendable {
    public let celsius: String
    public let fahrenheit: String

    public init(celsius: String, fahrenheit: String) {
        self.celsius = celsius
        self.fahrenheit = fahrenheit
    }

    public var displayCelsius: String {
        "\(celsius)°C"
    }
}

/// 降水確率
public struct ChanceOfRain: Equatable, Sendable {
    public let t00_06: String
    public let t06_12: String
    public let t12_18: String
    public let t18_24: String

    public init(t00_06: String, t06_12: String, t12_18: String, t18_24: String) {
        self.t00_06 = t00_06
        self.t06_12 = t06_12
        self.t12_18 = t12_18
        self.t18_24 = t18_24
    }

    public var periods: [(label: String, value: String)] {
        [
            ("0-6時", t00_06),
            ("6-12時", t06_12),
            ("12-18時", t12_18),
            ("18-24時", t18_24)
        ]
    }
}
