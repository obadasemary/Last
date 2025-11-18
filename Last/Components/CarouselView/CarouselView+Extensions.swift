//
//  CarouselView+Extensions.swift
//  Last
//
//  Enhanced functionality for CarouselView
//

import SwiftUI

extension CarouselView {

    // MARK: - Computed Properties

    /// Returns the total number of items in the carousel
    var itemCount: Int {
        characters.count
    }

    // MARK: - Factory Methods

    /// Creates a CarouselView with auto-scrolling capability
    /// - Parameters:
    ///   - characters: The characters to display
    ///   - interval: Time interval between auto-scrolls (in seconds)
    /// - Returns: A view with auto-scrolling enabled
    static func autoScrolling(
        characters: [CharactersResponse],
        interval: TimeInterval = 3.0
    ) -> some View {
        AutoScrollingCarouselView(
            characters: characters,
            scrollInterval: interval
        )
    }
}

// MARK: - Auto-Scrolling Carousel

/// A carousel view that automatically scrolls through items
private struct AutoScrollingCarouselView: View {
    let characters: [CharactersResponse]
    let scrollInterval: TimeInterval

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @State private var currentIndex = 0
    @State private var timer: Timer?

    var body: some View {
        CarouselView(characters: characters)
            .onAppear {
                startAutoScroll()
            }
            .onDisappear {
                stopAutoScroll()
            }
    }

    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { _ in
            withAnimation {
                currentIndex = (currentIndex + 1) % characters.count
            }
        }
    }

    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Carousel Navigation Helpers

extension CarouselView {

    /// Returns a view with custom navigation controls
    /// - Parameter showControls: Whether to show previous/next buttons
    /// - Returns: A view with navigation controls
    func withNavigationControls(showControls: Bool = true) -> some View {
        CarouselViewWithControls(
            characters: characters,
            showControls: showControls
        )
    }
}

/// A carousel view with previous/next navigation controls
private struct CarouselViewWithControls: View {
    let characters: [CharactersResponse]
    let showControls: Bool

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @State private var currentIndex = 0

    var body: some View {
        VStack {
            CarouselView(characters: characters)

            if showControls && !characters.isEmpty {
                HStack(spacing: 20) {
                    Button(action: previousItem) {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .disabled(currentIndex == 0)
                    .opacity(currentIndex == 0 ? 0.5 : 1.0)

                    Text("\(currentIndex + 1) of \(characters.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button(action: nextItem) {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .disabled(currentIndex == characters.count - 1)
                    .opacity(currentIndex == characters.count - 1 ? 0.5 : 1.0)
                }
                .padding(.horizontal)
            }
        }
    }

    private func previousItem() {
        guard currentIndex > 0 else { return }
        withAnimation {
            currentIndex -= 1
        }
    }

    private func nextItem() {
        guard currentIndex < characters.count - 1 else { return }
        withAnimation {
            currentIndex += 1
        }
    }
}

#Preview("Auto-Scrolling Carousel") {
    NavigationStack {
        CarouselView.autoScrolling(
            characters: [
                CharactersResponse(
                    id: 1,
                    name: "Rick Sanchez",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                ),
                CharactersResponse(
                    id: 2,
                    name: "Morty Smith",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                ),
                CharactersResponse(
                    id: 3,
                    name: "Summer Smith",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                )
            ],
            interval: 2.0
        )
        .environment(FeedDetailsBuilder())
    }
}

#Preview("Carousel with Controls") {
    NavigationStack {
        CarouselView(
            characters: [
                CharactersResponse(
                    id: 1,
                    name: "Rick Sanchez",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                ),
                CharactersResponse(
                    id: 2,
                    name: "Morty Smith",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                ),
                CharactersResponse(
                    id: 3,
                    name: "Summer Smith",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                )
            ]
        )
        .withNavigationControls()
        .environment(FeedDetailsBuilder())
    }
}
