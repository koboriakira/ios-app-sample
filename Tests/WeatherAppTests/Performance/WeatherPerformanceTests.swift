import XCTest
@testable import WeatherApp

/// パフォーマンステスト
final class WeatherPerformanceTests: XCTestCase {

    // MARK: - JSON Decoding Performance

    func testPerformance_jsonDecoding() throws {
        let data = TestFixtures.sampleAPIResponseData
        let decoder = JSONDecoder()

        measure {
            for _ in 0..<100 {
                _ = try? decoder.decode(WeatherAPIResponse.self, from: data)
            }
        }
    }

    // MARK: - WeatherCondition Parsing Performance

    func testPerformance_weatherConditionParsing() {
        let telops = [
            "晴れ", "曇り", "雨", "雪",
            "晴のち曇", "曇のち晴", "晴のち雨", "曇のち雨",
            "晴れ 時々 曇り", "曇り 一時 雨"
        ]

        measure {
            for _ in 0..<1000 {
                for telop in telops {
                    _ = WeatherCondition.from(telop: telop)
                }
            }
        }
    }

    // MARK: - Domain Model Transformation Performance

    func testPerformance_domainModelTransformation() throws {
        let data = TestFixtures.sampleAPIResponseData
        let decoder = JSONDecoder()
        let response = try decoder.decode(WeatherAPIResponse.self, from: data)

        measure {
            for _ in 0..<1000 {
                _ = response.toDomain()
            }
        }
    }

    // MARK: - ChanceOfRain Periods Generation Performance

    func testPerformance_chanceOfRainPeriods() {
        let chanceOfRain = ChanceOfRain(
            t00_06: "10%",
            t06_12: "20%",
            t12_18: "30%",
            t18_24: "40%"
        )

        measure {
            for _ in 0..<10000 {
                _ = chanceOfRain.periods
            }
        }
    }
}
