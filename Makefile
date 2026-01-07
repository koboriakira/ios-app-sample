# WeatherApp Makefile
# Common development tasks

.PHONY: all setup build test lint format clean docs help
.PHONY: install-hooks uninstall-hooks
.PHONY: coverage test-integration test-unit test-performance
.PHONY: release archive

# Default target
all: lint build test

# ====================
# Setup
# ====================

## Install all development dependencies and setup hooks
setup: install-hooks
	@echo "📦 Installing dependencies..."
	@swift package resolve
	@echo "🔧 Checking for SwiftLint..."
	@command -v swiftlint >/dev/null 2>&1 || { echo "⚠️  SwiftLint not found. Install with: brew install swiftlint"; }
	@echo "✅ Setup complete!"

## Install Git hooks
install-hooks:
	@echo "🔧 Installing Git hooks..."
	@chmod +x scripts/install-hooks.sh
	@./scripts/install-hooks.sh

## Uninstall Git hooks
uninstall-hooks:
	@echo "🗑️  Uninstalling Git hooks..."
	@chmod +x scripts/uninstall-hooks.sh
	@./scripts/uninstall-hooks.sh

# ====================
# Build
# ====================

## Build the project in debug mode
build:
	@echo "🔨 Building (debug)..."
	@swift build

## Build the project in release mode
release:
	@echo "🔨 Building (release)..."
	@swift build -c release

## Clean build artifacts
clean:
	@echo "🧹 Cleaning..."
	@swift package clean
	@rm -rf .build
	@rm -rf docs
	@echo "✅ Clean complete!"

# ====================
# Testing
# ====================

## Run all tests
test:
	@echo "🧪 Running all tests..."
	@swift test

## Run unit tests only
test-unit:
	@echo "🧪 Running unit tests..."
	@swift test --filter "WeatherAppTests"

## Run integration tests only
test-integration:
	@echo "🧪 Running integration tests..."
	@swift test --filter "Integration"

## Run performance tests only
test-performance:
	@echo "🧪 Running performance tests..."
	@swift test --filter "Performance"

## Run tests with coverage
coverage:
	@echo "🧪 Running tests with coverage..."
	@swift test --enable-code-coverage
	@echo "📊 Generating coverage report..."
	@xcrun llvm-cov report \
		.build/debug/WeatherAppPackageTests.xctest/Contents/MacOS/WeatherAppPackageTests \
		-instr-profile=.build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests" 2>/dev/null || echo "Coverage report generation requires Xcode"

## Generate HTML coverage report
coverage-html:
	@echo "🧪 Running tests with coverage..."
	@swift test --enable-code-coverage
	@echo "📊 Generating HTML coverage report..."
	@xcrun llvm-cov show \
		.build/debug/WeatherAppPackageTests.xctest/Contents/MacOS/WeatherAppPackageTests \
		-instr-profile=.build/debug/codecov/default.profdata \
		-format=html \
		-output-dir=coverage \
		-ignore-filename-regex=".build|Tests" 2>/dev/null || echo "HTML coverage requires Xcode"
	@echo "📂 Coverage report: coverage/index.html"

# ====================
# Linting & Formatting
# ====================

## Run SwiftLint
lint:
	@echo "📝 Running SwiftLint..."
	@swiftlint lint --strict

## Run SwiftLint with auto-fix
lint-fix:
	@echo "🔧 Running SwiftLint with auto-fix..."
	@swiftlint lint --fix

## Format code with swift-format (if available)
format:
	@echo "🎨 Formatting code..."
	@command -v swift-format >/dev/null 2>&1 && \
		find Sources Tests -name "*.swift" -exec swift-format -i {} \; || \
		echo "⚠️  swift-format not found. Install with: brew install swift-format"

## Check formatting without modifying files
format-check:
	@echo "🔍 Checking code format..."
	@command -v swift-format >/dev/null 2>&1 && \
		find Sources Tests -name "*.swift" -exec swift-format lint {} \; || \
		echo "⚠️  swift-format not found"

# ====================
# Documentation
# ====================

## Generate documentation
docs:
	@echo "📚 Generating documentation..."
	@swift package \
		--allow-writing-to-directory docs \
		generate-documentation \
		--target WeatherApp \
		--output-path docs \
		--transform-for-static-hosting 2>/dev/null || echo "DocC generation requires Swift 5.8+"
	@echo "📂 Documentation: docs/index.html"

## Serve documentation locally
docs-serve:
	@echo "🌐 Serving documentation..."
	@cd docs && python3 -m http.server 8080 || echo "Python 3 required for local server"

# ====================
# Xcode
# ====================

## Open in Xcode
xcode:
	@echo "📱 Opening in Xcode..."
	@open Package.swift

## Build for iOS Simulator
build-ios:
	@echo "📱 Building for iOS Simulator..."
	@xcodebuild build \
		-scheme WeatherApp \
		-destination 'platform=iOS Simulator,name=iPhone 15' \
		-skipPackagePluginValidation \
		CODE_SIGNING_ALLOWED=NO

# ====================
# CI/CD
# ====================

## Run CI checks locally
ci: lint build test
	@echo "✅ CI checks passed!"

## Prepare for release
prepare-release: clean lint test release
	@echo "✅ Ready for release!"

# ====================
# Help
# ====================

## Show this help message
help:
	@echo ""
	@echo "WeatherApp Development Tasks"
	@echo "============================"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'
	@echo ""
	@echo "Examples:"
	@echo "  make setup     - Initial project setup"
	@echo "  make test      - Run all tests"
	@echo "  make lint      - Check code style"
	@echo "  make ci        - Run all CI checks"
	@echo ""
