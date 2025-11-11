//
//  FeedUIKit.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import UIKit
import SwiftUI
import Observation

final class FeedUIKit: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: FeedViewModel
    private let feedDetailsBuilder: FeedDetailsBuilder
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.delegate = self
        cv.dataSource = self
        cv.refreshControl = refreshControl
        return cv
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    
    private var observationTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(viewModel: FeedViewModel, feedDetailsBuilder: FeedDetailsBuilder) {
        self.viewModel = viewModel
        self.feedDetailsBuilder = feedDetailsBuilder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservations()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        observationTask?.cancel()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Feeds"
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
    }
    
    private func setupObservations() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let self else { return }
            await withObservationTracking {
                _ = self.viewModel.characters
                _ = self.viewModel.isLoading
            } onChange: {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.collectionView.reloadData()
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.setupObservations()
                }
            }
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self else { return nil }
            
            if self.viewModel.isLoading && self.viewModel.characters.isEmpty {
                return self.createShimmerSection()
            } else if self.viewModel.characters.isEmpty {
                return self.createEmptyStateSection()
            } else {
                // First section: Grid cards
                if sectionIndex == 0 {
                    return self.createGridSection()
                } else {
                    // Second section: List rows
                    return self.createListSection()
                }
            }
        }
        return layout
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
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        
        return section
    }
    
    private func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
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
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0)
        
        return section
    }
    
    private func createEmptyStateSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(400)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
    
    // MARK: - Actions
    
    @objc private func refreshData() {
        Task {
            await viewModel.loadDataAsync()
            await MainActor.run {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func loadData() {
        Task {
            await viewModel.loadDataAsync()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FeedUIKit: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if viewModel.isLoading && viewModel.characters.isEmpty {
            return 1
        } else if viewModel.characters.isEmpty {
            return 1
        } else {
            return 2 // Grid section + List section
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.isLoading && viewModel.characters.isEmpty {
            return 4 // Shimmer placeholders
        } else if viewModel.characters.isEmpty {
            return 1 // Empty state
        } else {
            if section == 0 {
                return viewModel.characters.count // Grid cards
            } else {
                return viewModel.characters.count // List rows
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewModel.isLoading && viewModel.characters.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ShimmerCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! ShimmerCollectionViewCell
            return cell
        } else if viewModel.characters.isEmpty {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmptyStateCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! EmptyStateCollectionViewCell
            return cell
        } else {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CharacterCardCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as! CharacterCardCollectionViewCell
                cell.configure(with: viewModel.characters[indexPath.item])
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CharacterListCollectionViewCell.reuseIdentifier,
                    for: indexPath
                ) as! CharacterListCollectionViewCell
                cell.configure(with: viewModel.characters[indexPath.item])
                return cell
            }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension FeedUIKit: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard !viewModel.characters.isEmpty else { return }
        
        let character = viewModel.characters[indexPath.item]
        let detailsView = feedDetailsBuilder.buildFeedDetailsView(character: character)
        let hostingController = UIHostingController(rootView: detailsView)
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

