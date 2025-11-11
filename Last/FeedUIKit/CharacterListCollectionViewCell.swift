//
//  CharacterListCollectionViewCell.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import UIKit

final class CharacterListCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CharacterListCollectionViewCell"
    
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
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
        characterImageView.image = nil
        nameLabel.text = nil
        speciesLabel.text = nil
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(characterImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(speciesLabel)
        
        NSLayoutConstraint.activate([
            characterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            characterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            characterImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            characterImageView.widthAnchor.constraint(equalToConstant: 100),
            characterImageView.heightAnchor.constraint(equalToConstant: 100),
            
            nameLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            
            speciesLabel.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 16),
            speciesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            speciesLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with character: CharactersResponse) {
        nameLabel.text = character.name
        speciesLabel.text = character.species
        speciesLabel.isHidden = character.species == nil
        
        guard let imageURL = character.image else {
            characterImageView.image = UIImage(systemName: "person.fill")
            return
        }
        
        imageTask = Task { @MainActor in
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                if let image = UIImage(data: data) {
                    self.characterImageView.image = image
                }
            } catch {
                self.characterImageView.image = UIImage(systemName: "person.fill")
            }
        }
    }
}

