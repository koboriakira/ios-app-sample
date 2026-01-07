import ComposableArchitecture
import Foundation

/// 天気画面のTCA Feature
@Reducer
public struct WeatherFeature: Sendable {
    // MARK: - State

    @ObservableState
    public struct State: Equatable, Sendable {
        /// 選択中の都市コード
        public var selectedCityCode: String
        /// 天気データ
        public var weather: Weather?
        /// ローディング状態
        public var isLoading: Bool
        /// エラーメッセージ
        public var errorMessage: String?

        /// 利用可能な都市リスト
        public static let availableCities: [(code: String, name: String)] = [
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

        public init(
            selectedCityCode: String = "130010",
            weather: Weather? = nil,
            isLoading: Bool = false,
            errorMessage: String? = nil
        ) {
            self.selectedCityCode = selectedCityCode
            self.weather = weather
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }
    }

    // MARK: - Action

    public enum Action: Equatable, Sendable {
        /// 画面が表示された
        case onAppear
        /// 都市が選択された
        case citySelected(String)
        /// 更新ボタンが押された
        case refreshButtonTapped
        /// 天気データの取得レスポンス
        case weatherResponse(Result<Weather, WeatherError>)
    }

    // MARK: - Dependencies

    @Dependency(\.weatherClient) var weatherClient

    // MARK: - Reducer

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return fetchWeather(cityCode: state.selectedCityCode)

            case let .citySelected(cityCode):
                state.selectedCityCode = cityCode
                return fetchWeather(cityCode: cityCode)

            case .refreshButtonTapped:
                return fetchWeather(cityCode: state.selectedCityCode)

            case let .weatherResponse(.success(weather)):
                state.isLoading = false
                state.weather = weather
                state.errorMessage = nil
                return .none

            case let .weatherResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.errorDescription ?? "エラーが発生しました"
                return .none
            }
        }
    }

    // MARK: - Private Methods

    private func fetchWeather(cityCode: String) -> Effect<Action> {
        .run { send in
            await send(.weatherResponse(
                Result { try await weatherClient.fetchWeather(cityCode) }
                    .mapError { error in
                        if let weatherError = error as? WeatherError {
                            return weatherError
                        }
                        return WeatherError.unknown(error.localizedDescription)
                    }
            ))
        }
    }
}

// MARK: - WeatherError Equatable Extension

extension WeatherError: Equatable {
    public static func == (lhs: WeatherError, rhs: WeatherError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCityCode, .invalidCityCode):
            return true
        case let (.networkError(lhsMsg), .networkError(rhsMsg)):
            return lhsMsg == rhsMsg
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.decodingError(lhsMsg), .decodingError(rhsMsg)):
            return lhsMsg == rhsMsg
        case let (.unknown(lhsMsg), .unknown(rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}
