// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherCore",
    products: [
        .library(
            name: "WeatherCore",
            targets: ["WeatherCore"]
        ),
    ],
    targets: [
        .target(
            name: "WeatherCore",
            path: "Sources/WeatherCore"
        ),
        .testTarget(
            name: "WeatherCoreTests",
            dependencies: ["WeatherCore"],
            path: "Tests/WeatherCoreTests"
        ),
    ]
)
