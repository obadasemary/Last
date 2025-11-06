# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI iOS application that displays character data fetched from the Rick and Morty API. The app follows Clean Architecture principles with a clear separation of concerns across layers.

## Architecture

### Clean Architecture Layers

The codebase implements Clean Architecture with the following layers:

1. **Presentation Layer**
   - `*View.swift`: SwiftUI views
   - `*ViewModel.swift`: Observable view models using Swift's `@Observable` macro
   - `*Builder.swift`: Factory pattern for constructing views with dependencies

2. **Domain Layer**
   - `*UseCase.swift`: Business logic layer with protocol-first design
   - `*Entity.swift`: Domain models (Decodable, Sendable)

3. **Data Layer**
   - `*Repository.swift`: Data access abstraction with protocols
   - `NetworkService.swift`: Generic network layer for API calls
   - `Mock*Repository.swift`: Mock implementations for testing/previews

### Dependency Injection Pattern

The app uses Builder pattern for dependency injection:
- `FeedBuilder` constructs the main feed view with all dependencies
- `FeedDetailsBuilder` constructs detail views (injected as SwiftUI environment object)
- Builders support mock mode via `isUsingMock` parameter for previews and testing

### Key Architectural Decisions

- **Protocol-first design**: All major components have protocol definitions (*Protocol)
- **Async/await**: All network operations use structured concurrency
- **Sendable compliance**: All data models conform to Sendable for thread safety
- **SwiftUI @Observable**: Modern observation using Swift macros instead of ObservableObject

## Development Commands

### Building and Running

```bash
# Build the project
xcodebuild -scheme Last -project Last.xcodeproj build

# Run tests
xcodebuild -scheme Last -project Last.xcodeproj test

# Run specific test
xcodebuild -scheme Last -project Last.xcodeproj -only-testing:LastTests/LastTests/fetchFeed_OnSuccess test
```

### Testing

The project uses Swift Testing framework (not XCTest). Test files use:
- `@Test` attribute for test functions
- `#expect` for assertions
- `@MainActor` when testing view models

## Code Organization

### File Naming Conventions

- Views: `*View.swift` (e.g., `FeedView.swift`)
- ViewModels: `*ViewModel.swift` (e.g., `FeedViewModel.swift`)
- Builders: `*Builder.swift` (e.g., `FeedBuilder.swift`)
- Entities: `*Entity.swift` or `*Response.swift`
- Use Cases: `*UseCase.swift`
- Repositories: `*Repository.swift`
- Mocks: `Mock*.swift`

### Dependency Flow

```
View → ViewModel → UseCase → Repository → NetworkService
```

Each layer depends only on protocols from the layer below, enabling:
- Easy testing with mock implementations
- Flexible dependency injection
- Clear separation of concerns

### Testing Strategy

- Mock implementations (`MockFeedRepository`, `MockFeedUseCase`) for unit tests
- Builders support `isUsingMock` parameter for SwiftUI previews
- ViewModels are tested by injecting mock use cases
- Network layer tested through repository mocks

## Important Implementation Details

### Network Layer

`NetworkService` is a generic service that:
- Accepts any `URLRequest`
- Returns any `Decodable` type
- Handles HTTP status validation (200-299)
- Provides specific error types: `NetworkError.invalideResponse`, `NetworkError.decodingError`

### State Management

ViewModels use `@Observable` macro and expose state as:
- `private(set) var`: Read-only properties for views
- Async functions for actions (e.g., `loadData()`)
- No manual `@Published` or `objectWillChange` needed

### Constants

API endpoints and UI constants are centralized in `Constants.swift`:
- `Constants.url`: API endpoint URL
- Other UI constants (image dimensions, corner radius)
