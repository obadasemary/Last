//
//  CarouselView+Accessibility.swift
//  Last
//
//  Accessibility enhancements for CarouselView
//

import SwiftUI

// MARK: - Accessible Carousel View

/// A carousel view with comprehensive accessibility support
struct AccessibleCarouselView: View {

    let characters: [CharactersResponse]
    let configuration: CarouselConfiguration

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var currentIndex = 0
    @AccessibilityFocusState private var isCarouselFocused: Bool

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
                emptyStateView
            } else {
                VStack(spacing: 8) {
                    carouselContent
                    accessibleControls
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Character carousel")
        .accessibilityHint("Swipe left or right to browse characters")
    }

    // MARK: - Carousel Content

    private var carouselContent: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                accessibleCarouselItem(character: character, index: index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: configuration.showsPageIndicator ? .automatic : .never))
        .frame(height: adjustedHeight)
        .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous))
        .padding(.top, configuration.topPadding)
        .animation(reduceMotion ? .none : configuration.transitionAnimation, value: currentIndex)
        .onChange(of: currentIndex) { _, newValue in
            announcePageChange(index: newValue)
        }
        .accessibilityFocused($isCarouselFocused)
    }

    // MARK: - Accessible Carousel Item

    private func accessibleCarouselItem(character: CharactersResponse, index: Int) -> some View {
        NavigationLink {
            feedDetailsBuilder.buildFeedDetailsView(character: character)
        } label: {
            CarouselCard(character: character)
        }
        .buttonStyle(.plain)
        .tag(index)
        .padding(.horizontal, configuration.horizontalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: character, at: index))
        .accessibilityHint("Double tap to view details")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(named: "View details") {
            // Navigation handled by NavigationLink
        }
    }

    // MARK: - Accessible Controls

    private var accessibleControls: some View {
        HStack(spacing: 16) {
            Button(action: previousPage) {
                Label("Previous character", systemImage: "chevron.left.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title3)
            }
            .disabled(currentIndex == 0)
            .accessibilityLabel("Previous character")
            .accessibilityHint(currentIndex > 0 ? "Shows \(characters[currentIndex - 1].name)" : "At first character")

            Text("\(currentIndex + 1) of \(characters.count)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .accessibilityLabel("Page \(currentIndex + 1) of \(characters.count)")

            Button(action: nextPage) {
                Label("Next character", systemImage: "chevron.right.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title3)
            }
            .disabled(currentIndex == characters.count - 1)
            .accessibilityLabel("Next character")
            .accessibilityHint(currentIndex < characters.count - 1 ? "Shows \(characters[currentIndex + 1].name)" : "At last character")
        }
        .padding(.horizontal)
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
        .frame(height: adjustedHeight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No characters available")
    }

    // MARK: - Accessibility Helpers

    private func accessibilityLabel(for character: CharactersResponse, at index: Int) -> String {
        """
        \(character.name), \(character.species). \
        Character \(index + 1) of \(characters.count)
        """
    }

    private func announcePageChange(index: Int) {
        guard index < characters.count else { return }
        let character = characters[index]
        let announcement = "\(character.name). Page \(index + 1) of \(characters.count)"

        // Post accessibility announcement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(
                notification: .announcement,
                argument: announcement
            )
        }

        // Haptic feedback if enabled and not reduced motion
        if configuration.enableHapticFeedback && !reduceMotion {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    private var adjustedHeight: CGFloat {
        // Adjust height based on dynamic type size
        let baseHeight = configuration.height
        switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large:
            return baseHeight
        case .xLarge, .xxLarge:
            return baseHeight * 1.1
        case .xxxLarge:
            return baseHeight * 1.2
        default:
            return baseHeight * 1.3
        }
    }

    // MARK: - Actions

    private func previousPage() {
        guard currentIndex > 0 else { return }
        withAnimation(reduceMotion ? .none : .easeInOut) {
            currentIndex -= 1
        }
    }

    private func nextPage() {
        guard currentIndex < characters.count - 1 else { return }
        withAnimation(reduceMotion ? .none : .easeInOut) {
            currentIndex += 1
        }
    }
}

// MARK: - Accessibility Extensions

extension CarouselView {
    /// Creates an accessible version of the carousel with full accessibility support
    /// - Parameter configuration: Optional configuration
    /// - Returns: An accessible carousel view
    static func accessible(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration = .default
    ) -> some View {
        AccessibleCarouselView(
            characters: characters,
            configuration: configuration
        )
    }
}

// MARK: - Accessibility Modifiers

struct CarouselAccessibilityModifier: ViewModifier {
    let currentIndex: Int
    let totalCount: Int
    let currentCharacter: CharactersResponse?

    func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Character carousel")
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Swipe left or right to browse characters")
            .accessibilityAdjustableAction { direction in
                handleAccessibilityAdjustment(direction: direction)
            }
    }

    private var accessibilityValue: String {
        guard let character = currentCharacter else {
            return "No character selected"
        }
        return "\(character.name). Page \(currentIndex + 1) of \(totalCount)"
    }

    private func handleAccessibilityAdjustment(direction: AccessibilityAdjustmentDirection) {
        switch direction {
        case .increment:
            // Handle next page
            UIAccessibility.post(
                notification: .announcement,
                argument: "Moving to next character"
            )
        case .decrement:
            // Handle previous page
            UIAccessibility.post(
                notification: .announcement,
                argument: "Moving to previous character"
            )
        @unknown default:
            break
        }
    }
}

extension View {
    /// Adds comprehensive accessibility support to the carousel
    /// - Parameters:
    ///   - currentIndex: The current page index
    ///   - totalCount: Total number of items
    ///   - currentCharacter: The currently visible character
    /// - Returns: An accessible carousel
    func carouselAccessibility(
        currentIndex: Int,
        totalCount: Int,
        currentCharacter: CharactersResponse?
    ) -> some View {
        self.modifier(
            CarouselAccessibilityModifier(
                currentIndex: currentIndex,
                totalCount: totalCount,
                currentCharacter: currentCharacter
            )
        )
    }
}

// MARK: - High Contrast Support

struct HighContrastCarouselModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        reduceTransparency ? borderColor : Color.clear,
                        lineWidth: 2
                    )
            )
    }

    private var borderColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

extension View {
    /// Adds high contrast border when accessibility settings require it
    func carouselHighContrast() -> some View {
        self.modifier(HighContrastCarouselModifier())
    }
}

// MARK: - Preview

#Preview("Accessible Carousel") {
    NavigationStack {
        AccessibleCarouselView(
            characters: previewCharacters,
            configuration: .large
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Accessible Carousel - Reduced Motion") {
    NavigationStack {
        AccessibleCarouselView(
            characters: previewCharacters,
            configuration: .default
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Accessible Carousel - High Contrast") {
    NavigationStack {
        CarouselView(characters: previewCharacters)
            .carouselHighContrast()
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
    )
]
