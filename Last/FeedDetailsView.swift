//
//  FeedDetailsView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import SwiftUI

struct FeedDetailsView: View {

    @State var viewModel: FeedDetailsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let imageURL = viewModel.character.image {
                    ImageLoaderView(url: imageURL)
                        .frame(maxHeight: 400)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .accessibilityLabel("Character image of \(viewModel.character.name)")
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.character.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)

                    if let species = viewModel.character.species {
                        HStack {
                            Text("Species:")
                                .fontWeight(.semibold)
                            Text(species)
                                .foregroundStyle(.secondary)
                        }
                        .font(.title3)
                    }

                    HStack {
                        Text("ID:")
                            .fontWeight(.semibold)
                        Text("#\(viewModel.character.id)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.title3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FeedDetailsView(
            viewModel: FeedDetailsViewModel(
                character: CharactarsResponse(
                    id: 1,
                    name: "Rick Sanchez",
                    species: "Human",
                    image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
                )
            )
        )
    }
}
