# Last - Rick and Morty Character Explorer

A SwiftUI iOS application demonstrating Clean Architecture principles with both SwiftUI and UIKit implementations. Features character data from the Rick and Morty API with advanced image caching capabilities.

## Features

- **Dual UI Implementations**: Compare SwiftUI and UIKit side-by-side
- **Clean Architecture**: Clear separation of concerns across presentation, domain, and data layers
- **Advanced Image Caching**: Multiple caching strategies with dependency injection
- **Modern Swift**: Uses Swift 6 features including `@Observable` and structured concurrency
- **Comprehensive Testing**: Unit tests with mock implementations

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (Views, ViewModels, Builders)      │
├─────────────────────────────────────┤
│         Domain Layer                │
│    (UseCases, Entities)             │
├─────────────────────────────────────┤
│          Data Layer                 │
│  (Repositories, NetworkService)     │
└─────────────────────────────────────┘
```

### Key Components

- **Views**: SwiftUI views (`*View.swift`) and UIKit controllers (`*ViewController.swift`)
- **ViewModels**: Observable view models using `@Observable` macro
- **Builders**: Factory pattern for dependency injection
- **UseCases**: Business logic abstraction
- **Repositories**: Data access with protocol-first design
- **NetworkService**: Generic network layer with async/await

## Image Caching Solutions

The project includes **4 different caching implementations** to demonstrate various approaches:

### 1. Simple Dictionary Cache (`CachedAsyncImage`)
```swift
CachedAsyncImage(url: imageURL) { phase in
    // Handle phases
}
```
- Lightweight dictionary-based cache
- Good for prototyping and small apps
- Minimal overhead

### 2. NSCache with Singleton (`EnhancedCachedAsyncImage`)
```swift
EnhancedCachedAsyncImage(url: imageURL) { phase in
    // Handle phases
}
```
- Thread-safe NSCache
- Automatic memory management
- Memory warning handling
- Production-ready

### 3. DI with UIImage Cache (`EnhancedCacheManager`)
```swift
let cacheManager = EnhancedCacheManager(
    countLimit: 100,
    totalCostLimit: 100 * 1024 * 1024
)
```
- Dependency injection pattern
- Configurable cache limits
- Testable with protocol abstraction
- Access count tracking

### 4. DI with Data Cache (`ImageDataCacheManager` + `EnhancedCachedAsyncImageWithDI`)
```swift
let dataCache = ImageDataCacheManager(countLimit: 50)
EnhancedCachedAsyncImageWithDI(
    url: imageURL,
    dataCache: dataCache
) { phase in
    // Handle phases
}
```
- Data-level caching (more memory efficient)
- Full dependency injection
- Perfect for testing
- Analytics support

## Project Structure

```
Last/
├── Components/
│   ├── Cached/                    # Image caching implementations
│   │   ├── CachedAsyncImage.swift
│   │   ├── EnhancedCachedAsyncImage.swift
│   │   ├── EnhancedCachedAsyncImageWithDI.swift
│   │   ├── CacheManager.swift
│   │   ├── EnhancedCacheManager.swift
│   │   └── ImageDataCacheManager.swift
│   ├── CharacterCardView.swift
│   ├── CharacterView.swift
│   └── Shimmer.swift
├── FeedView/                       # Main feed (SwiftUI)
│   ├── FeedView.swift
│   ├── FeedViewModel.swift
│   └── FeedBuilder.swift
├── FeedUIKit/                      # Main feed (UIKit)
│   ├── FeedUIKitViewController.swift
│   ├── FeedUIKitBuilder.swift
│   └── Collection View Cells/
├── FeedDetailsView/
│   ├── FeedDetailsView.swift
│   ├── FeedDetailsViewModel.swift
│   └── FeedDetailsBuilder.swift
├── UseCase/
│   ├── FeedUseCase.swift
│   ├── FeedEntity.swift
│   └── MockFeedUseCase.swift
├── Repository/
│   ├── FeedRepository.swift
│   └── MockFeedRepository.swift
├── NetworkService/
│   └── NetworkService.swift
└── LastApp.swift
```

## Getting Started

### Requirements

- iOS 26.0+
- Xcode 16.0+
- Swift 6.0+

### Building and Running

```bash
# Build the project
xcodebuild -scheme Last -project Last.xcodeproj build

# Run tests
xcodebuild -scheme Last -project Last.xcodeproj test
```

### Pre-commit Hooks

The project includes git pre-commit hooks that automatically:
1. Build the project for iOS Simulator
2. Run unit tests
3. Block commits if either fails

This ensures code quality and prevents broken code from entering the repository.

## Development Workflow

### Adding New Features

1. Create protocol definition in appropriate layer
2. Implement concrete class
3. Add mock implementation for testing
4. Create builder method for dependency injection
5. Write unit tests
6. Update this README

### Testing

```bash
# Run all tests
xcodebuild -scheme Last -project Last.xcodeproj test

# Run specific test
xcodebuild -scheme Last -project Last.xcodeproj \
  -only-testing:LastTests/LastTests/fetchFeed_OnSuccess test
```

## Cache Management Demo

The app includes an interactive cache testing UI in the FeedDetailsView:

- **Save to Cache**: Manually download and cache an image
- **Delete from Cache**: Remove image from cache
- **Get from Cache**: Retrieve and display cached image

This demonstrates the cache manager functionality and helps debug caching behavior.

## API

This app uses the [Rick and Morty API](https://rickandmortyapi.com/):
- Endpoint: `https://rickandmortyapi.com/api/character`
- No authentication required
- Returns character data with images

## Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **UIKit**: Traditional imperative UI with UICollectionView
- **Async/Await**: Structured concurrency for network calls
- **@Observable**: Modern state management (Swift 5.9+)
- **NSCache**: Thread-safe caching with automatic eviction
- **Protocols**: Protocol-oriented programming for testability
- **Dependency Injection**: Builder pattern for clean dependencies

## Design Patterns

- **Clean Architecture**: Separation of concerns
- **Repository Pattern**: Data access abstraction
- **Builder Pattern**: Object construction and DI
- **Observer Pattern**: SwiftUI's @Observable
- **Strategy Pattern**: Multiple cache implementations
- **Factory Pattern**: View builders

## Contributing

1. Follow Clean Architecture principles
2. Use protocol-first design
3. Write unit tests for new features
4. Run pre-commit checks before pushing
5. Use meaningful commit messages

## License

This is a demo project for educational purposes.

## Acknowledgments

- [Rick and Morty API](https://rickandmortyapi.com/) for providing the data
- Clean Architecture principles by Robert C. Martin
- SwiftUI and UIKit communities
