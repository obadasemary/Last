//
//  VideoEntity.swift
//  Last
//
//  Created by Claude Code on 06.12.2025.
//

import Foundation

struct VideoEntity: Decodable, Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let url: URL
    let thumbnailURL: URL?
    let duration: TimeInterval?
    let title: String?
    let qualities: [VideoQuality]

    enum VideoQuality: Equatable, Hashable, Sendable {
        case low(URL)      // 360p
        case medium(URL)   // 720p
        case high(URL)     // 1080p
        case hls(URL)      // Adaptive streaming

        var url: URL {
            switch self {
            case .low(let url), .medium(let url), .high(let url), .hls(let url):
                return url
            }
        }

        var displayName: String {
            switch self {
            case .low: return "360p"
            case .medium: return "720p"
            case .high: return "1080p"
            case .hls: return "Auto (HLS)"
            }
        }
    }
}

// MARK: - VideoQuality Decodable Implementation
extension VideoEntity.VideoQuality: Decodable {
    enum CodingKeys: String, CodingKey {
        case type
        case url
    }

    enum QualityType: String, Decodable {
        case low, medium, high, hls
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(QualityType.self, forKey: .type)
        let url = try container.decode(URL.self, forKey: .url)

        switch type {
        case .low:
            self = .low(url)
        case .medium:
            self = .medium(url)
        case .high:
            self = .high(url)
        case .hls:
            self = .hls(url)
        }
    }
}

// MARK: - Mock Data
extension VideoEntity {
    static let mock = VideoEntity(
        id: "sample-video-1",
        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
        thumbnailURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg"),
        duration: 596.5,
        title: "Big Buck Bunny",
        qualities: [
            .medium(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!),
            .hls(URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!)
        ]
    )

    static let mockElephantsDream = VideoEntity(
        id: "sample-video-2",
        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
        thumbnailURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg"),
        duration: 653.8,
        title: "Elephants Dream",
        qualities: [
            .medium(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!)
        ]
    )

    static let mockForBiggerBlazes = VideoEntity(
        id: "sample-video-3",
        url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
        thumbnailURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg"),
        duration: 15.0,
        title: "For Bigger Blazes",
        qualities: [
            .medium(URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!)
        ]
    )
}
