//
//  ShimmerCollectionViewCell.swift
//  Last
//
//  Created by Abdelrahman Mohamed on 03.11.2025.
//

import UIKit

final class ShimmerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ShimmerCollectionViewCell"
    
    private let shimmerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startShimmer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(shimmerView)
        NSLayoutConstraint.activate([
            shimmerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func startShimmer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemGray6.cgColor,
            UIColor.systemGray5.cgColor,
            UIColor.systemGray6.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 20
        
        shimmerView.layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.5
        animation.repeatCount = .greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        gradientLayer.add(animation, forKey: "shimmer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerView.layer.sublayers?.forEach { $0.frame = bounds }
    }
}

