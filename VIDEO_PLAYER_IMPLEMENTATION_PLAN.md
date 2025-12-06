# Video Player Implementation Plan

## Executive Summary

This document outlines the complete implementation plan for adding Instagram/YouTube-style video playback capabilities to the Last iOS application. The implementation follows Clean Architecture principles and includes:

- AVPlayer-based video playback with custom controls
- Offline video downloads with HLS chunk support
- Video caching and storage management
- Picture-in-Picture and background playback
- Progressive download with quality selection

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Domain Layer](#domain-layer)
3. [Data Layer](#data-layer)
4. [Presentation Layer](#presentation-layer)
5. [Implementation Phases](#implementation-phases)
6. [File Structure](#file-structure)
7. [Technical Decisions](#technical-decisions)
8. [Testing Strategy](#testing-strategy)
9. [Performance Considerations](#performance-considerations)
10. [Open Questions](#open-questions)

---

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  VideoPlayerView, VideoPlayerViewModel, VideoPlayerBuilder  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│     VideoPlayerUseCase, VideoDownloadUseCase, VideoEntity   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│   VideoRepository, VideoDownloadManager, VideoCacheManager  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Infrastructure                            │
│      AVPlayer, AVAssetDownloadTask, FileManager, SwiftData  │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Flow

```
FeedDetailsView
    → FeedDetailsViewModel
        → VideoPlayerUseCase (protocol)
            → VideoRepository (protocol)
                → VideoDownloadManager
                → VideoCacheManager
                    → FileManager/SwiftData
```

---

## Domain Layer

### 1. VideoEntity.swift

**Purpose**: Domain model for video data

```swift
struct VideoEntity: Decodable, Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let url: URL
    let thumbnailURL: URL?
    let duration: TimeInterval?
    let title: String?

    // Video quality options
    let qualities: [VideoQuality]

    enum VideoQuality: Decodable, Sendable {
        case low(URL)      // 360p
        case medium(URL)   // 720p
        case high(URL)     // 1080p
        case hls(URL)      // Adaptive streaming
    }
}

struct VideoMetadata: Codable, Sendable {
    let id: String
    let downloadDate: Date
    let fileSize: Int64
    let localURL: URL
    let quality: VideoEntity.VideoQuality
    let isFullyDownloaded: Bool
}
```

### 2. VideoPlayerUseCaseProtocol.swift

**Purpose**: Business logic for video playback

```swift
protocol VideoPlayerUseCaseProtocol: Sendable {
    /// Load video metadata and prepare for playback
    func loadVideo(id: String) async throws -> VideoEntity

    /// Get local cached video if available
    func getCachedVideo(id: String) async -> URL?

    /// Check if video is available offline
    func isVideoAvailableOffline(id: String) async -> Bool

    /// Get playback URL (local if cached, remote otherwise)
    func getPlaybackURL(for video: VideoEntity) async -> URL
}
```

### 3. VideoDownloadUseCaseProtocol.swift

**Purpose**: Business logic for downloads

```swift
protocol VideoDownloadUseCaseProtocol: Sendable {
    /// Start downloading a video
    func downloadVideo(_ video: VideoEntity, quality: VideoEntity.VideoQuality) async throws

    /// Cancel ongoing download
    func cancelDownload(id: String)

    /// Get download progress for a video
    func getDownloadProgress(id: String) -> AsyncStream<DownloadProgress>

    /// Get all downloaded videos
    func getDownloadedVideos() async -> [VideoMetadata]

    /// Delete downloaded video
    func deleteDownload(id: String) async throws
}

struct DownloadProgress: Sendable {
    let videoId: String
    let progress: Double // 0.0 to 1.0
    let downloadedBytes: Int64
    let totalBytes: Int64
    let state: DownloadState

    enum DownloadState: Sendable {
        case waiting
        case downloading
        case paused
        case completed
        case failed(Error)
    }
}
```

---

## Data Layer

### 1. VideoRepositoryProtocol.swift

**Purpose**: Data access abstraction

```swift
protocol VideoRepositoryProtocol: Sendable {
    /// Fetch video metadata from remote
    func fetchVideo(id: String) async throws -> VideoEntity

    /// Get cached video URL
    func getCachedVideoURL(id: String) async -> URL?

    /// Save video to cache
    func cacheVideo(id: String, from url: URL) async throws -> URL

    /// Remove video from cache
    func removeCachedVideo(id: String) async throws

    /// Get all cached videos metadata
    func getAllCachedVideos() async -> [VideoMetadata]
}
```

### 2. VideoRepository.swift

**Purpose**: Concrete implementation of repository

```swift
final class VideoRepository: VideoRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let cacheManager: VideoCacheManagerProtocol
    private let downloadManager: VideoDownloadManagerProtocol

    init(
        networkService: NetworkServiceProtocol,
        cacheManager: VideoCacheManagerProtocol,
        downloadManager: VideoDownloadManagerProtocol
    ) {
        self.networkService = networkService
        self.cacheManager = cacheManager
        self.downloadManager = downloadManager
    }

    // Implementation...
}
```

### 3. VideoCacheManagerProtocol.swift

**Purpose**: Video caching layer

```swift
protocol VideoCacheManagerProtocol: Sendable {
    /// Save video file to cache
    func saveVideo(id: String, data: Data, metadata: VideoMetadata) async throws -> URL

    /// Get cached video URL
    func getVideoURL(id: String) async -> URL?

    /// Get cached video metadata
    func getMetadata(id: String) async -> VideoMetadata?

    /// Remove video from cache
    func removeVideo(id: String) async throws

    /// Get total cache size
    func getCacheSize() async -> Int64

    /// Clear cache (with optional size limit)
    func clearCache(keepingSize: Int64?) async throws

    /// Get all cached videos
    func getAllCachedVideos() async -> [VideoMetadata]
}
```

### 4. VideoCacheManager.swift

**Purpose**: Implementation of caching

**Key Features**:
- LRU (Least Recently Used) eviction policy
- Maximum cache size limit (e.g., 2GB)
- Automatic cleanup when storage is low
- SwiftData for metadata storage
- FileManager for video files

```swift
final class VideoCacheManager: VideoCacheManagerProtocol {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let maxCacheSize: Int64 = 2_000_000_000 // 2GB
    private let modelContainer: ModelContainer

    init() throws {
        self.fileManager = FileManager.default
        // Create cache directory in Library/Caches/Videos
        self.cacheDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("Videos")

        try fileManager.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )

        // SwiftData setup for metadata
        self.modelContainer = try ModelContainer(
            for: CachedVideoEntity.self
        )
    }

    // Implementation with LRU eviction...
}
```

### 5. VideoDownloadManagerProtocol.swift

**Purpose**: Download management with HLS support

```swift
protocol VideoDownloadManagerProtocol: Sendable {
    /// Start download using AVAssetDownloadTask for HLS
    func downloadVideo(
        from url: URL,
        quality: VideoEntity.VideoQuality
    ) async throws -> URL

    /// Cancel download
    func cancelDownload(for url: URL)

    /// Get download progress stream
    func downloadProgress(for url: URL) -> AsyncStream<DownloadProgress>

    /// Resume paused download
    func resumeDownload(for url: URL) async throws
}
```

### 6. VideoDownloadManager.swift

**Purpose**: Implementation using AVAssetDownloadTask

**Key Features**:
- HLS chunk-based downloads using `AVAssetDownloadURLSession`
- Background download support
- Resumable downloads
- Queue management for multiple downloads
- Quality selection for HLS variants

```swift
final class VideoDownloadManager: NSObject, VideoDownloadManagerProtocol {
    private var downloadSession: AVAssetDownloadURLSession!
    private var activeDownloads: [URL: AVAssetDownloadTask] = [:]
    private var progressHandlers: [URL: AsyncStream<DownloadProgress>.Continuation] = [:]

    override init() {
        super.init()

        let configuration = URLSessionConfiguration.background(
            withIdentifier: "com.last.videodownload"
        )

        self.downloadSession = AVAssetDownloadURLSession(
            configuration: configuration,
            assetDownloadDelegate: self,
            delegateQueue: OperationQueue.main
        )
    }

    // Implementation...
}

// MARK: - AVAssetDownloadDelegate
extension VideoDownloadManager: AVAssetDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        assetDownloadTask: AVAssetDownloadTask,
        didLoad timeRange: CMTimeRange,
        totalTimeRangesLoaded loadedTimeRanges: [NSValue],
        timeRangeExpectedToLoad: CMTimeRange
    ) {
        // Progress tracking for chunked downloads
    }

    func urlSession(
        _ session: URLSession,
        assetDownloadTask: AVAssetDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // Handle completion
    }
}
```

### 7. MockVideoRepository.swift

**Purpose**: Mock for testing and previews

```swift
final class MockVideoRepository: VideoRepositoryProtocol {
    var shouldFail = false
    var mockVideos: [VideoEntity] = []

    func fetchVideo(id: String) async throws -> VideoEntity {
        if shouldFail { throw NetworkError.invalidResponse }
        return mockVideos.first ?? .mock
    }

    // Other mock implementations...
}
```

---

## Presentation Layer

### 1. VideoPlayerView.swift

**Purpose**: SwiftUI video player interface

**Features**:
- Custom video player with AVPlayer
- Play/pause, seek controls
- Volume control
- Fullscreen support
- Picture-in-Picture
- Loading states
- Error states

```swift
struct VideoPlayerView: View {
    @State var viewModel: VideoPlayerViewModel
    @State private var isShowingControls = true

    var body: some View {
        ZStack {
            // Video player layer
            VideoPlayer(player: viewModel.player) {
                // Custom overlay controls
                VideoControlsView(
                    isPlaying: viewModel.isPlaying,
                    currentTime: viewModel.currentTime,
                    duration: viewModel.duration,
                    isShowingControls: $isShowingControls,
                    onPlayPause: { viewModel.togglePlayPause() },
                    onSeek: { time in viewModel.seek(to: time) }
                )
            }
            .onTapGesture {
                isShowingControls.toggle()
            }

            // Loading overlay
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }

            // Error overlay
            if let error = viewModel.error {
                VideoErrorView(error: error) {
                    await viewModel.retry()
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await viewModel.loadVideo()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}
```

### 2. VideoPlayerViewModel.swift

**Purpose**: Video player state and logic

```swift
@Observable
final class VideoPlayerViewModel {
    private let video: VideoEntity
    private let useCase: VideoPlayerUseCaseProtocol
    private let downloadUseCase: VideoDownloadUseCaseProtocol

    private(set) var player: AVPlayer?
    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var isLoading = true
    private(set) var error: VideoPlayerError?
    private(set) var downloadProgress: Double = 0
    private(set) var isAvailableOffline = false

    private var timeObserver: Any?

    init(
        video: VideoEntity,
        useCase: VideoPlayerUseCaseProtocol,
        downloadUseCase: VideoDownloadUseCaseProtocol
    ) {
        self.video = video
        self.useCase = useCase
        self.downloadUseCase = downloadUseCase
    }

    @MainActor
    func loadVideo() async {
        isLoading = true
        error = nil

        do {
            // Check for cached version first
            let playbackURL = await useCase.getPlaybackURL(for: video)
            isAvailableOffline = await useCase.isVideoAvailableOffline(id: video.id)

            // Create AVPlayer
            let playerItem = AVPlayerItem(url: playbackURL)
            player = AVPlayer(playerItem: playerItem)

            // Setup time observer
            setupTimeObserver()

            // Get duration
            if let duration = try? await playerItem.asset.load(.duration) {
                self.duration = duration.seconds
            }

            isLoading = false
        } catch {
            self.error = VideoPlayerError.loadingFailed(error)
            isLoading = false
        }
    }

    func togglePlayPause() {
        guard let player else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }

    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func downloadForOffline(quality: VideoEntity.VideoQuality) async {
        do {
            for await progress in downloadUseCase.getDownloadProgress(id: video.id) {
                downloadProgress = progress.progress
            }
        } catch {
            self.error = VideoPlayerError.downloadFailed(error)
        }
    }

    private func setupTimeObserver() {
        guard let player else { return }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }

    func cleanup() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
    }
}

enum VideoPlayerError: Error, LocalizedError {
    case loadingFailed(Error)
    case downloadFailed(Error)
    case cacheError(Error)

    var errorDescription: String? {
        switch self {
        case .loadingFailed: return "Failed to load video"
        case .downloadFailed: return "Failed to download video"
        case .cacheError: return "Cache error occurred"
        }
    }
}
```

### 3. VideoControlsView.swift

**Purpose**: Custom playback controls overlay

```swift
struct VideoControlsView: View {
    let isPlaying: Bool
    let currentTime: TimeInterval
    let duration: TimeInterval
    @Binding var isShowingControls: Bool
    let onPlayPause: () -> Void
    let onSeek: (TimeInterval) -> Void

    var body: some View {
        VStack {
            Spacer()

            if isShowingControls {
                // Center play/pause button
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.white)
                        .shadow(radius: 8)
                }

                Spacer()

                // Bottom controls
                VStack(spacing: 12) {
                    // Timeline slider
                    Slider(
                        value: Binding(
                            get: { currentTime },
                            set: { onSeek($0) }
                        ),
                        in: 0...max(duration, 1)
                    )
                    .tint(.white)

                    // Time labels
                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.caption)
                    .foregroundStyle(.white)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
```

### 4. VideoPlayerBuilder.swift

**Purpose**: Dependency injection factory

```swift
@Observable
final class VideoPlayerBuilder {
    func buildVideoPlayerView(
        video: VideoEntity,
        isUsingMock: Bool = false
    ) -> some View {
        // Dependencies
        let networkService = NetworkService()

        let cacheManager: VideoCacheManagerProtocol = isUsingMock
            ? MockVideoCacheManager()
            : try! VideoCacheManager()

        let downloadManager: VideoDownloadManagerProtocol = isUsingMock
            ? MockVideoDownloadManager()
            : VideoDownloadManager()

        let repository: VideoRepositoryProtocol = isUsingMock
            ? MockVideoRepository()
            : VideoRepository(
                networkService: networkService,
                cacheManager: cacheManager,
                downloadManager: downloadManager
            )

        let playerUseCase = VideoPlayerUseCase(repository: repository)
        let downloadUseCase = VideoDownloadUseCase(repository: repository)

        // ViewModel
        let viewModel = VideoPlayerViewModel(
            video: video,
            useCase: playerUseCase,
            downloadUseCase: downloadUseCase
        )

        return VideoPlayerView(viewModel: viewModel)
    }
}
```

### 5. Integration with FeedDetailsView

**Update FeedDetailsView.swift** to include video player:

```swift
struct FeedDetailsView: View {
    @State var viewModel: FeedDetailsViewModel
    @Environment(VideoPlayerBuilder.self) private var videoPlayerBuilder

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Video player (if video URL exists)
                if let video = viewModel.character.video {
                    videoPlayerBuilder.buildVideoPlayerView(video: video)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Existing image view
                if let imageURL = viewModel.character.image {
                    ImageLoaderView(url: imageURL)
                        .frame(maxHeight: 400)
                        // ... existing code
                }

                // Download button for video
                if let video = viewModel.character.video {
                    Button {
                        await viewModel.downloadVideo()
                    } label: {
                        Label("Download for Offline", systemImage: "arrow.down.circle")
                    }
                }

                // ... rest of existing code
            }
        }
    }
}
```

**Update CharactersResponse** in [FeedEntity.swift](Last/UseCase/FeedEntity.swift:57):

```swift
struct CharactersResponse: Decodable, Identifiable, Equatable, Hashable, Sendable {
    let id: Int
    let name: String
    let species: String?
    let image: URL?
    let video: VideoEntity?  // NEW: Optional video
}
```

---

## Implementation Phases

### Phase 1: Basic Video Playback (Week 1)
**Goal**: Get basic video playing in FeedDetails

**Tasks**:
1. Add `VideoEntity` domain model
2. Update `CharactersResponse` with optional video field
3. Create basic `VideoPlayerView` with AVPlayer
4. Create `VideoPlayerViewModel` with play/pause
5. Create `VideoPlayerBuilder` for DI
6. Add video player to `FeedDetailsView`
7. Add mock video data for testing

**Testing**:
- Unit tests for `VideoPlayerViewModel`
- Preview with mock video data
- Manual testing with sample video URLs

**Deliverables**:
- Working video player in FeedDetails
- Basic play/pause controls
- Mock data for previews

---

### Phase 2: Download Support (Week 2)
**Goal**: Enable offline video downloads

**Tasks**:
1. Create `VideoDownloadManagerProtocol`
2. Implement `VideoDownloadManager` with `AVAssetDownloadTask`
3. Create `VideoDownloadUseCase`
4. Add download progress UI
5. Implement download queue management
6. Add cancel/resume functionality

**Testing**:
- Test download progress tracking
- Test download cancellation
- Test multiple concurrent downloads
- Test network interruption handling

**Deliverables**:
- Working download functionality
- Progress indicators
- Download management UI

---

### Phase 3: Caching Layer (Week 3)
**Goal**: Implement video caching and storage

**Tasks**:
1. Create `VideoCacheManagerProtocol`
2. Implement `VideoCacheManager` with LRU eviction
3. Add SwiftData models for metadata
4. Implement cache size management
5. Add "Available Offline" badge to UI
6. Implement automatic cache cleanup

**Testing**:
- Test LRU eviction policy
- Test cache size limits
- Test metadata persistence
- Test offline playback

**Deliverables**:
- Working video cache
- Offline playback support
- Cache management UI

---

### Phase 4: Advanced Features (Week 4)
**Goal**: Add production-ready features

**Tasks**:
1. Implement custom video controls overlay
2. Add Picture-in-Picture support
3. Add quality selection for HLS
4. Implement background audio playback
5. Add video thumbnails
6. Performance optimization
7. Error handling improvements

**Testing**:
- Test PiP transitions
- Test background playback
- Test quality switching
- Performance testing with multiple videos

**Deliverables**:
- Production-ready video player
- All advanced features working
- Comprehensive test coverage

---

## File Structure

Complete file organization:

```
Last/
├── VideoPlayer/
│   ├── Domain/
│   │   ├── VideoEntity.swift
│   │   ├── VideoPlayerUseCaseProtocol.swift
│   │   ├── VideoPlayerUseCase.swift
│   │   ├── VideoDownloadUseCaseProtocol.swift
│   │   └── VideoDownloadUseCase.swift
│   │
│   ├── Data/
│   │   ├── VideoRepositoryProtocol.swift
│   │   ├── VideoRepository.swift
│   │   ├── VideoCacheManagerProtocol.swift
│   │   ├── VideoCacheManager.swift
│   │   ├── VideoDownloadManagerProtocol.swift
│   │   ├── VideoDownloadManager.swift
│   │   ├── CachedVideoEntity.swift (SwiftData model)
│   │   └── MockVideoRepository.swift
│   │
│   ├── Presentation/
│   │   ├── VideoPlayerView.swift
│   │   ├── VideoPlayerViewModel.swift
│   │   ├── VideoPlayerBuilder.swift
│   │   ├── VideoControlsView.swift
│   │   ├── VideoErrorView.swift
│   │   └── DownloadProgressView.swift
│   │
│   └── Core/
│       ├── AVPlayerWrapper.swift
│       └── VideoPlayerError.swift
│
├── FeedDetailsView/
│   ├── FeedDetailsView.swift (UPDATED)
│   ├── FeedDetailsViewModel.swift (UPDATED)
│   └── FeedDetailsBuilder.swift (UPDATED)
│
└── UseCase/
    └── FeedEntity.swift (UPDATED - add video field)

LastTests/
├── VideoPlayerViewModelTests.swift
├── VideoDownloadManagerTests.swift
├── VideoCacheManagerTests.swift
├── VideoPlayerUseCaseTests.swift
└── MockVideoRepository.swift
```

---

## Technical Decisions

### 1. AVPlayer vs AVKit VideoPlayer

**Decision**: Use SwiftUI's `VideoPlayer` wrapper around `AVPlayer`

**Rationale**:
- Native SwiftUI integration
- Built-in PiP support
- Custom controls via overlay
- Easier state management with `@Observable`

**Alternative**: Custom UIViewRepresentable with AVPlayerLayer
- More control but more complex
- Not needed for our use case

---

### 2. Download Strategy: HLS vs Progressive

**Decision**: Support both HLS (primary) and Progressive MP4 (fallback)

**Rationale**:
- HLS provides adaptive quality and chunk downloads
- `AVAssetDownloadTask` is Apple's recommended approach
- Progressive downloads for simple MP4 files
- Better user experience with varying network conditions

**Implementation**:
```swift
enum VideoQuality {
    case low(URL)      // Direct MP4
    case medium(URL)   // Direct MP4
    case high(URL)     // Direct MP4
    case hls(URL)      // M3U8 playlist
}
```

---

### 3. Cache Storage Strategy

**Decision**: FileManager for video files + SwiftData for metadata

**Rationale**:
- Video files stored in `Library/Caches/Videos/`
- Metadata (download date, size, quality) in SwiftData
- LRU eviction based on last access time
- Maximum 2GB cache size (configurable)

**File naming**: `{videoId}_{quality}.mp4` or `{videoId}.movpkg` for HLS

---

### 4. Background Downloads

**Decision**: Use `URLSessionConfiguration.background`

**Rationale**:
- Downloads continue when app is backgrounded
- System handles network failures and retries
- Battery-efficient

**Configuration**:
```swift
let config = URLSessionConfiguration.background(
    withIdentifier: "com.last.videodownload"
)
config.isDiscretionary = false  // Download immediately
config.sessionSendsLaunchEvents = true  // Relaunch app when complete
```

---

### 5. Concurrency Model

**Decision**: Swift Concurrency (async/await) throughout

**Rationale**:
- Consistent with existing codebase
- Actor isolation for thread safety
- Structured concurrency for download streams
- `AsyncStream` for progress updates

---

### 6. Error Handling Strategy

**Decision**: Typed errors with recovery options

```swift
enum VideoPlayerError: Error {
    case networkUnavailable
    case insufficientStorage
    case videoNotFound
    case downloadFailed(underlying: Error)
    case cacheCorrupted

    var recoveryOptions: [RecoveryOption] {
        switch self {
        case .networkUnavailable:
            return [.retry, .useCache]
        case .insufficientStorage:
            return [.clearCache, .cancel]
        // ...
        }
    }
}
```

---

## Testing Strategy

### Unit Tests

**VideoPlayerViewModelTests.swift**:
```swift
@Test("Load video successfully")
@MainActor
func testLoadVideo() async throws {
    let mockUseCase = MockVideoPlayerUseCase()
    let viewModel = VideoPlayerViewModel(
        video: .mock,
        useCase: mockUseCase,
        downloadUseCase: MockVideoDownloadUseCase()
    )

    await viewModel.loadVideo()

    #expect(viewModel.player != nil)
    #expect(viewModel.isLoading == false)
    #expect(viewModel.error == nil)
}

@Test("Handle loading error")
@MainActor
func testLoadVideoError() async throws {
    let mockUseCase = MockVideoPlayerUseCase()
    mockUseCase.shouldFail = true

    let viewModel = VideoPlayerViewModel(
        video: .mock,
        useCase: mockUseCase,
        downloadUseCase: MockVideoDownloadUseCase()
    )

    await viewModel.loadVideo()

    #expect(viewModel.player == nil)
    #expect(viewModel.error != nil)
}
```

**VideoCacheManagerTests.swift**:
```swift
@Test("Save and retrieve video")
func testCacheVideo() async throws {
    let cacheManager = try VideoCacheManager()
    let videoData = Data(count: 1000)
    let metadata = VideoMetadata(
        id: "test-video",
        downloadDate: Date(),
        fileSize: 1000,
        localURL: URL(fileURLWithPath: ""),
        quality: .medium(URL(string: "https://example.com")!),
        isFullyDownloaded: true
    )

    let url = try await cacheManager.saveVideo(
        id: "test-video",
        data: videoData,
        metadata: metadata
    )

    #expect(url != nil)

    let retrieved = await cacheManager.getVideoURL(id: "test-video")
    #expect(retrieved == url)
}

@Test("LRU eviction when cache is full")
func testLRUEviction() async throws {
    // Test implementation
}
```

**VideoDownloadManagerTests.swift**:
```swift
@Test("Download progress updates")
func testDownloadProgress() async throws {
    let manager = VideoDownloadManager()
    let videoURL = URL(string: "https://example.com/video.mp4")!

    var progressUpdates: [Double] = []

    for await progress in manager.downloadProgress(for: videoURL) {
        progressUpdates.append(progress.progress)
        if progress.state == .completed {
            break
        }
    }

    #expect(progressUpdates.count > 0)
    #expect(progressUpdates.last == 1.0)
}
```

### Integration Tests

Test complete flow from UI to cache:
```swift
@Test("Complete download and offline playback flow")
@MainActor
func testCompleteFlow() async throws {
    let builder = VideoPlayerBuilder()
    let video = VideoEntity.mock

    // Build view with real dependencies
    let view = builder.buildVideoPlayerView(video: video, isUsingMock: false)

    // Trigger download
    // Verify offline availability
    // Test playback from cache
}
```

### Manual Testing Checklist

- [ ] Play video from network
- [ ] Download video for offline
- [ ] Play downloaded video offline
- [ ] Cancel download mid-progress
- [ ] Resume cancelled download
- [ ] Test with poor network conditions
- [ ] Test cache eviction with multiple videos
- [ ] Test PiP mode
- [ ] Test background playback
- [ ] Test quality switching for HLS
- [ ] Test with various video formats (MP4, M3U8)
- [ ] Test memory usage with long videos
- [ ] Test battery impact during download

---

## Performance Considerations

### 1. Memory Management

**Strategies**:
- Release AVPlayer when view disappears
- Use `@MainActor` for UI-related properties only
- Stream downloads instead of loading into memory
- Lazy loading for video thumbnails

**Implementation**:
```swift
func cleanup() {
    player?.pause()
    player?.replaceCurrentItem(with: nil)
    player = nil
}
```

### 2. Network Optimization

**Strategies**:
- Prefetch video metadata on cell appearance
- Use HLS for adaptive bitrate streaming
- Cache video thumbnails separately
- Implement request coalescing for same videos

### 3. Storage Optimization

**Strategies**:
- Compress videos using H.264/H.265
- Implement smart cache eviction (LRU)
- Monitor system storage and auto-cleanup
- Store thumbnails in lower resolution

### 4. Battery Optimization

**Strategies**:
- Use `isDiscretionary = true` for non-urgent downloads
- Pause downloads when battery is low
- Reduce quality automatically on battery saver mode
- Stop downloads when thermal state is critical

**Implementation**:
```swift
NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)
    .sink { _ in
        if ProcessInfo.processInfo.thermalState == .critical {
            pauseAllDownloads()
        }
    }
```

---

## Open Questions

### Questions for Product/Design

1. **Video Source Integration**
   - Will videos come from Rick and Morty API or separate endpoint?
   - Should we add a dedicated video API endpoint?
   - What's the expected API response format?

2. **UX Behavior**
   - Should videos auto-play when scrolling (like Instagram)?
   - Should videos auto-play with sound on/off by default?
   - Should we show video in place of image or alongside?
   - Should we have a dedicated "Videos" tab?

3. **Download Limits**
   - Maximum number of videos that can be downloaded?
   - Maximum storage allocation for videos?
   - Should we warn users before large downloads on cellular?

4. **Quality Settings**
   - Should users manually select quality or auto-detect?
   - Default quality for auto-download?
   - Should we download lower quality on cellular?

### Technical Questions

1. **Video Format Support**
   - Do we need to support both HLS and MP4?
   - What video codecs should we support?
   - Do we need to transcode videos?

2. **Analytics Requirements**
   - Should we track video play duration?
   - Should we track download completion rates?
   - Should we track quality selection preferences?

3. **Offline Behavior**
   - Should downloaded videos expire after X days?
   - Should we auto-delete watched videos?
   - How to handle video updates/removals?

4. **Feature Flags**
   - Should video player be behind a feature flag?
   - Should downloads be separately controlled?
   - Should PiP be optional?

---

## Next Steps

Once you've reviewed this plan and answered the open questions, we can proceed with:

1. **Review & Approve**: Review this plan and provide feedback
2. **Answer Questions**: Address the open questions above
3. **Start Phase 1**: Begin implementation with basic video playback
4. **Iterate**: Gather feedback after each phase

**Estimated Timeline**:
- Phase 1 (Basic Playback): 1 week
- Phase 2 (Downloads): 1 week
- Phase 3 (Caching): 1 week
- Phase 4 (Advanced): 1 week
- **Total**: ~4 weeks for complete implementation

---

## Appendix: Code Samples

### Sample Video Entity Mock Data

```swift
extension VideoEntity {
    static let mock = VideoEntity(
        id: "sample-video-1",
        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
        thumbnailURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg"),
        duration: 596.5,
        title: "Big Buck Bunny",
        qualities: [
            .low(URL(string: "https://example.com/video_360p.mp4")!),
            .medium(URL(string: "https://example.com/video_720p.mp4")!),
            .high(URL(string: "https://example.com/video_1080p.mp4")!),
            .hls(URL(string: "https://example.com/video.m3u8")!)
        ]
    )
}
```

### Sample Info.plist Additions

Required permissions and background modes:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to save videos to your photo library</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>processing</string>
</array>

<key>AVAllowsBackgroundAudioPlayback</key>
<true/>
```

---

## Document Version

- **Version**: 1.0
- **Last Updated**: 2025-12-06
- **Author**: Claude Code
- **Status**: Draft - Awaiting Review
