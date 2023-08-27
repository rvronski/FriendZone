//
//  PhotosTableViewCell.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

class PhotosCollectionViewCell: UICollectionViewCell {

    static let identifire = "PhotosCell"
    
    
    private lazy var imageView = CustomImageView()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(model: Post) {
        self.imageView.image = UIImage(data: model.image)
    }
    
    private func setupView() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.addSubview(imageView)
       
        
        imageView.layer.cornerRadius = 10
        
        NSLayoutConstraint.activate([
            
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
        
        ])
    }
}
