//
//  FeedUIKitViewController.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import UIKit
import SwiftUI

final class FeedUIKitViewController: UIViewController {
    
    private let viewModel: FeedViewModel
    private let feedDetailsBuilder: FeedDetailsBuilder
    private var collectionView: UICollectionView!
    private var refreshControl: UIRefreshControl!
    private var updateTask: Task<Void, Never>?
    
    init(viewModel: FeedViewModel, feedDetailsBuilder: FeedDetailsBuilder) {
        self.viewModel = viewModel
        self.feedDetailsBuilder = feedDetailsBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupRefreshControl()
        observeViewModel()
        loadData()
    }
    
    private func setupUI() {
        title = "Feeds"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cells
        collectionView.register(
            CharacterCardCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterCardCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            CharacterListCollectionViewCell.self,
            forCellWithReuseIdentifier: CharacterListCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            ShimmerCollectionViewCell.self,
            forCellWithReuseIdentifier: ShimmerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            EmptyStateCollectionViewCell.self,
            forCellWithReuseIdentifier: EmptyStateCollectionViewCell.reuseIdentifier
        )
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else { return nil }
            
            // Section 0: Grid cards (if not loading/empty)
            if sectionIndex == 0 && !self.viewModel.characters.isEmpty && !self.viewModel.isLoading {
                return self.createGridSection()
            }
            
            // Section 1: List items (if not loading/empty)
            if sectionIndex == 1 && !self.viewModel.characters.isEmpty && !self.viewModel.isLoading {
                return self.createListSection()
            }
            
            // Loading shimmer section
            if self.viewModel.isLoading && self.viewModel.characters.isEmpty {
                return self.createShimmerSection()
            }
            
            // Empty state section
            if self.viewModel.characters.isEmpty && !self.viewModel.isLoading {
                return self.createEmptyStateSection()
            }
            
            return nil
        }
    }
    
    private func createGridSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(250)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        
        return section
    }
    
    private func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        
        return section
    }
    
    private func createShimmerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(250)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        
        return section
    }
    
    private func createEmptyStateSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.6)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(0.6)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 100, leading: 20, bottom: 100, trailing: 20)
        
        return section
    }
    
    private func observeViewModel() {
        updateTask?.cancel()
        updateTask = Task { [weak self] in
            guard let self = self else { return }
            while !Task.isCancelled {
                // Use observation tracking to detect changes
                withObservationTracking {
                    _ = self.viewModel.characters
                    _ = self.viewModel.isLoading
                } onChange: { [weak self] in
                    Task { @MainActor [weak self] in
                        self?.updateUI()
                    }
                }
                
                // Small delay to avoid tight loop
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            }
        }
    }
    
    private func updateUI() {
        // Invalidate layout to recalculate sections based on new state
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }
    
    deinit {
        updateTask?.cancel()
    }
    
    private func loadData() {
        Task {
            await viewModel.loadDataAsync()
            await MainActor.run {
                updateUI()
            }
        }
    }
    
    @objc private func refreshData() {
        Task {
            await viewModel.loadDataAsync()
            await MainActor.run {
                updateUI()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FeedUIKitViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewModel.isLoading && viewModel.characters.isEmpty {
            return 1 // Shimmer section
        }
        if viewModel.characters.isEmpty && !viewModel.isLoading {
            return 1 // Empty state section
        }
        return 2 // Grid section + List section
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.isLoading && viewModel.characters.isEmpty {
            return 4 // Shimmer cards
        }
        if viewModel.characters.isEmpty && !viewModel.isLoading {
            return 1 // Empty state
        }
        
        if section == 0 {
            return viewModel.characters.count // Grid cards
        } else {
            return viewModel.characters.count // List items
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.isLoading && viewModel.characters.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ShimmerCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! ShimmerCollectionViewCell
            return cell
        }
        
        if viewModel.characters.isEmpty && !viewModel.isLoading {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyStateCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! EmptyStateCollectionViewCell
            return cell
        }
        
        let character = viewModel.characters[indexPath.item]
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterCardCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! CharacterCardCollectionViewCell
            cell.configure(with: character)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CharacterListCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! CharacterListCollectionViewCell
            cell.configure(with: character)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FeedUIKitViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard !viewModel.characters.isEmpty else { return }
        
        let character = viewModel.characters[indexPath.item]
        let detailsView = feedDetailsBuilder.buildFeedDetailsView(character: character)
        let hostingController = UIHostingController(rootView: detailsView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

