//
//  AVPlayerViewControllerWrapper.swift
//  Last
//
//  Created by Claude Code on 06.12.2025.
//

import SwiftUI
import AVKit

struct AVPlayerViewControllerWrapper: UIViewControllerRepresentable {
    let player: AVPlayer
    let allowsPictureInPicturePlayback: Bool
    let showsPlaybackControls: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        controller.showsPlaybackControls = showsPlaybackControls

        // Enable playback controls gestures
        controller.canStartPictureInPictureAutomaticallyFromInline = true

        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
        uiViewController.allowsPictureInPicturePlayback = allowsPictureInPicturePlayback
        uiViewController.showsPlaybackControls = showsPlaybackControls
    }
}
