// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WeatherApp",
            targets: ["WeatherApp"]
        ),
    ],
    targets: [
        .target(
            name: "WeatherApp",
            dependencies: [],
            path: "Sources/WeatherApp"
        ),
        .testTarget(
            name: "WeatherAppTests",
            dependencies: ["WeatherApp"],
            path: "Tests/WeatherAppTests"
        ),
    ]
)
