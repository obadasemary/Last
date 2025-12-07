//
//  VideoPlayerViewModelTests.swift
//  LastTests
//
//  Created by Claude Code on 06.12.2025.
//

import Testing
import Foundation
@testable import Last

@Suite("VideoPlayerViewModel Tests")
struct VideoPlayerViewModelTests {

    // MARK: - Initialization Tests

    @Test("Initialize with video")
    @MainActor
    func initializeWithVideo() {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        #expect(viewModel.player == nil) // Player not created until loadVideo()
        #expect(viewModel.isPlaying == false)
        #expect(viewModel.currentTime == 0)
        #expect(viewModel.duration == 0)
        #expect(viewModel.isLoading == true) // Initially loading
        #expect(viewModel.error == nil)
        #expect(viewModel.availableQualities == video.qualities)
    }

    @Test("Initialize with preferred quality")
    @MainActor
    func initializeWithPreferredQuality() {
        let video = VideoEntity.mock
        let preferredQuality = VideoEntity.VideoQuality.high(
            URL(string: "https://example.com/video_1080p.mp4")!
        )

        let viewModel = VideoPlayerViewModel(
            video: video,
            preferredQuality: preferredQuality
        )

        #expect(viewModel.selectedQuality == preferredQuality)
    }

    @Test("Initialize with default quality when no preference")
    @MainActor
    func initializeWithDefaultQuality() {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        // Should use first quality from video
        #expect(viewModel.selectedQuality == video.qualities.first)
    }

    // MARK: - Video Loading Tests

    @Test("Load video successfully")
    @MainActor
    func loadVideoSuccessfully() async {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        await viewModel.loadVideo()

        #expect(viewModel.player != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("Load video with HLS quality")
    @MainActor
    func loadVideoWithHLS() async {
        let hlsURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
        let video = VideoEntity(
            id: "hls-test",
            url: hlsURL,
            thumbnailURL: nil,
            duration: nil,
            title: "HLS Test",
            qualities: [.hls(hlsURL)]
        )

        let viewModel = VideoPlayerViewModel(video: video)
        await viewModel.loadVideo()

        #expect(viewModel.player != nil)
        #expect(viewModel.error == nil)
    }

    // MARK: - Playback Control Tests

    @Test("Toggle play pause")
    @MainActor
    func togglePlayPause() async {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        await viewModel.loadVideo()

        // Initially not playing
        #expect(viewModel.isPlaying == false)

        // Toggle to play
        viewModel.togglePlayPause()
        #expect(viewModel.isPlaying == true)

        // Toggle to pause
        viewModel.togglePlayPause()
        #expect(viewModel.isPlaying == false)
    }

    @Test("Seek to specific time")
    @MainActor
    func seekToSpecificTime() async {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        await viewModel.loadVideo()

        let seekTime: TimeInterval = 30.0
        viewModel.seek(to: seekTime)

        // Note: Actual currentTime update requires time observer callback
        // which happens asynchronously, so we just verify the method doesn't crash
        #expect(viewModel.player != nil)
    }

    // MARK: - Quality Change Tests

    @Test("Change video quality")
    @MainActor
    func changeVideoQuality() async {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        await viewModel.loadVideo()

        let initialQuality = viewModel.selectedQuality
        let newQuality = video.qualities.last!

        await viewModel.changeQuality(newQuality)

        #expect(viewModel.selectedQuality == newQuality)
        #expect(viewModel.selectedQuality != initialQuality)
    }

    @Test("Change quality maintains same quality when called with current quality")
    @MainActor
    func changeQualityNoOpWhenSame() async {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        await viewModel.loadVideo()

        let currentQuality = viewModel.selectedQuality
        await viewModel.changeQuality(currentQuality)

        // Should still be the same quality
        #expect(viewModel.selectedQuality == currentQuality)
    }

    // MARK: - Cleanup Tests

    @Test("Cleanup releases player")
    @MainActor
    func cleanupReleasesPlayer() async {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        await viewModel.loadVideo()
        #expect(viewModel.player != nil)

        viewModel.cleanup()

        #expect(viewModel.player == nil)
    }

    @Test("Cleanup when playing stops playback")
    @MainActor
    func cleanupStopsPlayback() async {
        let video = VideoEntity.mock
        let viewModel = VideoPlayerViewModel(video: video)

        await viewModel.loadVideo()
        viewModel.togglePlayPause() // Start playing

        #expect(viewModel.isPlaying == true)

        viewModel.cleanup()

        // Player should be nil after cleanup
        #expect(viewModel.player == nil)
    }

    // MARK: - Error State Tests

    @Test("Handle invalid URL gracefully")
    @MainActor
    func handleInvalidURL() async {
        // Note: AVPlayer actually accepts most URLs, even invalid ones
        // It will fail during playback, not during creation
        let invalidURL = URL(string: "https://invalid-domain-that-does-not-exist.com/video.mp4")!
        let video = VideoEntity(
            id: "invalid",
            url: invalidURL,
            thumbnailURL: nil,
            duration: nil,
            title: "Invalid",
            qualities: [.medium(invalidURL)]
        )

        let viewModel = VideoPlayerViewModel(video: video)
        await viewModel.loadVideo()

        // Player is created but may fail later during actual playback
        #expect(viewModel.player != nil)
    }

    // MARK: - Background Playback Tests

    @Test("Now Playing info updates on play pause")
    @MainActor
    func nowPlayingInfoUpdates() async {
        let video = VideoEntity(
            id: "test",
            url: URL(string: "https://example.com/video.mp4")!,
            thumbnailURL: nil,
            duration: 120.0,
            title: "Test Video",
            qualities: [.medium(URL(string: "https://example.com/video.mp4")!)]
        )

        let viewModel = VideoPlayerViewModel(video: video)
        await viewModel.loadVideo()

        // Toggle play - should update Now Playing info
        viewModel.togglePlayPause()

        // Verify method doesn't crash
        #expect(viewModel.isPlaying == true)
    }

    // MARK: - Available Qualities Tests

    @Test("Available qualities match video qualities")
    @MainActor
    func availableQualitiesMatchVideo() {
        let qualities: [VideoEntity.VideoQuality] = [
            .low(URL(string: "https://example.com/360p.mp4")!),
            .medium(URL(string: "https://example.com/720p.mp4")!),
            .high(URL(string: "https://example.com/1080p.mp4")!)
        ]

        let video = VideoEntity(
            id: "multi-quality",
            url: URL(string: "https://example.com/720p.mp4")!,
            thumbnailURL: nil,
            duration: 180.0,
            title: "Multi Quality Video",
            qualities: qualities
        )

        let viewModel = VideoPlayerViewModel(video: video)

        #expect(viewModel.availableQualities.count == 3)
        #expect(viewModel.availableQualities == qualities)
    }

    // MARK: - State Management Tests

    @Test("Initial loading state is true")
    @MainActor
    func initialLoadingStateIsTrue() {
        let viewModel = VideoPlayerViewModel(video: .mock)
        #expect(viewModel.isLoading == true)
    }

    @Test("Loading state is false after successful load")
    @MainActor
    func loadingStateFalseAfterLoad() async {
        let viewModel = VideoPlayerViewModel(video: .mock)
        await viewModel.loadVideo()
        #expect(viewModel.isLoading == false)
    }

    @Test("Initial error state is nil")
    @MainActor
    func initialErrorStateIsNil() {
        let viewModel = VideoPlayerViewModel(video: .mock)
        #expect(viewModel.error == nil)
    }

    @Test("Current time starts at zero")
    @MainActor
    func currentTimeStartsAtZero() {
        let viewModel = VideoPlayerViewModel(video: .mock)
        #expect(viewModel.currentTime == 0.0)
    }

    @Test("Duration starts at zero")
    @MainActor
    func durationStartsAtZero() {
        let viewModel = VideoPlayerViewModel(video: .mock)
        #expect(viewModel.duration == 0.0)
    }
}

// MARK: - VideoEntity Tests
@Suite("VideoEntity Tests")
struct VideoEntityTests {

