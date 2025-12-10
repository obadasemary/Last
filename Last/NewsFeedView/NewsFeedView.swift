//
//  NewsFeedView.swift
//  Last
//
//  Created by Claude Code on 10.12.2025.
//

import SwiftUI

struct NewsFeedView: View {

    @State var viewModel: NewsFeedViewModel

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 0) {
                        if viewModel.isLoading && viewModel.episodes.isEmpty {
                            loadingView
                        } else if let error = viewModel.error {
                            errorView(error: error)
                        } else if viewModel.episodes.isEmpty {
                            emptyStateView
                        } else {
                            episodesListView
                        }
                    }
                }

                // Data source indicator
                if !viewModel.episodes.isEmpty {
                    dataSourceIndicator
                }
            }
            .navigationTitle("Episodes")
            .task {
                await viewModel.loadData()
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }

    // MARK: - Subviews

    private var loadingView: some View {
        VStack(spacing: 16) {
            ForEach(0..<10, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .frame(height: 80)
                    .padding(.horizontal)
                    .redacted(reason: .placeholder)
                    .shimmer()
            }
        }
        .padding(.top)
    }

    private func errorView(error: Error) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Episodes", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error.localizedDescription)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.loadData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Episodes",
            systemImage: "film.stack",
            description: Text("Pull to refresh")
        )
    }

    private var episodesListView: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.episodes) { episode in
                EpisodeCard(episode: episode)
            }
        }
        .padding(.horizontal)
        .padding(.top, 50) // Make room for data source indicator
        .padding(.bottom)
    }

    private var dataSourceIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.isFromRemote ? "wifi" : "internaldrive")
                .font(.caption)
            Text(viewModel.isFromRemote ? "Live Data" : "Cached Data")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(viewModel.isFromRemote ? .green : .orange)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(viewModel.isFromRemote ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        )
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.3), value: viewModel.isFromRemote)
    }
}

// MARK: - Episode Card

struct EpisodeCard: View {
    let episode: EpisodeResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(episode.episode)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )

                Spacer()

                Text(episode.airDate)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Text(episode.name)
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Previews

#Preview("With Episodes - Remote") {
    let builder = NewsFeedSwiftUIBuilder()
    builder.buildNewsFeedView(isUsingMock: true)
}

#Preview("Empty State") {
    let mockUseCase = MockNewsFeedUseCase()
    let viewModel = NewsFeedViewModel(useCase: mockUseCase)
    NewsFeedView(viewModel: viewModel)
}
