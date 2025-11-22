//
//  CarouselView+Animations.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//  Custom animations and transitions for CarouselView
//

import SwiftUI

// MARK: - Animation Styles

/// Defines various animation styles for carousel transitions
enum CarouselAnimationStyle {
    case spring
    case easeInOut
    case bounce
    case smooth
    case snappy
    case custom(Animation)

    var animation: Animation {
        switch self {
        case .spring:
            return .spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.2)
        case .easeInOut:
            return .easeInOut(duration: 0.3)
        case .bounce:
            return .spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.3)
        case .smooth:
            return .smooth(duration: 0.4, extraBounce: 0)
        case .snappy:
            return .snappy(duration: 0.25, extraBounce: 0.1)
        case .custom(let animation):
            return animation
        }
    }
}

// MARK: - Transition Effects

/// Custom transition effects for carousel cards
enum CarouselTransitionEffect {
    case scale
    case fade
    case slide
    case rotate
    case blur
    case none

    func apply(to view: some View, isActive: Bool) -> AnyView {
        switch self {
        case .scale:
            return AnyView(
                view
                    .scaleEffect(isActive ? 1.0 : 0.9)
                    .opacity(isActive ? 1.0 : 0.7)
            )
        case .fade:
            return AnyView(
                view
                    .opacity(isActive ? 1.0 : 0.5)
            )
        case .slide:
            return AnyView(
                view
                    .offset(y: isActive ? 0 : 20)
            )
        case .rotate:
            return AnyView(
                view
                    .rotation3DEffect(
                        .degrees(isActive ? 0 : 15),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
            )
        case .blur:
            return AnyView(
                view
                    .blur(radius: isActive ? 0 : 3)
            )
        case .none:
            return AnyView(view)
        }
    }
}

// MARK: - Animated Carousel View

/// A carousel with customizable animation effects
struct AnimatedCarouselView: View {

    let characters: [CharactersResponse]
    let configuration: CarouselConfiguration
    let animationStyle: CarouselAnimationStyle
    let transitionEffect: CarouselTransitionEffect

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentIndex = 0
    @State private var dragOffset: CGFloat = 0

    init(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration = .default,
        animationStyle: CarouselAnimationStyle = .spring,
        transitionEffect: CarouselTransitionEffect = .scale
    ) {
        self.characters = characters
        self.configuration = configuration
        self.animationStyle = animationStyle
        self.transitionEffect = transitionEffect
    }

    var body: some View {
        Group {
            if characters.isEmpty {
                EmptyView()
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                        animatedCarouselItem(character: character, index: index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: configuration.showsPageIndicator ? .automatic : .never))
                .frame(height: configuration.height)
                .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous))
                .padding(.top, configuration.topPadding)
                .animation(
                    reduceMotion ? .none : animationStyle.animation,
                    value: currentIndex
                )
            }
        }
    }

    private func animatedCarouselItem(character: CharactersResponse, index: Int) -> some View {
        let isActive = index == currentIndex

        return NavigationLink {
            feedDetailsBuilder.buildFeedDetailsView(character: character)
        } label: {
            transitionEffect.apply(
                to: CarouselCard(character: character),
                isActive: isActive
            )
        }
        .buttonStyle(.plain)
        .tag(index)
        .padding(.horizontal, configuration.horizontalPadding)
        .animation(
            reduceMotion ? .none : animationStyle.animation,
            value: isActive
        )
    }
}

// MARK: - Parallax Carousel View

/// A carousel with parallax scrolling effect
struct ParallaxCarouselView: View {

    let characters: [CharactersResponse]
    let configuration: CarouselConfiguration

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @State private var currentIndex = 0

    var body: some View {
        GeometryReader { geometry in
            TabView(selection: $currentIndex) {
                ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                    NavigationLink {
                        feedDetailsBuilder.buildFeedDetailsView(character: character)
                    } label: {
                        CarouselCard(character: character)
                            .rotation3DEffect(
                                .degrees(parallaxRotation(for: index)),
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.5
                            )
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
        }
    }

    private func parallaxRotation(for index: Int) -> Double {
        let offset = Double(index - currentIndex)
        return offset * 15.0 // Degrees of rotation
    }
}

// MARK: - Zoom Carousel View

/// A carousel with zoom transition effect
struct ZoomCarouselView: View {

    let characters: [CharactersResponse]
    let configuration: CarouselConfiguration

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                NavigationLink {
                    feedDetailsBuilder.buildFeedDetailsView(character: character)
                } label: {
                    CarouselCard(character: character)
                        .scaleEffect(scale(for: index))
                        .opacity(opacity(for: index))
                }
                .buttonStyle(.plain)
                .tag(index)
                .padding(.horizontal, configuration.horizontalPadding)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.4, dampingFraction: 0.75),
                    value: currentIndex
                )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: configuration.showsPageIndicator ? .automatic : .never))
        .frame(height: configuration.height)
        .clipShape(RoundedRectangle(cornerRadius: configuration.cornerRadius, style: .continuous))
        .padding(.top, configuration.topPadding)
    }

    private func scale(for index: Int) -> CGFloat {
        index == currentIndex ? 1.0 : 0.85
    }

    private func opacity(for index: Int) -> Double {
        index == currentIndex ? 1.0 : 0.6
    }
}

