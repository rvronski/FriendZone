//
//  MainAvatarCollectionViewCell.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 24.05.2023.
//

import UIKit

protocol MainAvatarCollectionDelegate: AnyObject {
    func reload()
}

class MainAvatarCollectionViewCell: UICollectionViewCell {
    
    static let identifire = "collectionAvatar"
    
    weak var delegate: MainAvatarCollectionDelegate?
    
    lazy var avatarImage = CustomImageView()
    private lazy var nameLabel = CustomLabel(inform: "", size: 13, weight: .regular, color: .black)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(model: Avatar) {
        self.nameLabel.text = model.name
        let data = UIImage(named: "navigationLogo")?.pngData()
        self.avatarImage.image = UIImage(data: model.image ?? data!)
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.height/2
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.width/2
        layoutIfNeeded()
    }
//
    private func setupView() {
        self.contentView.addSubview(avatarImage)
        self.contentView.addSubview(nameLabel)
        self.avatarImage.layer.borderColor = UIColor.buttonColor.cgColor
        self.avatarImage.layer.borderWidth = 0.3
        
        NSLayoutConstraint.activate([
        
            self.avatarImage.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.avatarImage.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.avatarImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.avatarImage.heightAnchor.constraint(equalTo: self.avatarImage.widthAnchor),
            
            self.nameLabel.centerXAnchor.constraint(equalTo: self.avatarImage.centerXAnchor),
            self.nameLabel.topAnchor.constraint(equalTo: self.avatarImage.bottomAnchor, constant: 10),
            
        ])
//        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.width/2
    }
}

