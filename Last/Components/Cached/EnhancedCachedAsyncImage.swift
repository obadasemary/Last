//
//  EnhancedCachedAsyncImage.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 11.11.2025.
//

import SwiftUI

struct EnhancedCachedAsyncImage<Content: View>: View {

    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    @ViewBuilder private let content: (AsyncImagePhase) -> Content

    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    var body: some View {
        if let url = url {
            if let cachedImage = EnhancedImageCache.shared[url] {
                let _ = print("📦 Cache hit: \(url.lastPathComponent)")
                content(.success(cachedImage))
            } else {
                let _ = print("🌐 Fetching: \(url.lastPathComponent)")
                AsyncImage(
                    url: url,
                    scale: scale,
                    transaction: transaction
                ) { phase in
                    cacheAndRender(phase: phase, url: url)
                }
            }
        } else {
            content(.failure(URLError(.badURL)))
        }
    }

    private func cacheAndRender(phase: AsyncImagePhase, url: URL) -> some View {
        if case .success(let image) = phase {
            EnhancedImageCache.shared[url] = image
        }

        return content(phase)
    }
}

/// Thread-safe image cache using NSCache with automatic memory management
final class EnhancedImageCache {

    static let shared = EnhancedImageCache()

    private let cache: NSCache<NSURL, ImageWrapper>

    private init() {
        cache = NSCache<NSURL, ImageWrapper>()
        cache.countLimit = 100 // Maximum 100 images
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB

        // Automatically clear cache on memory warning
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    subscript(url: URL) -> Image? {
        get {
            cache.object(forKey: url as NSURL)?.image
        }
        set {
            if let image = newValue {
                let wrapper = ImageWrapper(image: image)
                cache.setObject(wrapper, forKey: url as NSURL)
            } else {
                cache.removeObject(forKey: url as NSURL)
            }
        }
    }

    @objc private func clearCache() {
        cache.removeAllObjects()
        let _ = print("🧹 Image cache cleared due to memory warning")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/// Wrapper class to store SwiftUI Image in NSCache (NSCache requires reference types)
private final class ImageWrapper {
    let image: Image

    init(image: Image) {
        self.image = image
    }
}

#Preview {
    EnhancedCachedAsyncImage(url: Constants.randomImageURL()) { phase in
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
                .frame(width: 300, height: 300)
                .clipped(antialiased: true)
                .cornerRadius(16)
        case .failure(let error):
            ContentUnavailableView(
                "No Feeds",
                systemImage: "network.slash",
                description: Text("Pull to refresh")
            )
        @unknown default:
            fatalError()
        }
    }
}
