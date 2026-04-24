# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftUI iOS app displaying Rick and Morty character data with a full Clean Architecture stack. Notably ships **parallel SwiftUI and UIKit implementations** of the same features (Feed, NewsFeed) as an educational comparison — both live in the app under separate tabs.

## Development Commands

```bash
# Build
xcodebuild -scheme Last -project Last.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run all tests (unit only — UI tests intentionally skipped for speed)
xcodebuild -scheme Last -project Last.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:LastTests test

# Run a single test
xcodebuild -scheme Last -project Last.xcodeproj -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:LastTests/LastTests/fetchFeed_OnSuccess test
```

A pre-commit hook runs build + unit tests automatically and blocks the commit on failure. Bypass only in exceptional cases: `git commit --no-verify`.

## Architecture

### Layer Structure

```text
View → ViewModel → UseCase → Repository → NetworkService / CacheRepository
```

Each layer depends only on **protocols** from the layer below (`*Protocol` suffix). All data models are `Decodable & Sendable`.

| Layer        | Files                                                                | Notes                                |
| ------------ | -------------------------------------------------------------------- | ------------------------------------ |
| Presentation | `*View.swift`, `*ViewModel.swift`, `*Builder.swift`                  | `@Observable @MainActor` view models |
| Domain       | `*UseCase.swift`, `*Entity.swift`                                    | Pure Swift, no framework deps        |
| Data         | `*Repository.swift`, `NetworkService.swift`, `CacheRepository.swift` | SwiftData + network                  |

### Dependency Injection

`FeedUseCaseFactory` is the single entry point that chains the full dependency graph (Network → Cache → Repository → UseCase). Builders call the factory:

```swift
// FeedBuilder.swift
let feedUseCase = FeedUseCaseFactory.createFeedUseCase(isUsingMock: isUsingMock)
let viewModel = FeedViewModel(feedUseCase: feedUseCase)
```

`FeedDetailsBuilder` is passed as a SwiftUI environment object so child views can build detail screens without upward coupling.

### Offline-First Strategy

`FeedRepository` implements a cache-fallback pattern:

1. Check network reachability (`NetworkReachability`)
2. If online: fetch from network, save to SwiftData cache (fire-and-forget — cache failure doesn't propagate)
3. If fetch fails or offline: load from SwiftData cache
4. If no cache available: throw `FeedRepositoryError.noInternetAndNoCache`

### Async Patterns

`NetworkService` and the use-case protocols expose **all three** async patterns (completion handler, Combine `AnyPublisher`, async/await). `FeedViewModel` demonstrates wrapping the older patterns with `withCheckedThrowingContinuation` — this is intentional as a learning reference.

### SwiftData Persistence

`SwiftDataManager.shared` owns the `ModelContainer`. Cache entities (`CachedFeedEntity`, `CachedNewsFeedEntity`) live in `Last/Data/`. Repositories receive a `ModelContext` injected via the factory.

### Feature Flags

`FeatureFlag.swift` provides a `FeatureFlagManagerProtocol` backed by `UserDefaults`, with a mock for tests. Currently used to toggle carousel variants (`enhancedCarousel`, `genericCarousel`).

## Testing

Framework: **Swift Testing** (not XCTest).

```swift
@Suite(.serialized) struct FeedRepositoryTests {
    @Test func fetchFeed_OnSuccess() async throws { ... }
    // assertions use #expect(), not XCTAssert*
}
```

All layers have dedicated mock files (`Mock*.swift`) with configurable results and call counts. ViewModels are tested by injecting mock use cases; repositories are tested with `MockNetworkService` + `MockCacheRepository` + `MockNetworkReachability` for full scenario coverage (online success, offline+cache, offline+no cache, network error with cache fallback).

## Key Files

- `Last/Factory/FeedUseCaseFactory.swift` — root of the DI graph
- `Last/NetworkService/NetworkService.swift` — generic `execute<T: Decodable>` with three overloads
- `Last/Repository/FeedRepository.swift` — offline-first logic
- `Last/FeatureFlag.swift` — feature flag system
- `Last/TabBarView.swift` — top-level navigation; shows both SwiftUI and UIKit tabs
- `LastTests/FeedRepositoryTests.swift` — most comprehensive test file (~620 lines)
