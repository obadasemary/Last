//
//  TabBarView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import SwiftUI

struct TabBarView: View {

    @State private var feedBuilder = FeedBuilder()
    @State private var newsFeedBuilder = NewsFeedSwiftUIBuilder()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // First Tab: SwiftUI FeedView
            feedBuilder.buildFeedView()
                .tabItem {
                    Label("Characters", systemImage: "person.2")
                }
                .tag(0)

            // Second Tab: News Feed SwiftUI
            newsFeedBuilder.buildNewsFeedView()
                .tabItem {
                    Label("Episodes", systemImage: "film")
                }
                .tag(1)

            // Third Tab: UIKit FeedUIKit
            FeedUIKitWrapper(isUsingMock: false)
                .tabItem {
                    Label("Feed UIKit", systemImage: "square.grid.2x2")
                }
                .tag(2)

            // Fourth Tab: News Feed (UIKit)
            NewsFeedWrapper(isUsingMock: false)
                .tabItem {
                    Label("News UIKit", systemImage: "newspaper")
                }
                .tag(3)
        }
    }
}

