import SwiftUI

/// メインの天気表示画面
public struct WeatherView: View {
    @ObservedObject private var viewModel: WeatherViewModel

    public init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            VStack {
                cityPicker

                content
            }
            .navigationTitle("天気予報")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        Task {
                            await viewModel.fetchWeather()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .task {
            await viewModel.fetchWeather()
        }
    }

    @ViewBuilder
    private var cityPicker: some View {
        Picker("都市", selection: Binding(
            get: { viewModel.selectedCityCode },
            set: { newValue in
                Task {
                    await viewModel.changeCity(to: newValue)
                }
            }
        )) {
            ForEach(viewModel.availableCities, id: \.code) { city in
                Text(city.name).tag(city.code)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            ContentUnavailableView(
                "天気を取得",
                systemImage: "cloud.sun",
                description: Text("都市を選択して天気を確認")
            )

        case .loading:
            ProgressView("読み込み中...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded(let weather):
            WeatherContentView(weather: weather)

        case .error(let message):
            ContentUnavailableView(
                "エラー",
                systemImage: "exclamationmark.triangle",
                description: Text(message)
            )
        }
    }
}

/// 天気コンテンツ表示
struct WeatherContentView: View {
    let weather: Weather

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                locationHeader

                descriptionSection

                forecastList
            }
            .padding()
        }
    }

    private var locationHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(weather.location.city)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("\(weather.location.area) / \(weather.location.prefecture)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var descriptionSection: some View {
        Text(weather.description)
            .font(.body)
            .foregroundStyle(.secondary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }

    private var forecastList: some View {
        VStack(spacing: 12) {
            ForEach(weather.forecasts) { forecast in
                ForecastCard(forecast: forecast)
            }
        }
    }
}

/// 日別予報カード
struct ForecastCard: View {
    let forecast: DailyForecast

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            temperatureRow

            rainProbabilityRow
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(forecast.dateLabel)
                    .font(.headline)
                Text(forecast.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(forecast.telopDescription.emoji)
                    .font(.system(size: 40))
                Text(forecast.telop)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }

    private var temperatureRow: some View {
        HStack(spacing: 24) {
            if let max = forecast.temperature.max {
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.sun.fill")
                        .foregroundStyle(.red)
                    Text("最高")
                        .font(.caption)
                    Text(max.displayCelsius)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }

            if let min = forecast.temperature.min {
                HStack(spacing: 4) {
                    Image(systemName: "thermometer.snowflake")
                        .foregroundStyle(.blue)
                    Text("最低")
                        .font(.caption)
                    Text(min.displayCelsius)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            if forecast.temperature.max == nil && forecast.temperature.min == nil {
                Text("気温データなし")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var rainProbabilityRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("降水確率")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(forecast.chanceOfRain.periods, id: \.label) { period in
                    RainProbabilityBadge(label: period.label, value: period.value)
                }
            }
        }
    }
}

/// 降水確率バッジ
struct RainProbabilityBadge: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value.isEmpty || value == "--%" ? "-" : value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(probabilityColor)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private var probabilityColor: Color {
        guard let numericValue = Int(value.replacingOccurrences(of: "%", with: "")) else {
            return .secondary
        }
        switch numericValue {
        case 0..<30: return .green
        case 30..<60: return .orange
        default: return .blue
        }
    }
}
