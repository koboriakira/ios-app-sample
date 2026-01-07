import ComposableArchitecture
import SwiftUI

/// アプリケーションのエントリーポイント
@main
public struct WeatherApp: App {
    let store = Store(initialState: WeatherFeature.State()) {
        WeatherFeature()
    }

    public init() {}

    public var body: some Scene {
        WindowGroup {
            WeatherView(store: store)
        }
    }
}
