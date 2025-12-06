//
//  VideoControlsView.swift
//  Last
//
//  Created by Claude Code on 06.12.2025.
//

import SwiftUI

struct VideoControlsView: View {
    let isPlaying: Bool
    let currentTime: TimeInterval
    let duration: TimeInterval
    let availableQualities: [VideoEntity.VideoQuality]
    let selectedQuality: VideoEntity.VideoQuality
    @Binding var isShowingControls: Bool
    let onPlayPause: () -> Void
    let onSeek: (TimeInterval) -> Void
    let onQualityChange: (VideoEntity.VideoQuality) async -> Void
    let onPiPToggle: (() -> Void)?

    @State private var isShowingQualityPicker = false

    var body: some View {
        ZStack {
            if isShowingControls {
                VStack {
                    // Top controls
                    topControls

                    Spacer()

                    // Center play/pause button
                    centerPlayButton

                    Spacer()

                    // Bottom controls
                    bottomControls
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isShowingControls)
    }

    private var topControls: some View {
        HStack {
            Spacer()

            HStack(spacing: 12) {
                // PiP button
                if let onPiPToggle = onPiPToggle {
                    Button {
                        onPiPToggle()
                    } label: {
                        Image(systemName: "pip.enter")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }

                // Quality selector
                if availableQualities.count > 1 {
                    Button {
                        isShowingQualityPicker.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "gear")
                            Text(selectedQuality.displayName)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .confirmationDialog("Select Quality", isPresented: $isShowingQualityPicker) {
                        ForEach(availableQualities, id: \.self) { quality in
                            Button(quality.displayName) {
                                Task {
                                    await onQualityChange(quality)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }

    private var centerPlayButton: some View {
        Button(action: onPlayPause) {
            ZStack {
                Circle()
                    .fill(.black.opacity(0.5))
                    .frame(width: 80, height: 80)

                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 8)
        }
        .buttonStyle(.plain)
    }

    private var bottomControls: some View {
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

            // Time labels and controls
            HStack {
                Text(formatTime(currentTime))
                    .font(.caption)
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Spacer()

                Text(formatTime(duration))
                    .font(.caption)
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "0:00" }

        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if totalSeconds >= 3600 {
            let hours = totalSeconds / 3600
            let remainingMinutes = (totalSeconds % 3600) / 60
            return String(format: "%d:%02d:%02d", hours, remainingMinutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    ZStack {
        Color.black

        VideoControlsView(
            isPlaying: true,
            currentTime: 125.5,
            duration: 596.5,
            availableQualities: [
                .low(URL(string: "https://example.com")!),
                .medium(URL(string: "https://example.com")!),
                .high(URL(string: "https://example.com")!)
            ],
            selectedQuality: .medium(URL(string: "https://example.com")!),
            isShowingControls: .constant(true),
            onPlayPause: {},
            onSeek: { _ in },
            onQualityChange: { _ in },
            onPiPToggle: {}
        )
    }
}
