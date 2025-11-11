//
//  CharacterCardCollectionViewCell.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import UIKit

final class CharacterCardCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CharacterCardCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var imageTask: Task<Void, Never>?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageView.image = nil
        nameLabel.text = nil
        speciesLabel.text = nil
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
        overlayView.addSubview(nameLabel)
        overlayView.addSubview(speciesLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            overlayView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            
            speciesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            speciesLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 16),
            speciesLabel.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -16),
            speciesLabel.bottomAnchor.constraint(lessThanOrEqualTo: overlayView.bottomAnchor, constant: -12)
        ])
        
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 3
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.cornerRadius = 20
    }
    
    func configure(with character: CharactersResponse) {
        nameLabel.text = character.name
        speciesLabel.text = character.species
        speciesLabel.isHidden = character.species == nil
        
        guard let imageURL = character.image else {
            imageView.image = UIImage(systemName: "person.fill")
            return
        }
        
        imageTask = Task { @MainActor in
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                if let image = UIImage(data: data) {
                    self.imageView.image = image
                }
            } catch {
                self.imageView.image = UIImage(systemName: "person.fill")
            }
        }
    }
}

