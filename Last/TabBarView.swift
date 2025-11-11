//
//  TabBarView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var feedBuilder = FeedBuilder()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // First Tab: SwiftUI FeedView
            feedBuilder.buildFeedView()
                .tabItem {
                    Label("Feed SwiftUI", systemImage: "list.bullet")
                }
                .tag(0)
            
            // Second Tab: UIKit FeedUIKit
            FeedUIKitWrapper(isUsingMock: false)
                .tabItem {
                    Label("Feed UIKit", systemImage: "square.grid.2x2")
                }
                .tag(1)
        }
    }
}

