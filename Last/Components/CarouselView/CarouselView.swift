//
//  CarouselView.swift
//  Neva
//
//  Created by Abdelrahman Mohamed on 01.11.2025.
//

import SwiftUI

struct CarouselView: View {
    
    let characters: [CharactersResponse]
    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder

    @State private var currentIndex = 0
    
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
                        .padding(.horizontal)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CarouselView(
            characters: [
                CharactersResponse(
                    id: 1,
                    name: "Obada",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                ),
                CharactersResponse(
                    id: 2,
                    name: "Sara",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                ),
                CharactersResponse(
                    id: 3,
                    name: "Nazli",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                ),
                CharactersResponse(
                    id: 4,
                    name: "Omar",
                    species: "Human",
                    image: URL(string: "https://picsum.photos/600/600")
                )
            ]
        )
        .environment(FeedDetailsBuilder())
    }
}
