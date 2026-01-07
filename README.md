# WeatherApp

iOS天気予報アプリ - Clean Architecture + MVVM によるテスタブルな設計

[![CI](https://github.com/koboriakira/ios-app-sample/actions/workflows/ci.yml/badge.svg)](https://github.com/koboriakira/ios-app-sample/actions/workflows/ci.yml)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS 17+](https://img.shields.io/badge/iOS-17+-blue.svg)](https://developer.apple.com/ios/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 概要

[天気予報 API](https://weather.tsukumijima.net/) を使用した iOS 天気予報アプリです。
Clean Architecture と MVVM パターンを採用し、実機テストなしでもユニットテストによる品質保証が可能な設計になっています。

## 機能

- 🌤️ 10都市の天気予報表示（東京、大阪、名古屋など）
- 📊 3日間の予報（今日、明日、明後日）
- 🌡️ 最高/最低気温の表示
- 💧 6時間ごとの降水確率
- 🔄 プルトゥリフレッシュ対応

## アーキテクチャ

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐    ┌──────────────────────────────┐  │
│  │  SwiftUI     │◄───│     WeatherViewModel         │  │
│  │  Views       │    │  (@MainActor, ObservableObject)│  │
│  └──────────────┘    └──────────────────────────────┘  │
└─────────────────────────────┬───────────────────────────┘
                              │ FetchWeatherUseCaseProtocol
┌─────────────────────────────▼───────────────────────────┐
│                      Domain Layer                        │
│  ┌──────────────┐    ┌──────────────────────────────┐  │
│  │   Weather    │    │    FetchWeatherUseCase       │  │
│  │   Models     │    │                              │  │
│  └──────────────┘    └──────────────────────────────┘  │
└─────────────────────────────┬───────────────────────────┘
                              │ WeatherRepositoryProtocol
┌─────────────────────────────▼───────────────────────────┐
│                       Data Layer                         │
│  ┌──────────────┐    ┌──────────────────────────────┐  │
│  │  Repository  │◄───│      WeatherAPIClient        │  │
│  │              │    │   (HTTPClientProtocol)       │  │
│  └──────────────┘    └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### レイヤー説明

| レイヤー | 責務 | テスト方法 |
|---------|------|-----------|
| **Presentation** | UI表示、ユーザー入力処理 | ViewModelのユニットテスト |
| **Domain** | ビジネスロジック、モデル定義 | UseCaseのユニットテスト |
| **Data** | API通信、データ変換 | Repositoryのユニットテスト |

## 必要環境

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+
- iOS 17.0+ (実行対象)

## セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/koboriakira/ios-app-sample.git
cd ios-app-sample

# 開発環境をセットアップ
make setup

# または手動で
swift package resolve
./scripts/install-hooks.sh
```

## ビルド & テスト

```bash
# ビルド
make build

# 全テスト実行
make test

# カバレッジ付きテスト
make coverage

# Lintチェック
make lint

# CIチェック（lint + build + test）
make ci
```

## プロジェクト構造

```
ios-app-sample/
├── Package.swift                 # Swift Package 定義
├── Makefile                      # 開発タスク
├── .swiftlint.yml               # SwiftLint 設定
├── .gitignore
│
├── Sources/WeatherApp/
│   ├── App/
│   │   └── WeatherApp.swift     # アプリエントリーポイント
│   ├── Domain/
│   │   ├── Models/              # ドメインモデル
│   │   ├── Protocols/           # リポジトリプロトコル
│   │   └── UseCases/            # ユースケース
│   ├── Data/
│   │   ├── DTOs/                # API レスポンスマッピング
│   │   ├── DataSources/         # API クライアント
│   │   └── Repositories/        # リポジトリ実装
│   ├── Presentation/
│   │   ├── ViewModels/          # ViewModel
│   │   └── Views/               # SwiftUI Views
│   └── DI/
│       └── DependencyContainer.swift
│
├── Tests/WeatherAppTests/
│   ├── Domain/                  # ドメイン層テスト
│   ├── Data/                    # データ層テスト
│   ├── Presentation/            # プレゼンテーション層テスト
│   ├── Integration/             # 統合テスト
│   ├── Performance/             # パフォーマンステスト
│   ├── Snapshot/                # スナップショットテスト準備
│   ├── Mocks/                   # テスト用モック
│   └── Fixtures/                # テストフィクスチャ
│
├── .github/
│   └── workflows/
│       ├── ci.yml               # CI ワークフロー
│       ├── pr.yml               # PR チェック
│       └── release.yml          # リリースワークフロー
│
├── scripts/
│   ├── hooks/                   # Git フック
│   ├── install-hooks.sh
│   └── uninstall-hooks.sh
│
└── fastlane/
    ├── Fastfile                 # Fastlane 設定
    └── Appfile
```

## テスト戦略

### ユニットテスト

```swift
// UseCaseテスト例
func testFetchWeather_success_returnsWeather() async throws {
    // Given
    let mockRepository = MockWeatherRepository()
    mockRepository.stubbedResult = .success(TestFixtures.sampleWeather)
    let sut = FetchWeatherUseCase(repository: mockRepository)

    // When
    let result = try await sut.execute(cityCode: "130010")

    // Then
    XCTAssertEqual(result.location.city, "東京")
}
```

### 統合テスト

APIクライアント → リポジトリ → ユースケース → ViewModel の
フロー全体をモックHTTPクライアントでテスト。

### パフォーマンステスト

JSONデコードやモデル変換の処理時間を計測。

## Git Hooks

| Hook | 実行内容 |
|------|---------|
| `pre-commit` | SwiftLint、ビルドチェック、機密情報チェック |
| `pre-push` | 全テスト実行、プロテクトブランチ警告 |
| `commit-msg` | Conventional Commits形式の検証 |

### コミットメッセージ形式

```
type(scope): description

# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# Examples:
feat: add weather caching
fix(api): handle network timeout
docs: update README
```

## CI/CD

### GitHub Actions

- **CI** (`ci.yml`): プッシュ時にビルド・テスト・Lint実行
- **PR** (`pr.yml`): PRタイトル検証、カバレッジチェック
- **Release** (`release.yml`): タグプッシュ時にリリース作成

### Fastlane

```bash
# CIチェック
fastlane ci

# TestFlight配布（Xcodeプロジェクト必要）
fastlane beta

# App Store配布
fastlane release version:1.0.0
```

## 使用API

[天気予報 API（livedoor 天気互換）](https://weather.tsukumijima.net/)

```
GET https://weather.tsukumijima.net/api/forecast/city/{cityCode}
```

### 対応都市コード

| 都市 | コード |
|------|--------|
| 東京 | 130010 |
| 大阪 | 270000 |
| 横浜 | 140010 |
| 名古屋 | 230010 |
| 札幌 | 016010 |
| 福岡 | 400010 |
| 仙台 | 040010 |
| 広島 | 340010 |
| 新潟 | 170010 |
| 京都 | 260010 |

## ライセンス

MIT License

## 貢献

1. Fork the repository
2. Create your feature branch (`git checkout -b feat/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feat/amazing-feature`)
5. Open a Pull Request
