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
                    
                    HStack {
                        Button {
                            Task {
                                await downloadAndSaveImage()
                            }
                        } label: {
                            Text("Save to Cache")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color(.systemBlue))
                                .cornerRadius(10)
                        }

                        Button {
                            viewModel.removeFromCache()
                        } label: {
                            Text("Delete from Cache")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color(.systemRed))
                                .cornerRadius(10)
                        }
                        
                        Button {
                            viewModel.getFromCache()
                        } label: {
                            Text("Get from Cache")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color(.systemGreen))
                                .cornerRadius(10)
                        }
                    }
                    
                    if let image = viewModel.cachedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .clipped()
                            .cornerRadius(10)
                            .brightness(viewModel.brightness - 0.5)
                        
                        Slider(
                            value: Binding(
                                get: {
                                    viewModel.brightness
                                },
                                set: { value in
                                    viewModel.updateBrightness(value)
                                }
                            ),
                            in: CGFloat(0)...CGFloat(1)
                        ) {
                            Text("Brightness: \(Int(round(viewModel.brightness * 100)))%")
                        } ticks: {
                            SliderTick(0)
                            SliderTick(0.25)
                            SliderTick(0.5)
                            SliderTick(0.75)
                            SliderTick(1)
                        }
                        .padding()
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .ignoresSafeArea(.all, edges: .top)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func downloadAndSaveImage() async {
        guard let imageURL = viewModel.character.image else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            if let uiImage = UIImage(data: data) {
                viewModel.saveToCache(image: uiImage)
            }
        } catch {
            print("Failed to download image: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        FeedDetailsView(
            viewModel: FeedDetailsViewModel(
                character: CharactersResponse(
                    id: 1,
                    name: "Rick Sanchez",
                    species: "Human",
                    image: URL(string: "https://rickandmortyapi.com/api/character/avatar/1.jpeg")
                )
            )
        )
    }
}