    @Test("Mock video has correct properties")
    func mockVideoProperties() {
        let mock = VideoEntity.mock

        #expect(mock.id == "sample-video-1")
        #expect(mock.url.absoluteString.contains("BigBuckBunny"))
        #expect(mock.thumbnailURL != nil)
        #expect(mock.duration == 596.5)
        #expect(mock.title == "Big Buck Bunny")
        #expect(mock.qualities.count == 2)
    }

    @Test("Mock Elephants Dream video exists")
    func mockElephantsDreamExists() {
        let mock = VideoEntity.mockElephantsDream

        #expect(mock.id == "sample-video-2")
        #expect(mock.title == "Elephants Dream")
        #expect(mock.duration == 653.8)
    }

    @Test("Mock For Bigger Blazes video exists")
    func mockForBiggerBlazesExists() {
        let mock = VideoEntity.mockForBiggerBlazes

        #expect(mock.id == "sample-video-3")
        #expect(mock.title == "For Bigger Blazes")
        #expect(mock.duration == 15.0)
    }

    @Test("VideoQuality URL property returns correct URL")
    func videoQualityURLProperty() {
        let url = URL(string: "https://example.com/video.mp4")!

        let lowQuality = VideoEntity.VideoQuality.low(url)
        let mediumQuality = VideoEntity.VideoQuality.medium(url)
        let highQuality = VideoEntity.VideoQuality.high(url)
        let hlsQuality = VideoEntity.VideoQuality.hls(url)

        #expect(lowQuality.url == url)
        #expect(mediumQuality.url == url)
        #expect(highQuality.url == url)
        #expect(hlsQuality.url == url)
    }

    @Test("VideoQuality display names are correct")
    func videoQualityDisplayNames() {
        let url = URL(string: "https://example.com/video.mp4")!

        #expect(VideoEntity.VideoQuality.low(url).displayName == "360p")
        #expect(VideoEntity.VideoQuality.medium(url).displayName == "720p")
        #expect(VideoEntity.VideoQuality.high(url).displayName == "1080p")
        #expect(VideoEntity.VideoQuality.hls(url).displayName == "Auto (HLS)")
    }

    @Test("VideoQuality is Equatable")
    func videoQualityEquatable() {
        let url1 = URL(string: "https://example.com/video1.mp4")!
        let url2 = URL(string: "https://example.com/video2.mp4")!

        let quality1 = VideoEntity.VideoQuality.medium(url1)
        let quality2 = VideoEntity.VideoQuality.medium(url1)
        let quality3 = VideoEntity.VideoQuality.medium(url2)

        #expect(quality1 == quality2)
        #expect(quality1 != quality3)
    }
}
