import Foundation

/// APIレスポンスのDTO (Data Transfer Object)
/// APIのJSONレスポンスをそのままマッピング
struct WeatherAPIResponse: Decodable {
    let publicTime: String
    let publicTimeFormatted: String
    let publishingOffice: String
    let title: String
    let link: String
    let description: Description
    let forecasts: [ForecastDTO]
    let location: LocationDTO
    let copyright: Copyright

    struct Description: Decodable {
        let publicTime: String
        let publicTimeFormatted: String
        let headlineText: String
        let bodyText: String
        let text: String
    }

    struct ForecastDTO: Decodable {
        let date: String
        let dateLabel: String
        let telop: String
        let detail: Detail
        let temperature: TemperatureDTO
        let chanceOfRain: ChanceOfRainDTO
        let image: ImageDTO

        struct Detail: Decodable {
            let weather: String?
            let wind: String?
            let wave: String?
        }

        struct TemperatureDTO: Decodable {
            let min: TemperatureValueDTO
            let max: TemperatureValueDTO

            struct TemperatureValueDTO: Decodable {
                let celsius: String?
                let fahrenheit: String?
            }
        }

        struct ChanceOfRainDTO: Decodable {
            let T00_06: String
            let T06_12: String
            let T12_18: String
            let T18_24: String
        }

        struct ImageDTO: Decodable {
            let title: String
            let url: String
            let width: Int
            let height: Int
        }
    }

    struct LocationDTO: Decodable {
        let area: String
        let prefecture: String
        let district: String
        let city: String
    }

    struct Copyright: Decodable {
        let title: String
        let link: String
        let image: CopyrightImage
        let provider: [Provider]

        struct CopyrightImage: Decodable {
            let title: String
            let link: String
            let url: String
            let width: Int
            let height: Int
        }

        struct Provider: Decodable {
            let link: String
            let name: String
            let note: String?
        }
    }
}

// MARK: - ドメインモデルへの変換

extension WeatherAPIResponse {
    func toDomain() -> Weather {
        Weather(
            location: location.toDomain(),
            description: description.bodyText,
            forecasts: forecasts.map { $0.toDomain() }
        )
    }
}

extension WeatherAPIResponse.LocationDTO {
    func toDomain() -> Location {
        Location(
            area: area,
            prefecture: prefecture,
            city: city
        )
    }
}

extension WeatherAPIResponse.ForecastDTO {
    func toDomain() -> DailyForecast {
        DailyForecast(
            date: date,
            dateLabel: dateLabel,
            telop: telop,
            telopDescription: WeatherCondition.from(telop: telop),
            temperature: temperature.toDomain(),
            chanceOfRain: chanceOfRain.toDomain(),
            imageUrl: URL(string: image.url)
        )
    }
}

extension WeatherAPIResponse.ForecastDTO.TemperatureDTO {
    func toDomain() -> Temperature {
        Temperature(
            min: min.toDomain(),
            max: max.toDomain()
        )
    }
}

extension WeatherAPIResponse.ForecastDTO.TemperatureDTO.TemperatureValueDTO {
    func toDomain() -> TemperatureValue? {
        guard let celsius = celsius, let fahrenheit = fahrenheit else {
            return nil
        }
        return TemperatureValue(celsius: celsius, fahrenheit: fahrenheit)
    }
}

extension WeatherAPIResponse.ForecastDTO.ChanceOfRainDTO {
    func toDomain() -> ChanceOfRain {
        ChanceOfRain(
            t00_06: T00_06,
            t06_12: T06_12,
            t12_18: T12_18,
            t18_24: T18_24
        )
    }
}
