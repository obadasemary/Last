//
//  CarouselCard.swift
//  Neva
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import SwiftUI

struct CarouselCard: View {
    
    let character: CharactersResponse
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ImageLoaderView(url: character.image)
                .frame(height: 220)
                .clipped()
            
            LinearGradient(
                colors: [.black.opacity(0.7), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 90)
            .frame(maxWidth: .infinity, alignment: .bottom)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                
                if let species = character.species, !species.isEmpty {
                    Text(species)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(16)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    CarouselCard(
        character: CharactersResponse(
            id: 1,
            name: "Obada",
            species: "Human",
            image: URL(string: "https://picsum.photos/600/600")
        )
    )
}
