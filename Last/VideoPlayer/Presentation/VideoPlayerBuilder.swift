//
//  VideoPlayerBuilder.swift
//  Last
//
//  Created by Claude Code on 06.12.2025.
//

import Foundation
import SwiftUI

@Observable
final class VideoPlayerBuilder {
    func buildVideoPlayerView(video: VideoEntity) -> some View {
        let viewModel = VideoPlayerViewModel(video: video)
        return VideoPlayerView(viewModel: viewModel)
    }
}
