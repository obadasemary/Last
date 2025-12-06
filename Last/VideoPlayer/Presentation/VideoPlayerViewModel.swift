//
//  VideoPlayerViewModel.swift
//  Last
//
//  Created by Claude Code on 06.12.2025.
//

import Foundation
import AVFoundation
import Observation
import MediaPlayer

@Observable
@MainActor
final class VideoPlayerViewModel {
    private let video: VideoEntity
    private(set) var selectedQuality: VideoEntity.VideoQuality

    private(set) var player: AVPlayer?
    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0
    private(set) var isLoading = true
    private(set) var error: VideoPlayerError?
    private(set) var availableQualities: [VideoEntity.VideoQuality] = []

    private var timeObserver: Any?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerItemDurationObserver: NSKeyValueObservation?

    init(video: VideoEntity, preferredQuality: VideoEntity.VideoQuality? = nil) {
        self.video = video
        self.availableQualities = video.qualities
        self.selectedQuality = preferredQuality ?? video.qualities.first ?? .medium(video.url)
    }

    func loadVideo() async {
        isLoading = true
        error = nil

        do {
            // Use selected quality URL
            let playbackURL = selectedQuality.url

            // Create AVPlayer
            let playerItem = AVPlayerItem(url: playbackURL)
            player = AVPlayer(playerItem: playerItem)

            // Setup observers
            setupTimeObserver()
            setupPlayerItemObservers(playerItem)

            // Configure for background playback
            configureAudioSession()

            isLoading = false
        } catch {
            self.error = .loadingFailed(error)
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

        // Update Now Playing info
        updateNowPlayingInfo()
    }

    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func changeQuality(_ quality: VideoEntity.VideoQuality) async {
        guard quality != selectedQuality else { return }

        // Save current time
        let currentPlaybackTime = currentTime
        let wasPlaying = isPlaying

        // Pause current playback
        player?.pause()

        // Update quality and reload
        selectedQuality = quality
        await loadVideo()

        // Restore playback position
        seek(to: currentPlaybackTime)

        if wasPlaying {
            player?.play()
            isPlaying = true
        }
    }

    private func setupTimeObserver() {
        guard let player else { return }

        // Update current time every 0.5 seconds
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                self?.currentTime = time.seconds
            }
        }
    }

    private func setupPlayerItemObservers(_ playerItem: AVPlayerItem) {
        // Observe player item status
        playerItemStatusObserver = playerItem.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                switch item.status {
                case .readyToPlay:
                    self?.isLoading = false
                    if let duration = try? await item.asset.load(.duration) {
                        self?.duration = duration.seconds
                    }
                case .failed:
                    self?.error = .loadingFailed(item.error ?? NSError(domain: "VideoPlayer", code: -1))
                    self?.isLoading = false
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }

        // Observe duration
        playerItemDurationObserver = playerItem.observe(\.duration, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                self?.duration = item.duration.seconds
            }
        }
    }

    private func configureAudioSession() {
        do {
            // Configure audio session for background playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            // Setup Now Playing info for lock screen and control center
            setupNowPlayingInfo()
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    private func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()

        // Set video title
        nowPlayingInfo[MPMediaItemPropertyTitle] = video.title ?? "Video"

        // Set duration
        if let duration = video.duration {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        }

        // Set current playback time
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime

        // Set playback rate
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func updateNowPlayingInfo() {
        guard var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }

        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func cleanup() {
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        playerItemStatusObserver?.invalidate()
        playerItemDurationObserver?.invalidate()
        player = nil
    }

}

enum VideoPlayerError: Error, LocalizedError {
    case loadingFailed(Error)
    case downloadFailed(Error)
    case cacheError(Error)

    var errorDescription: String? {
        switch self {
        case .loadingFailed(let error):
            return "Failed to load video: \(error.localizedDescription)"
        case .downloadFailed(let error):
            return "Failed to download video: \(error.localizedDescription)"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        }
    }
}
