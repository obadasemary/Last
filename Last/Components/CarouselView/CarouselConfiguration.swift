//
//  CarouselConfiguration.swift
//  Last
//
//  Configuration options for CarouselView customization
//

import SwiftUI

// MARK: - Carousel Configuration

/// Configuration object for customizing CarouselView appearance and behavior
struct CarouselConfiguration {

    // MARK: - Layout Properties

    /// The height of the carousel
    var height: CGFloat

    /// Corner radius for the carousel container
    var cornerRadius: CGFloat

    /// Horizontal padding around carousel items
    var horizontalPadding: CGFloat

    /// Top padding for the carousel
    var topPadding: CGFloat

    /// Spacing between carousel items (not directly applicable to TabView)
    var itemSpacing: CGFloat

    // MARK: - Display Properties

    /// Whether to show the page indicator dots
    var showsPageIndicator: Bool

    /// Page indicator tint color (iOS 16+)
    var pageIndicatorTintColor: Color?

    /// Current page indicator tint color (iOS 16+)
    var currentPageIndicatorTintColor: Color?

    // MARK: - Animation Properties

    /// Animation to use for page transitions
    var transitionAnimation: Animation

    /// Whether to enable haptic feedback on page change
    var enableHapticFeedback: Bool

    // MARK: - Shadow Properties

    /// Whether to show shadow
    var showsShadow: Bool

    /// Shadow color
    var shadowColor: Color

    /// Shadow radius
    var shadowRadius: CGFloat

    /// Shadow horizontal offset
    var shadowX: CGFloat

    /// Shadow vertical offset
    var shadowY: CGFloat

    // MARK: - Preset Configurations

    /// Default configuration
    static let `default` = CarouselConfiguration(
        height: 220,
        cornerRadius: 16,
        horizontalPadding: 0,
        topPadding: 8,
        itemSpacing: 0,
        showsPageIndicator: true,
        pageIndicatorTintColor: nil,
        currentPageIndicatorTintColor: nil,
        transitionAnimation: .easeInOut(duration: 0.3),
        enableHapticFeedback: false,
        showsShadow: false,
        shadowColor: .black.opacity(0.1),
        shadowRadius: 8,
        shadowX: 0,
        shadowY: 4
    )

    /// Compact configuration for smaller displays
    static let compact = CarouselConfiguration(
        height: 180,
        cornerRadius: 12,
        horizontalPadding: 8,
        topPadding: 4,
        itemSpacing: 0,
        showsPageIndicator: true,
        pageIndicatorTintColor: nil,
        currentPageIndicatorTintColor: nil,
        transitionAnimation: .easeInOut(duration: 0.2),
        enableHapticFeedback: false,
        showsShadow: false,
        shadowColor: .black.opacity(0.1),
        shadowRadius: 6,
        shadowX: 0,
        shadowY: 3
    )

    /// Large configuration for prominent displays
    static let large = CarouselConfiguration(
        height: 280,
        cornerRadius: 20,
        horizontalPadding: 16,
        topPadding: 12,
        itemSpacing: 0,
        showsPageIndicator: true,
        pageIndicatorTintColor: nil,
        currentPageIndicatorTintColor: nil,
        transitionAnimation: .spring(response: 0.4, dampingFraction: 0.8),
        enableHapticFeedback: true,
        showsShadow: true,
        shadowColor: .blue.opacity(0.15),
        shadowRadius: 12,
        shadowX: 0,
        shadowY: 6
    )

    /// Full-width configuration with no padding
    static let fullWidth = CarouselConfiguration(
        height: 240,
        cornerRadius: 0,
        horizontalPadding: 0,
        topPadding: 0,
        itemSpacing: 0,
        showsPageIndicator: true,
        pageIndicatorTintColor: nil,
        currentPageIndicatorTintColor: nil,
        transitionAnimation: .easeInOut(duration: 0.3),
        enableHapticFeedback: false,
        showsShadow: false,
        shadowColor: .clear,
        shadowRadius: 0,
        shadowX: 0,
        shadowY: 0
    )

    /// Hero configuration for featured content
    static let hero = CarouselConfiguration(
        height: 320,
        cornerRadius: 24,
        horizontalPadding: 20,
        topPadding: 16,
        itemSpacing: 0,
        showsPageIndicator: true,
        pageIndicatorTintColor: .white.opacity(0.5),
        currentPageIndicatorTintColor: .white,
        transitionAnimation: .spring(response: 0.5, dampingFraction: 0.75),
        enableHapticFeedback: true,
        showsShadow: true,
        shadowColor: .black.opacity(0.2),
        shadowRadius: 20,
        shadowX: 0,
        shadowY: 10
    )
}

// MARK: - Configurable CarouselView

/// Extended CarouselView that accepts a configuration object
struct ConfigurableCarouselView: View {

    let characters: [CharactersResponse]
    let configuration: CarouselConfiguration

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @State private var currentIndex = 0

    init(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration = .default
    ) {
        self.characters = characters
        self.configuration = configuration
    }

    var body: some View {
        Group {
            if characters.isEmpty {
                EmptyView()
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                        NavigationLink {
                            feedDetailsBuilder
                                .buildFeedDetailsView(character: character)
                        } label: {
                            CarouselCard(character: character)
                        }
                        .buttonStyle(.plain)
                        .tag(index)
                        .padding(.horizontal, configuration.horizontalPadding)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: configuration.showsPageIndicator ? .automatic : .never))
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
                .onChange(of: currentIndex) { _, _ in
                    if configuration.enableHapticFeedback {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
        }
    }
}

// MARK: - CarouselView Extension

extension CarouselView {
    /// Creates a carousel with custom configuration
    /// - Parameter configuration: The configuration to apply
    /// - Returns: A configured carousel view
    static func configured(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration
    ) -> some View {
        ConfigurableCarouselView(
            characters: characters,
            configuration: configuration
        )
    }
}

// MARK: - Preview

#Preview("Configuration Presets") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default")
                        .font(.headline)
                    ConfigurableCarouselView(
                        characters: previewCharacters,
                        configuration: .default
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Compact")
                        .font(.headline)
                    ConfigurableCarouselView(
                        characters: previewCharacters,
                        configuration: .compact
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Large")
                        .font(.headline)
                    ConfigurableCarouselView(
                        characters: previewCharacters,
                        configuration: .large
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Full Width")
                        .font(.headline)
                    ConfigurableCarouselView(
                        characters: previewCharacters,
                        configuration: .fullWidth
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Hero")
                        .font(.headline)
                    ConfigurableCarouselView(
                        characters: previewCharacters,
                        configuration: .hero
                    )
                }
            }
            .padding()
        }
        .environment(FeedDetailsBuilder())
    }
}

#Preview("Custom Configuration") {
    NavigationStack {
        ConfigurableCarouselView(
            characters: previewCharacters,
            configuration: CarouselConfiguration(
                height: 250,
                cornerRadius: 18,
                horizontalPadding: 12,
                topPadding: 10,
                itemSpacing: 0,
                showsPageIndicator: true,
                pageIndicatorTintColor: .purple.opacity(0.5),
                currentPageIndicatorTintColor: .purple,
                transitionAnimation: .spring(response: 0.4, dampingFraction: 0.7),
                enableHapticFeedback: true,
                showsShadow: true,
                shadowColor: .purple.opacity(0.2),
                shadowRadius: 15,
                shadowX: 0,
                shadowY: 8
            )
        )
        .environment(FeedDetailsBuilder())
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
    )
]
