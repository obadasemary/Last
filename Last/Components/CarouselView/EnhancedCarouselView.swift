//
//  EnhancedCarouselView.swift
//  Last
//
//  Advanced carousel with additional features and customization options
//

import SwiftUI

// MARK: - Enhanced Carousel View

/// An advanced carousel view with additional features beyond the basic CarouselView
struct EnhancedCarouselView: View {

    // MARK: - Properties

    let characters: [CharactersResponse]
    let configuration: CarouselConfiguration
    let indicatorStyle: PageIndicatorStyle
    let onPageChanged: ((Int) -> Void)?
    let onCharacterTapped: ((CharactersResponse) -> Void)?

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @State private var currentIndex = 0
    @State private var isLoading = false

    // MARK: - Initialization

    init(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration = .default,
        indicatorStyle: PageIndicatorStyle = .dots,
        onPageChanged: ((Int) -> Void)? = nil,
        onCharacterTapped: ((CharactersResponse) -> Void)? = nil
    ) {
        self.characters = characters
        self.configuration = configuration
        self.indicatorStyle = indicatorStyle
        self.onPageChanged = onPageChanged
        self.onCharacterTapped = onCharacterTapped
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
            if characters.isEmpty {
                emptyStateView
            } else if isLoading {
                loadingView
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                        carouselItem(character: character, index: index)
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

    private func carouselItem(character: CharactersResponse, index: Int) -> some View {
        NavigationLink {
            feedDetailsBuilder.buildFeedDetailsView(character: character)
        } label: {
            ZStack(alignment: .topTrailing) {
                CarouselCard(character: character)

                // Optional badge or overlay
                if index == 0 {
                    Text("Featured")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.blue.gradient)
                        .clipShape(Capsule())
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
        .tag(index)
        .padding(.horizontal, configuration.horizontalPadding)
        .simultaneousGesture(
            TapGesture().onEnded {
                onCharacterTapped?(character)
            }
        )
    }

    // MARK: - Custom Page Indicator

    @ViewBuilder
    private var customPageIndicator: some View {
        if !characters.isEmpty {
            switch indicatorStyle {
            case .dots:
                dotsIndicator
            case .bars:
                barsIndicator
            case .numbers:
                numbersIndicator
            case .thumbnail:
                thumbnailIndicator
            case .none:
                EmptyView()
            }
        }
    }

    private var dotsIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<characters.count, id: \.self) { index in
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
            ForEach(0..<characters.count, id: \.self) { index in
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

            Text("\(currentIndex + 1) / \(characters.count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .monospacedDigit()

            Button(action: nextPage) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title3)
                    .foregroundStyle(currentIndex < characters.count - 1 ? .blue : .gray.opacity(0.3))
            }
            .disabled(currentIndex == characters.count - 1)
        }
        .padding(.horizontal)
    }

    private var thumbnailIndicator: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                    AsyncImage(url: character.image) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(index == currentIndex ? Color.blue : Color.clear, lineWidth: 2)
                    )
                    .scaleEffect(index == currentIndex ? 1.0 : 0.9)
                    .animation(.spring(response: 0.3), value: currentIndex)
                    .onTapGesture {
                        withAnimation {
                            currentIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(.gray)
            Text("No characters available")
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
        guard currentIndex < characters.count - 1 else { return }
        withAnimation {
            currentIndex += 1
        }
    }
}

// MARK: - Page Indicator Style

enum PageIndicatorStyle {
    case dots
    case bars
    case numbers
    case thumbnail
    case none
}

// MARK: - Conditional Modifier Extension

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview("Enhanced Carousel - Dots") {
    NavigationStack {
        EnhancedCarouselView(
            characters: previewCharacters,
            configuration: .large,
            indicatorStyle: .dots,
            onPageChanged: { index in
                print("Page changed to: \(index)")
            },
            onCharacterTapped: { character in
                print("Character tapped: \(character.name)")
            }
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Enhanced Carousel - Bars") {
    NavigationStack {
        EnhancedCarouselView(
            characters: previewCharacters,
            configuration: .default,
            indicatorStyle: .bars
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Enhanced Carousel - Numbers") {
    NavigationStack {
        EnhancedCarouselView(
            characters: previewCharacters,
            configuration: .default,
            indicatorStyle: .numbers
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Enhanced Carousel - Thumbnails") {
    NavigationStack {
        EnhancedCarouselView(
            characters: previewCharacters,
            configuration: .default,
            indicatorStyle: .thumbnail
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Enhanced Carousel - Empty State") {
    NavigationStack {
        EnhancedCarouselView(
            characters: [],
            configuration: .default,
            indicatorStyle: .dots
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

private let previewCharacters = [
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
    ),
    CharactersResponse(
        id: 4,
        name: "Beth Smith",
        species: "Human",
        image: URL(string: "https://picsum.photos/600/600")
    )
]
