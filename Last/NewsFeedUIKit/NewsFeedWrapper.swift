//
//  NewsFeedWrapper.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import SwiftUI
import UIKit

struct NewsFeedWrapper: UIViewControllerRepresentable {
    
    let isUsingMock: Bool
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let builder = NewsFeedBuilder()
        return builder.buildNewsFeed(isUsingMock: isUsingMock)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}
