//
//  NewsFeedViewController.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 21.11.2025.
//

import UIKit
import SwiftUI

final class NewsFeedViewController: UIViewController {
    
    private let viewModel: NewsFeedViewModel
    private var tableView: UITableView!
    private var refreshControl: UIRefreshControl!
    private var observationTask: Task<Void, Never>?
    
    init(viewModel: NewsFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupRefreshControl()
        setupObservations()
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        observationTask?.cancel()
    }
    
    private func setupUI() {
        title = "News"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupObservations() {
        observationTask?.cancel()
        observationTask = Task { [weak self] in
            guard let self else { return }
            await withObservationTracking {
                _ = self.viewModel.episodes
                _ = self.viewModel.isLoading
            } onChange: {
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.tableView.reloadData()
                    if !self.viewModel.isLoading {
                        self.refreshControl.endRefreshing()
                    }
                    self.setupObservations()
                }
            }
        }
    }
    
    @objc private func refreshData() {
        Task {
            await viewModel.loadData()
        }
    }
    
    private func loadData() {
        Task {
            await viewModel.loadData()
        }
    }
}

extension NewsFeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let episode = viewModel.episodes[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = episode.name
        content.secondaryText = "\(episode.episode) • \(episode.air_date)"
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
