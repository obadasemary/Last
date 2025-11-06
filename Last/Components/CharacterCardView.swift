//
//  CharacterCardView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import SwiftUI

struct CharacterCardView: View {
    
    let character: CharactersResponse
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 100, height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .cornerRadius(20)
                        .frame(width: 180)
                        .scaledToFit()
                case .failure:
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(character.name)
                    .font(.title3)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                if let species = character.species {
                    Text(species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(width: 180, alignment: .leading)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
        .frame(width: 180, height: 250)
        .shadow(radius: 3)
    }
}

#Preview {
    CharacterCardView(character: FeedEntity.mock.results[0])
}
