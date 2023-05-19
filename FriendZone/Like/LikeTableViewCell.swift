//
//  LikeTableViewCell.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

class LikeTableViewCell: UITableViewCell {
    
    let coreManager = CoreDataManager.shared
    
    private lazy var postImageView: UIImageView = {
        let postImageView = UIImageView()
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.backgroundColor = .black
        postImageView.contentMode = .scaleAspectFit
        postImageView.clipsToBounds = true
        
        return postImageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        return descriptionLabel
    }()
    
    private lazy var authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        authorLabel.textColor = .black
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.numberOfLines = 2

        return authorLabel
    }()
    
    private lazy var likesLabel: UILabel = {
        let likesLabel = UILabel()
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        likesLabel.font = UIFont.systemFont(ofSize: 16)
        likesLabel.textColor = .black
        likesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        return likesLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
    func setup(with viewModel: Like)  {
        DispatchQueue.main.async {
            if let data = viewModel.postImage, let image = UIImage(data: data) {
                self.postImageView.image = image
            }
        }
        self.authorLabel.text = viewModel.authorText
        self.descriptionLabel.text = viewModel.descriptionText
        var count = [Like]()
        guard let tag = viewModel.tag else { return }
        for like in coreManager.likes {
            if like.tag == tag {
                count.append(like)
            }
        }
//        let likeMeas = "Likes".localized
//        let like = String(format: likeMeas, count.count)
        self.likesLabel.text = "Нравится"
    }

    
    func setupView() {
        self.contentView.addSubview(postImageView)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(authorLabel)
        self.contentView.addSubview(likesLabel)
        
        
        NSLayoutConstraint.activate([
            self.authorLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.authorLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            
            self.postImageView.topAnchor.constraint(equalTo: self.authorLabel.bottomAnchor, constant: 16),

            self.postImageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.postImageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),

            self.postImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.postImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.postImageView.heightAnchor.constraint(equalTo: self.postImageView.widthAnchor),
            
            self.descriptionLabel.topAnchor.constraint(equalTo: self.postImageView.bottomAnchor, constant: 16),
            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.descriptionLabel.bottomAnchor.constraint(equalTo: self.likesLabel.topAnchor, constant: -16),
            
            self.likesLabel.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 16),
            self.likesLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.likesLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            
            
            
            
            
            
        ])
    }
    
    
    
    
}
