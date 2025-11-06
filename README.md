# Last

A SwiftUI iOS application that displays character data from the Rick and Morty API, built with Clean Architecture principles.

## Features

- Browse Rick and Morty characters in a grid and list layout
- View detailed character information
- Pull to refresh functionality
- Async image loading with caching
- Mock data support for testing and previews
- Clean Architecture implementation

## Architecture

This project follows Clean Architecture with clear separation of concerns:

### Layers

- **Presentation Layer**: SwiftUI views with `@Observable` view models
- **Domain Layer**: Protocol-based use cases containing business logic
- **Data Layer**: Repository pattern with network service abstraction

### Key Patterns

- **Builder Pattern**: Dependency injection for views and components
- **Protocol-First Design**: All major components have protocol definitions
- **Async/Await**: Structured concurrency for network operations
- **Sendable Compliance**: Thread-safe data models

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/obadasemary/Last.git
cd Last
```

2. Open the project in Xcode:
```bash
open Last.xcodeproj
```

3. Build and run the project (⌘R)

## Building and Testing

### Build the project
```bash
xcodebuild -scheme Last -project Last.xcodeproj build
```

### Run tests
```bash
xcodebuild -scheme Last -project Last.xcodeproj test
```

### Run specific test
```bash
xcodebuild -scheme Last -project Last.xcodeproj -only-testing:LastTests/LastTests/fetchFeed_OnSuccess test
```

## Project Structure

```
Last/
├── Views/
│   ├── FeedView.swift
│   ├── FeedDetailsView.swift
│   ├── CharacterView.swift
│   └── CharacterCardView.swift
├── ViewModels/
│   ├── FeedViewModel.swift
│   └── FeedDetailsViewModel.swift
├── Use Cases/
│   └── FeedUseCase.swift
├── Repositories/
│   ├── FeedRepository.swift
│   └── MockFeedRepository.swift
├── Services/
│   └── NetworkService.swift
├── Models/
│   └── FeedEntity.swift
└── Builders/
    ├── FeedBuilder.swift
    └── FeedDetailsBuilder.swift
```

## API Reference

This app uses the [Rick and Morty API](https://rickandmortyapi.com/):
- Base URL: `https://rickandmortyapi.com/api/`
- Endpoint: `/character` - Get all characters

## Testing

The project uses Swift Testing framework with:
- Unit tests for ViewModels
- Mock implementations for repositories and use cases
- `@Test` attribute for test functions
- `#expect` for assertions

## License

This project is available for educational purposes.
