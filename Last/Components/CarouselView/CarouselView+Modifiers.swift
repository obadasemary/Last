//
//  CarouselView+Modifiers.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//  Custom view modifiers for CarouselView styling and behavior
//

import SwiftUI

// MARK: - Carousel Style Modifier

/// Configures the visual appearance of a CarouselView
struct CarouselStyleModifier: ViewModifier {
    let height: CGFloat
    let cornerRadius: CGFloat
    let showsPageIndicator: Bool
    let horizontalPadding: CGFloat
    let topPadding: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .padding(.horizontal, horizontalPadding)
            .padding(.top, topPadding)
    }
}

extension View {
    /// Applies custom styling to a carousel view
    /// - Parameters:
    ///   - height: The height of the carousel
    ///   - cornerRadius: The corner radius for the carousel container
    ///   - showsPageIndicator: Whether to show page indicator dots
    ///   - horizontalPadding: Horizontal padding around the carousel
    ///   - topPadding: Top padding for the carousel
    /// - Returns: A styled carousel view
    func carouselStyle(
        height: CGFloat = 220,
        cornerRadius: CGFloat = 16,
        showsPageIndicator: Bool = true,
        horizontalPadding: CGFloat = 0,
        topPadding: CGFloat = 8
    ) -> some View {
        self.modifier(
            CarouselStyleModifier(
                height: height,
                cornerRadius: cornerRadius,
                showsPageIndicator: showsPageIndicator,
                horizontalPadding: horizontalPadding,
                topPadding: topPadding
            )
        )
    }
}

// MARK: - Carousel Shadow Modifier

/// Adds shadow effects to the carousel
struct CarouselShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}

extension View {
    /// Adds a shadow effect to the carousel
    /// - Parameters:
    ///   - color: Shadow color
    ///   - radius: Shadow blur radius
    ///   - x: Horizontal offset
    ///   - y: Vertical offset
    /// - Returns: A carousel with shadow effect
    func carouselShadow(
        color: Color = .black.opacity(0.1),
        radius: CGFloat = 8,
        x: CGFloat = 0,
        y: CGFloat = 4
    ) -> some View {
        self.modifier(
            CarouselShadowModifier(
                color: color,
                radius: radius,
                x: x,
                y: y
            )
        )
    }
}

// MARK: - Carousel Overlay Modifier

/// Adds an overlay effect to carousel items (like a gradient or vignette)
struct CarouselOverlayModifier: ViewModifier {
    let overlayStyle: OverlayStyle

    enum OverlayStyle {
        case gradient(colors: [Color])
        case vignette(intensity: Double)
        case border(color: Color, width: CGFloat)
        case none
    }

    func body(content: Content) -> some View {
        switch overlayStyle {
        case .gradient(let colors):
            content
                .overlay(
                    LinearGradient(
                        colors: colors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .opacity(0.3)
                )
        case .vignette(let intensity):
            content
                .overlay(
                    RadialGradient(
                        colors: [.clear, .black.opacity(intensity)],
                        center: .center,
                        startRadius: 100,
                        endRadius: 300
                    )
                )
        case .border(let color, let width):
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color, lineWidth: width)
                )
        case .none:
            content
        }
    }
}

extension View {
    /// Adds an overlay effect to the carousel
    /// - Parameter style: The overlay style to apply
    /// - Returns: A carousel with overlay effect
    func carouselOverlay(_ style: CarouselOverlayModifier.OverlayStyle) -> some View {
        self.modifier(CarouselOverlayModifier(overlayStyle: style))
    }
}

// MARK: - Carousel Animation Modifier

/// Configures animation behavior for carousel transitions
struct CarouselAnimationModifier<Value: Equatable>: ViewModifier {
    let animation: Animation
    let trigger: Value
    let hapticFeedback: Bool

    func body(content: Content) -> some View {
        content
            .animation(animation, value: trigger)
            .onChange(of: trigger) { _, _ in
                if hapticFeedback {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
    }
}

extension View {
    /// Configures animation for carousel page changes
    /// - Parameters:
    ///   - trigger: The value to trigger animations (usually the current index)
    ///   - animation: The animation to use for transitions
    ///   - hapticFeedback: Whether to provide haptic feedback on page change
    /// - Returns: An animated carousel
    func carouselAnimation<Value: Equatable>(
        trigger: Value,
        animation: Animation = .easeInOut(duration: 0.3),
        hapticFeedback: Bool = true
    ) -> some View {
        self.modifier(
            CarouselAnimationModifier(
                animation: animation,
                trigger: trigger,
                hapticFeedback: hapticFeedback
            )
        )
    }
}

// MARK: - Carousel Parallax Modifier

/// Adds a parallax scrolling effect to carousel items
struct CarouselParallaxModifier: ViewModifier {
    let offset: CGFloat

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .offset(x: parallaxOffset(for: geometry))
        }
    }

    private func parallaxOffset(for geometry: GeometryProxy) -> CGFloat {
        let frame = geometry.frame(in: .global)
        // Using the view's container width instead of deprecated UIScreen.main
        let containerWidth = geometry.size.width
        let center = frame.midX
        let distanceFromCenter = center - (containerWidth / 2)
        return distanceFromCenter * offset * -0.1
    }
}

extension View {
    /// Adds a parallax effect to carousel items
    /// - Parameter offset: The intensity of the parallax effect (0.0 to 1.0)
    /// - Returns: A carousel with parallax effect
    func carouselParallax(offset: CGFloat = 0.5) -> some View {
        self.modifier(CarouselParallaxModifier(offset: offset))
    }
}

// MARK: - Preset Styles

extension View {
    /// Applies a modern, elevated carousel style with shadow
    func carouselModernStyle() -> some View {
        self
            .carouselStyle(height: 240, cornerRadius: 20, horizontalPadding: 16)
            .carouselShadow(color: .blue.opacity(0.15), radius: 12, y: 6)
    }

    /// Applies a compact carousel style
    func carouselCompactStyle() -> some View {
        self
            .carouselStyle(height: 180, cornerRadius: 12, horizontalPadding: 8)
    }

    /// Applies a full-width carousel style with no padding
    func carouselFullWidthStyle() -> some View {
        self
            .carouselStyle(height: 260, cornerRadius: 0, horizontalPadding: 0)
    }

    /// Applies a bordered carousel style
    func carouselBorderedStyle(color: Color = .blue) -> some View {
        self
            .carouselStyle(height: 220, cornerRadius: 16)
            .carouselOverlay(.border(color: color, width: 2))
    }
}

// MARK: - Preview

#Preview("Styled Carousels") {
    NavigationStack {
        ScrollView {
            VStack(spacing: 24) {
                Text("Modern Style")
                    .font(.headline)
                CarouselView(characters: FeedEntity.mock.results)
                    .carouselModernStyle()

                Text("Compact Style")
                    .font(.headline)
                CarouselView(characters: FeedEntity.mock.results)
                    .carouselCompactStyle()

                Text("Bordered Style")
                    .font(.headline)
                CarouselView(characters: FeedEntity.mock.results)
                    .carouselBorderedStyle(color: .purple)

                Text("With Gradient Overlay")
                    .font(.headline)
                CarouselView(characters: FeedEntity.mock.results)
                    .carouselStyle()
                    .carouselOverlay(.gradient(colors: [.purple, .blue]))
            }
            .padding()
        }
        .environment(FeedDetailsBuilder())
    }
}
