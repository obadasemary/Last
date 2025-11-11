//
//  FeedUIKitWrapper.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import SwiftUI
import UIKit

struct FeedUIKitWrapper: UIViewControllerRepresentable {
    
    let isUsingMock: Bool
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let builder = FeedUIKitBuilder()
        return builder.buildFeedUIKit(isUsingMock: isUsingMock)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}

