//
//  ImageLoaderView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import SwiftUI

struct ImageLoaderView: View {
    
    let url: URL?
    let imageSize: CGFloat
    
    init(url: URL?, imageSize: CGFloat = 100) {
        self.url = url
        self.imageSize = imageSize
    }
    
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.quinary)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failure:
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.quinary)
            @unknown default:
                EmptyView()
            }
        }

    }
}

#Preview {
    ImageLoaderView(
        url: URL(
            string: "https://picsum.photos/600/600"
        )
    )
}
