//
//  EnhancedCachedAsyncImageWithDI.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 11.11.2025.
//

import SwiftUI

/// Enhanced cached async image using Dependency Injection
/// Caches image data for better performance and memory efficiency
struct EnhancedCachedAsyncImageWithDI<Content: View>: View {

    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let dataCache: ImageDataCacheProtocol
    @ViewBuilder private let content: (AsyncImagePhase) -> Content

    @State private var imagePhase: AsyncImagePhase = .empty

    /// Initialize with dependency injection
    /// - Parameters:
    ///   - url: The URL to load the image from
    ///   - scale: The scale of the image (default: 1.0)
    ///   - transaction: Transaction for animations (default: Transaction())
    ///   - dataCache: The data cache manager to use (injected for testability)
    ///   - content: View builder for rendering different phases
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        dataCache: ImageDataCacheProtocol = ImageDataCacheManager(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.dataCache = dataCache
        self.content = content
    }

    var body: some View {
        content(imagePhase)
            .task(id: url) {
                await loadImage()
            }
    }

    private func loadImage() async {
        guard let url = url else {
            imagePhase = .failure(URLError(.badURL))
            return
        }

        // Check cache first
        if let cachedData = dataCache.getFromCache(forURL: url),
           let uiImage = UIImage(data: cachedData) {
            withTransaction(transaction) {
                imagePhase = .success(Image(uiImage: uiImage))
            }
            return
        }

        // Fetch from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            guard let uiImage = UIImage(data: data) else {
                withTransaction(transaction) {
                    imagePhase = .failure(URLError(.cannotDecodeContentData))
                }
                return
            }

            // Cache the data
            dataCache.addToCache(data: data, forURL: url)

            // Update UI
            withTransaction(transaction) {
                imagePhase = .success(Image(uiImage: uiImage))
            }
        } catch {
            withTransaction(transaction) {
                imagePhase = .failure(error)
            }
        }
    }
}

// MARK: - Preview

#Preview("With Custom Cache") {
    let customCache = ImageDataCacheManager(
        countLimit: 50,
        totalCostLimit: 50 * 1024 * 1024
    )

    return EnhancedCachedAsyncImageWithDI(
        url: Constants.randomImageURL(),
        dataCache: customCache
    ) { phase in
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 300)
                .clipped()
                .cornerRadius(16)
        case .failure:
            ContentUnavailableView(
                "Failed to Load",
                systemImage: "network.slash",
                description: Text("Pull to refresh")
            )
        @unknown default:
            fatalError()
        }
    }
}

#Preview("Default Cache") {
    EnhancedCachedAsyncImageWithDI(
        url: Constants.randomImageURL()
    ) { phase in
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 300)
                .clipped()
                .cornerRadius(16)
        case .failure:
            ContentUnavailableView(
                "Failed to Load",
                systemImage: "network.slash",
                description: Text("Pull to refresh")
            )
        @unknown default:
            fatalError()
        }
    }
}
