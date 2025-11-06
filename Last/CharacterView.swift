//
//  CharacterView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 02.11.2025.
//

import SwiftUI

struct CharacterView: View {
    
    let character: CharactersResponse
    
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(width: 100, height: 100)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(4)
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
                    .font(.title)
                    .foregroundStyle(.primary)
                
                if let species = character.species {
                    Text(species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background {
            Color.gray.opacity(0.05)
        }
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

#Preview {
    CharacterView(character: FeedEntity.mock.results[0])
}
