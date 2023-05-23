//
//  PostTableViewCell.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit
protocol CellDelegate: AnyObject {
    func reload()
    func plusLike(postID: String)
    func minusLike(postID: String, likesCount: Int)
}

class PostTableViewCell: UITableViewCell {
    weak var delegat: CellDelegate?
    let coreManager = CoreDataManager.shared
    private var postID = ""
    private var likesCount = 0
    private var isLike = false
    private lazy var postImageView: UIImageView = {
        let postImageView = UIImageView()
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.backgroundColor = .black
        postImageView.contentMode = .scaleAspectFit
        postImageView.clipsToBounds = true
        postImageView.isUserInteractionEnabled = true
        return postImageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .createColor(light: .systemGray, dark: .white)
        descriptionLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        return descriptionLabel
    }()
    
    private lazy var authorLabel: UILabel = {
        let authorLabel = UILabel()
        authorLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        authorLabel.textColor = .createColor(light: .black, dark: .white)
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.numberOfLines = 2
        
        return authorLabel
    }()
    
    private lazy var likesLabel: UILabel = {
        let likesLabel = UILabel()
        likesLabel.translatesAutoresizingMaskIntoConstraints = false
        likesLabel.font = UIFont.systemFont(ofSize: 16)
        likesLabel.textColor = .createColor(light: .black, dark: .white)
        likesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        return likesLabel
    }()
    
    lazy var likeButton: UIButton = {
        let likeButton = UIButton(type: .custom)
        likeButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        likeButton.tintColor = isLike ? .systemRed : .lightGray
        likeButton.addTarget(self, action: #selector(tapLike), for: .touchUpInside)
        return likeButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.imageViewGesture()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with viewModel: Post, index: Int ) {
        self.postImageView.image = UIImage(data: viewModel.image)
        self.authorLabel.text = viewModel.author
        self.descriptionLabel.text = viewModel.description
        self.likeButton.tag = index
        self.postID = viewModel.postID
        var count = [Like]()
        for like in coreManager.likes {
            if like.tag == "\(index)" {
                count.append(like)
            }
        }
        self.isLike = viewModel.isLike
        self.likesCount = viewModel.likesCount
        self.likesLabel.text = "Нравится: \(likesCount)"
        likeButton.tintColor = self.isLike ? .systemRed : .lightGray
    }
    
    
    func setupView() {
        self.contentView.addSubview(postImageView)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(authorLabel)
        self.contentView.addSubview(likesLabel)
        self.contentView.addSubview(likeButton)
        
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
            
            self.likeButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,constant: 16),
            self.likeButton.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 16),
            self.likeButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            
            self.likesLabel.centerYAnchor.constraint(equalTo: self.likeButton.centerYAnchor),
            self.likesLabel.leadingAnchor.constraint(equalTo: self.likeButton.trailingAnchor, constant: 5),
            
        ])
    }
    
    func imageViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapLike))
        gesture.numberOfTapsRequired = 2
        self.postImageView.addGestureRecognizer(gesture)
    }
    
    
    @objc private func tapLike() {
//        guard let postImage = self.postImageView.image?.pngData() else { return }
        let authorText = self.authorLabel.text ?? ""
        let descriptionText = self.descriptionLabel.text ?? ""
        let tag = "\(self.likeButton.tag)"
        if isLike {
            self.delegat?.minusLike(postID: self.postID, likesCount: self.likesCount)
            self.isLike.toggle()
            guard let indexPost = posts.firstIndex(where: {$0.postID == self.postID}) else { return }
            var post = posts[indexPost]
            post.isLike = false
            post.likesCount -= 1
            self.delegat?.reload()
        } else {
            self.delegat?.plusLike(postID: self.postID)
            self.coreManager.reloadLikes()
            guard let indexPost = posts.firstIndex(where: {$0.postID == self.postID}) else { return }
            var post = posts[indexPost]
            post.isLike = true
            post.likesCount += 1
            self.delegat?.reload()
        }
//        if UserDefaults.standard.bool(forKey: "isLike\(likeButton.tag)") == false {
//            coreManager.createLike(authorText: authorText, descriptionText: descriptionText, postImage: postImage, tag: tag)  {
//                UserDefaults.standard.set(true, forKey: "isLike" + tag)
//                DispatchQueue.main.async {
//                    self.delegat?.plusLike(postID: self.postID)
//                    self.coreManager.reloadLikes()
//                    self.delegat?.reload()
//                }
//            }
//
//            self.delegat?.reload()
//        } else {
//            coreManager.likes.forEach { like in
//                if like.tag == tag {
//                    coreManager.deleteLike(like: like)
//                    UserDefaults.standard.set(false, forKey: "isLike" + tag)
//                    self.delegat?.reload()
//                }
//            }
//        }
    }
}