// MARK: - Bouncing Carousel View

/// A carousel with bouncy entrance animation
struct BouncingCarouselView: View {

    let characters: [CharactersResponse]
    let configuration: CarouselConfiguration

    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentIndex = 0
    @State private var hasAppeared = false

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(characters.enumerated()), id: \.1.id) { index, character in
                NavigationLink {
                    feedDetailsBuilder.buildFeedDetailsView(character: character)
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
        .scaleEffect(hasAppeared ? 1.0 : 0.8)
        .opacity(hasAppeared ? 1.0 : 0.0)
        .onAppear {
            if !reduceMotion {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    hasAppeared = true
                }
            } else {
                hasAppeared = true
            }
        }
    }
}

// MARK: - CarouselView Animation Extensions

extension CarouselView {

    /// Creates a carousel with custom animation style
    /// - Parameters:
    ///   - characters: Characters to display
    ///   - animationStyle: The animation style to use
    ///   - transitionEffect: The transition effect to apply
    /// - Returns: An animated carousel
    static func animated(
        characters: [CharactersResponse],
        animationStyle: CarouselAnimationStyle = .spring,
        transitionEffect: CarouselTransitionEffect = .scale
    ) -> some View {
        AnimatedCarouselView(
            characters: characters,
            animationStyle: animationStyle,
            transitionEffect: transitionEffect
        )
    }

    /// Creates a carousel with parallax scrolling effect
    /// - Parameters:
    ///   - characters: Characters to display
    ///   - configuration: Carousel configuration
    /// - Returns: A parallax carousel
    static func parallax(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration = .default
    ) -> some View {
        ParallaxCarouselView(
            characters: characters,
            configuration: configuration
        )
    }

    /// Creates a carousel with zoom transition effect
    /// - Parameters:
    ///   - characters: Characters to display
    ///   - configuration: Carousel configuration
    /// - Returns: A zoom carousel
    static func zoom(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration = .default
    ) -> some View {
        ZoomCarouselView(
            characters: characters,
            configuration: configuration
        )
    }

    /// Creates a carousel with bouncy entrance animation
    /// - Parameters:
    ///   - characters: Characters to display
    ///   - configuration: Carousel configuration
    /// - Returns: A bouncing carousel
    static func bouncing(
        characters: [CharactersResponse],
        configuration: CarouselConfiguration = .default
    ) -> some View {
        BouncingCarouselView(
            characters: characters,
            configuration: configuration
        )
    }
}

// MARK: - Animated Card Modifier

struct AnimatedCardModifier: ViewModifier {
    let isActive: Bool
    let effect: CarouselTransitionEffect
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            effect.apply(to: content, isActive: isActive)
        }
    }
}

extension View {
    /// Applies animated card effects
    func animatedCard(isActive: Bool, effect: CarouselTransitionEffect) -> some View {
        self.modifier(AnimatedCardModifier(isActive: isActive, effect: effect))
    }
}

// MARK: - Preview

#Preview("Spring Animation") {
    NavigationStack {
        CarouselView.animated(
            characters: FeedEntity.mock.results,
            animationStyle: .spring,
            transitionEffect: .scale
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Bounce Animation") {
    NavigationStack {
        CarouselView.animated(
            characters: FeedEntity.mock.results,
            animationStyle: .bounce,
            transitionEffect: .rotate
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Parallax Effect") {
    NavigationStack {
        CarouselView.parallax(
            characters: FeedEntity.mock.results,
            configuration: .large
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Zoom Effect") {
    NavigationStack {
        CarouselView.zoom(
            characters: FeedEntity.mock.results,
            configuration: .default
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("Bouncing Entrance") {
    NavigationStack {
        CarouselView.bouncing(
            characters: FeedEntity.mock.results,
            configuration: .hero
        )
        .environment(FeedDetailsBuilder())
        .padding()
    }
}

#Preview("All Effects") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 32) {
                Text("Scale Transition")
                    .font(.headline)
                CarouselView.animated(
                    characters: FeedEntity.mock.results,
                    animationStyle: .spring,
                    transitionEffect: .scale
                )

                Text("Rotate Transition")
                    .font(.headline)
                CarouselView.animated(
                    characters: FeedEntity.mock.results,
                    animationStyle: .smooth,
                    transitionEffect: .rotate
                )

                Text("Fade Transition")
                    .font(.headline)
                CarouselView.animated(
                    characters: FeedEntity.mock.results,
                    animationStyle: .easeInOut,
                    transitionEffect: .fade
                )
            }
            .padding()
        }
        .environment(FeedDetailsBuilder())
    }
}
