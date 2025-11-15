//
//  FeedView.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import SwiftUI

struct FeedView: View {
    
    @State var viewModel: FeedViewModel
    @Environment(FeedDetailsBuilder.self) private var feedDetailsBuilder
    var columns = [GridItem(.adaptive(minimum: 160), spacing: 20)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading && viewModel.characters.isEmpty {
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.05))
                        .frame(height: 220)
                        .padding(.horizontal)
                        .redacted(reason: .placeholder)
                        .shimmer()
                        .padding(.bottom)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.05))
                                .frame(width: 180)
                                .frame(height: 250)
                                .padding(.horizontal)
                                .redacted(reason: .placeholder)
                                .shimmer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .frame(maxWidth: .infinity)
                            .frame(height: 120)
                            .padding(.horizontal)
                            .redacted(reason: .placeholder)
                            .shimmer()
                    }
                } else if viewModel.characters.isEmpty {
                    ContentUnavailableView(
                        "No Feeds",
                        systemImage: "network.slash",
                        description: Text("Pull to refresh")
                    )
                } else {
                    CarouselView(characters: viewModel.characters)
                    
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.characters, id: \.id) { character in
                            NavigationLink {
                                feedDetailsBuilder.buildFeedDetailsView(character: character)
                            } label: {
                                CharacterCardView(character: character)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    LazyVStack {
                        ForEach(viewModel.characters, id: \.id) { character in
                            NavigationLink {
                                feedDetailsBuilder.buildFeedDetailsView(character: character)
                            } label: {
                                CharacterView(character: character)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // TODO: Implement settings action
                    } label: {
                        Image(systemName: "gear")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .onAppear {
//                viewModel.loadDataWithCompletionHandler()
////                viewModel.loadDataWithCombine()
            }
            .task {
//                await viewModel.loadDataAsync()
                await viewModel.loadDataAsyncFromCombine()
//                await viewModel.loadDataAsyncFromCompletion()
            }
            .refreshable {
//                viewModel.loadDataWithCompletionHandler()
//                viewModel.loadDataWithCombine()
//                await viewModel.loadDataAsync()
                await viewModel.loadDataAsyncFromCombine()
//                await viewModel.loadDataAsyncFromCompletion()
            }
            .navigationTitle("Feeds")
        }
    }
}

#Preview {
    let feedBuilder = FeedBuilder()
    feedBuilder.buildFeedView(isUsingMock: true)
}
