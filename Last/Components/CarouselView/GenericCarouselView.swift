//
//  GenericCarouselView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//  Generic carousel view that works with any data type and custom content
//

import SwiftUI

// MARK: - Generic Carousel View

/// A fully generic carousel view that accepts any data type and custom content builder
struct GenericCarouselView<T: Hashable, Content: View>: View {

    // MARK: - Properties

    let items: [T]
    let configuration: CarouselConfiguration
    let indicatorStyle: PageIndicatorStyle
    let onPageChanged: ((Int) -> Void)?
    let onItemTapped: ((T) -> Void)?
    let content: (T, Int) -> Content

    @State private var currentIndex = 0
    @State private var isLoading = false

    // MARK: - Initialization

    /// Creates a generic carousel view
    /// - Parameters:
    ///   - items: Array of items to display (must conform to Hashable)
    ///   - configuration: Carousel appearance configuration
    ///   - indicatorStyle: Style of the page indicator
    ///   - onPageChanged: Callback when the current page changes
    ///   - onItemTapped: Callback when an item is tapped
    ///   - content: ViewBuilder closure to create custom content for each item
    init(
        items: [T],
        configuration: CarouselConfiguration = .default,
        indicatorStyle: PageIndicatorStyle = .dots,
        onPageChanged: ((Int) -> Void)? = nil,
        onItemTapped: ((T) -> Void)? = nil,
        @ViewBuilder content: @escaping (T, Int) -> Content
    ) {
        self.items = items
        self.configuration = configuration
        self.indicatorStyle = indicatorStyle
        self.onPageChanged = onPageChanged
        self.onItemTapped = onItemTapped
        self.content = content
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            carouselContent
            customPageIndicator
        }
    }

    // MARK: - Carousel Content

    private var carouselContent: some View {
        Group {
            if items.isEmpty {
                emptyStateView
            } else if isLoading {
                loadingView
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
                        carouselItem(item: item, index: index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: configuration.height)
                .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous))
                .padding(.top, configuration.topPadding)
                .if(configuration.showsShadow) { view in
                    view.shadow(
                        color: configuration.shadowColor,
                        radius: configuration.shadowRadius,
                        x: configuration.shadowX,
                        y: configuration.shadowY
                    )
                }
                .animation(configuration.transitionAnimation, value: currentIndex)
                .onChange(of: currentIndex) { oldValue, newValue in
                    handlePageChange(from: oldValue, to: newValue)
                }
            }
        }
    }

    // MARK: - Carousel Item

    private func carouselItem(item: T, index: Int) -> some View {
        content(item, index)
            .tag(index)
            .padding(.horizontal, configuration.horizontalPadding)
            .contentShape(Rectangle())
            .onTapGesture {
                onItemTapped?(item)
            }
    }

    // MARK: - Custom Page Indicator

    @ViewBuilder
    private var customPageIndicator: some View {
        if !items.isEmpty {
            switch indicatorStyle {
            case .dots:
                dotsIndicator
            case .bars:
                barsIndicator
            case .numbers:
                numbersIndicator
            case .thumbnail:
                EmptyView() // Thumbnail requires specific implementation per content type
            case .none:
                EmptyView()
            }
        }
    }

    private var dotsIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<items.count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: index == currentIndex ? 10 : 8, height: index == currentIndex ? 10 : 8)
                    .animation(.spring(response: 0.3), value: currentIndex)
            }
        }
        .padding(.horizontal)
    }

    private var barsIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<items.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index == currentIndex ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: index == currentIndex ? 32 : 20, height: 4)
                    .animation(.spring(response: 0.3), value: currentIndex)
            }
        }
        .padding(.horizontal)
    }

    private var numbersIndicator: some View {
        HStack(spacing: 12) {
            Button(action: previousPage) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.title3)
                    .foregroundStyle(currentIndex > 0 ? .blue : .gray.opacity(0.3))
            }
            .disabled(currentIndex == 0)

            Text("\(currentIndex + 1) / \(items.count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Button(action: nextPage) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(currentIndex < items.count - 1 ? .blue : .gray.opacity(0.3))
            }
            .disabled(currentIndex == items.count - 1)
        }
        .padding(.horizontal)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            Text("No items available")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(height: configuration.height)
    }

    // MARK: - Loading State

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: configuration.height)
    }

    // MARK: - Actions

    private func handlePageChange(from oldIndex: Int, to newIndex: Int) {
        if configuration.enableHapticFeedback {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        onPageChanged?(newIndex)
    }

    private func previousPage() {
        guard currentIndex > 0 else { return }
        withAnimation {
            currentIndex -= 1
        }
    }

    private func nextPage() {
        guard currentIndex < items.count - 1 else { return }
        withAnimation {
            currentIndex += 1
        }
    }
}

// MARK: - Preview Models

private struct PreviewItem: Hashable, Identifiable {
    let id: Int
    let title: String
    let color: Color
}

// MARK: - Previews

#Preview("Generic Carousel - Text Cards") {
    NavigationStack {
        GenericCarouselView(
            items: [
                PreviewItem(id: 1, title: "First", color: .blue),
                PreviewItem(id: 2, title: "Second", color: .green),
                PreviewItem(id: 3, title: "Third", color: .purple),
                PreviewItem(id: 4, title: "Fourth", color: .orange)
            ],
            configuration: .default,
            indicatorStyle: .dots,
            onPageChanged: { index in
                print("Page changed to: \(index)")
            },
            onItemTapped: { item in
                print("Item tapped: \(item.title)")
            }
        ) { item, index in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(item.color.gradient)

                VStack(spacing: 8) {
                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("Item #\(index + 1)")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding()
    }
}

#Preview("Generic Carousel - Custom Images") {
    NavigationStack {
        GenericCarouselView(
            items: ["photo.fill", "heart.fill", "star.fill", "bolt.fill"],
            configuration: .large,
            indicatorStyle: .bars
        ) { iconName, index in
            VStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 80))
                    .foregroundStyle(.blue.gradient)

                Text("Icon \(index + 1)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }
}

#Preview("Generic Carousel - Numbers with Navigation") {
    NavigationStack {
        GenericCarouselView(
            items: [1, 2, 3, 4, 5],
            configuration: .compact,
            indicatorStyle: .numbers
        ) { number, _ in
            ZStack {
                LinearGradient(
                    colors: [.pink, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Text("\(number)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

#Preview("Generic Carousel - Empty State") {
    NavigationStack {
        GenericCarouselView(
            items: [] as [Int],
            configuration: .default,
            indicatorStyle: .dots
        ) { number, _ in
            Text("\(number)")
        }
        .padding()
    }
}

#Preview("Generic Carousel - Character Example") {
    NavigationStack {
        GenericCarouselView(
            items: [
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
                )
            ],
            configuration: .hero,
            indicatorStyle: .dots,
            onItemTapped: { character in
                print("Tapped: \(character.name)")
            }
        ) { character, index in
            VStack(alignment: .leading, spacing: 12) {
                AsyncImage(url: character.image) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.headline)

                    Text(character.species ?? "Unknown")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding()
    }
}
