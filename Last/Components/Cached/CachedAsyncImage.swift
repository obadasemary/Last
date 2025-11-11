//
//  CachedAsyncImage.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 10.11.2025.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {

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
            if let cachedImage = ImageCache[url] {
                let _ = print("cached \(url.absoluteString)")
                content(.success(cachedImage))
            } else {
                let _ = print("request \(url.absoluteString)")
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
            ImageCache[url] = image
        }

        return content(phase)
    }
}

fileprivate class ImageCache {

    static private var cache: [URL: Image] = [:]

    static subscript (_ url: URL) -> Image? {
        get {
            self.cache[url]
        } set {
            self.cache[url] = newValue
        }
    }
}

#Preview {
    CachedAsyncImage(url: Constants.randomImageURL()) { phase in
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
                "No Feeds \(error.localizedDescription)",
                systemImage: "network.slash",
                description: Text("Pull to refresh")
            )
        @unknown default:
            fatalError()
        }
    }
}
