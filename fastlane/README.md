# Fastlane Setup

This directory contains Fastlane configuration for automating iOS development tasks.

## Installation

```bash
# Install Fastlane
brew install fastlane

# Or with Ruby
gem install fastlane
```

## Available Lanes

### Testing

```bash
# Run all tests
fastlane test

# Run unit tests only
fastlane test_unit

# Run tests with coverage
fastlane test_coverage
```

### Building

```bash
# Build debug
fastlane build_debug

# Build release
fastlane build_release

# Build for iOS Simulator
fastlane build_ios device:"iPhone 15"
```

### Linting

```bash
# Run SwiftLint
fastlane lint

# Auto-fix SwiftLint issues
fastlane lint_fix
```

### CI/CD

```bash
# Run all CI checks
fastlane ci

# Prepare for release
fastlane prepare_release version:1.0.0
```

### Distribution

```bash
# Upload to TestFlight (requires Xcode project)
fastlane beta

# Deploy to App Store (requires Xcode project)
fastlane release version:1.0.0
```

### Utilities

```bash
# Generate documentation
fastlane docs

# Clean build artifacts
fastlane clean

# Setup development environment
fastlane setup
```

## Configuration

1. Update `Appfile` with your Apple ID and Team ID
2. Configure code signing with `match` (recommended)
3. Set up environment variables for CI

## Environment Variables

| Variable | Description |
|----------|-------------|
| `APPLE_ID` | Your Apple ID email |
| `TEAM_ID` | Apple Developer Team ID |
| `ITC_TEAM_ID` | App Store Connect Team ID |
| `MATCH_PASSWORD` | Password for match certificates |
| `SLACK_WEBHOOK` | Slack webhook for notifications |

## CI Integration

Fastlane works with popular CI services:

- **GitHub Actions**: See `.github/workflows/`
- **CircleCI**: Add `fastlane ci` to your config
- **Bitrise**: Use Fastlane step

## Code Signing (Optional)

For automatic code signing, set up [match](https://docs.fastlane.tools/actions/match/):

```bash
# Initialize match
fastlane match init

# Generate certificates
fastlane match development
fastlane match appstore
```
