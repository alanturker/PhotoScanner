//
//  GroupCollectionViewCell.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import UIKit

final class GroupCollectionViewCell: UICollectionViewCell {
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = UIColor.systemBlue
        contentView.addSubview(containerView)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        containerView.addSubview(iconImageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        
        countLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        countLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        countLabel.textAlignment = .center
        countLabel.numberOfLines = 1
        containerView.addSubview(countLabel)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            countLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with item: GroupItem) {
        titleLabel.text = item.title
        countLabel.text = formatCount(item.count)
        
        switch item.type {
        case .group:
            iconImageView.image = UIImage(systemName: "folder.fill")
            containerView.backgroundColor = UIColor.systemBlue
        case .other:
            iconImageView.image = UIImage(systemName: "questionmark.folder.fill")
            containerView.backgroundColor = UIColor.systemOrange
        }
    }
    
    private func formatCount(_ count: Int) -> String {
        return "\(count) photo\(count == 1 ? "" : "s")"
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.transform = self.isHighlighted ?
                    CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
                self.alpha = self.isHighlighted ? 0.8 : 1.0
            }
        }
    }
}
