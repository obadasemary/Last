//
//  VideoPlayerView.swift
//  Last
//
//  Created by Claude Code on 06.12.2025.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State var viewModel: VideoPlayerViewModel
    @State private var isShowingControls = true
    @State private var controlsTimer: Timer?
    @State private var playerViewController: AVPlayerViewController?

    var body: some View {
        ZStack {
            Color.black

            // Video player layer with PiP support
            if let player = viewModel.player {
                AVPlayerViewControllerWrapper(
                    player: player,
                    allowsPictureInPicturePlayback: true,
                    showsPlaybackControls: false
                )
            }

            // Tap overlay to show controls
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingControls = true
                    resetControlsTimer()
                }

            // Custom controls overlay
            VideoControlsView(
                isPlaying: viewModel.isPlaying,
                currentTime: viewModel.currentTime,
                duration: viewModel.duration,
                availableQualities: viewModel.availableQualities,
                selectedQuality: viewModel.selectedQuality,
                isShowingControls: $isShowingControls,
                onPlayPause: {
                    viewModel.togglePlayPause()
                    isShowingControls = true
                    resetControlsTimer()
                },
                onSeek: { time in
                    viewModel.seek(to: time)
                    isShowingControls = true
                    resetControlsTimer()
                },
                onQualityChange: { quality in
                    await viewModel.changeQuality(quality)
                },
                onPiPToggle: nil  // PiP is automatically handled by AVPlayerViewController
            )

            // Loading overlay
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.5)

                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }

            // Error overlay
            if let error = viewModel.error {
                VideoErrorView(error: error) {
                    await viewModel.loadVideo()
                }
            }
        }
        .task {
            await viewModel.loadVideo()
            startControlsTimer()
        }
        .onDisappear {
            viewModel.cleanup()
            stopControlsTimer()
        }
    }

    private func toggleControls() {
        isShowingControls.toggle()
        if isShowingControls {
            resetControlsTimer()
        } else {
            stopControlsTimer()
        }
    }

    private func startControlsTimer() {
        // Only hide controls if video is playing
        guard viewModel.isPlaying else { return }

        controlsTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            if viewModel.isPlaying {
                isShowingControls = false
            }
        }
    }

    private func resetControlsTimer() {
        stopControlsTimer()
        // Keep controls visible when paused
        if viewModel.isPlaying {
            startControlsTimer()
        } else {
            isShowingControls = true
        }
    }

    private func stopControlsTimer() {
        controlsTimer?.invalidate()
        controlsTimer = nil
    }
}

struct VideoErrorView: View {
    let error: VideoPlayerError
    let onRetry: () async -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.yellow)

                Text(error.errorDescription ?? "An error occurred")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    Task {
                        await onRetry()
                    }
                } label: {
                    Text("Retry")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
            .padding()
        }
    }
}

#Preview {
    VideoPlayerView(
        viewModel: VideoPlayerViewModel(video: .mock)
    )
}

#Preview("With HLS") {
    VideoPlayerView(
        viewModel: VideoPlayerViewModel(
            video: VideoEntity(
                id: "hls-sample",
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!,
                thumbnailURL: nil,
                duration: nil,
                title: "HLS Sample",
                qualities: [
                    .hls(URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!)
                ]
            )
        )
    )
}
