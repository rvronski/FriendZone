//
//  ProfileView.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

protocol ProfileViewDelegate: AnyObject {
    func changeLayout()
    func pushNoteButton()
}

final class ProfileView: UIView {
    
    lazy var nameLabel = CustomLabel(inform: "", size: 18, weight: .bold, color: .createColor(light: .black, dark: .white))

    lazy var publicationsButton = CustomButton(buttonText: "Публикации", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var publicationsCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var followButton = CustomButton(buttonText: "Подписок", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var followCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var followersButton =  CustomButton(buttonText: "Подписчики", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var followersCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var noteLabel = CustomLabel(inform: "Запись", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var noteButton = ButtonWithSystemImage(background: nil, image: "square.and.pencil", imageSize: 20, symbolScale: .medium, tintcolor: .black)
    
    lazy var historyLabel = CustomLabel(inform: "История", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var historyButton = ButtonWithSystemImage(background: nil, image: "camera", imageSize: 20, symbolScale: .medium, tintcolor: .black)
    
    lazy var fotoLabel =  CustomLabel(inform: "Фото", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var fotoButton = ButtonWithSystemImage(background: nil, image: "photo.stack", imageSize: 20, symbolScale: .medium, tintcolor: .black)
    
//   private lazy var layout: UICollectionViewFlowLayout = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumLineSpacing = 10
//        layout.minimumInteritemSpacing = 10
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        return layout
//    }()
//    
//   private lazy var collectionView: UICollectionView = {
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.backgroundColor = .white
//        collectionView.showsHorizontalScrollIndicator = false
//        return collectionView
//    }()
//    
//    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.dragInteractionEnabled = true
        return tableView
    }()

    lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .orange
        imageView.contentMode = .scaleToFill
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var setStatusButton = CustomButton(buttonText: "Редактировать", textColor: .white, background: .buttonColor, fontSize: 15, fontWeight: .bold)
    
    weak var delegate: ProfileViewDelegate?
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
        self.setupGesture()
        self.gestureAvatar()
        noteButton.tapButton = { [weak self] in
            self?.delegate?.pushNoteButton()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.height/2
    }
    
    private func setupView() {
        self.addSubview(self.tableView)
//        self.addSubview(self.collectionView)
        self.addSubview(self.avatarImage)
        self.addSubview(self.setStatusButton)
        self.addSubview(self.nameLabel)
        self.addSubview(self.followButton)
        self.addSubview(self.followCount)
        self.addSubview(self.followersButton)
        self.addSubview(self.followersCount)
        self.addSubview(self.publicationsButton)
        self.addSubview(self.publicationsCount)
        self.addSubview(self.noteLabel)
        self.addSubview(self.noteButton)
        self.addSubview(self.historyLabel)
        self.addSubview(self.historyButton)
        self.addSubview(self.fotoLabel)
        self.addSubview(self.fotoButton)
       
        
        NSLayoutConstraint.activate([
            
            self.avatarImage.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.avatarImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.avatarImage.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.2415),
            self.avatarImage.heightAnchor.constraint(equalTo: self.avatarImage.widthAnchor),
            
            self.nameLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant:27),
            self.nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.57),
            self.nameLabel.leadingAnchor.constraint(equalTo: self.avatarImage.trailingAnchor, constant: 20),
            
            self.followButton.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 30),
            self.followButton.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor),
            
            self.followCount.bottomAnchor.constraint(equalTo: self.followButton.topAnchor, constant: -5),
            self.followCount.centerXAnchor.constraint(equalTo: self.followButton.centerXAnchor),
            
            self.followersButton.centerYAnchor.constraint(equalTo: self.followButton.centerYAnchor),
            self.followersButton.leadingAnchor.constraint(equalTo: self.followButton.trailingAnchor, constant: 20),
            
            self.followersCount.bottomAnchor.constraint(equalTo: self.followersButton.topAnchor, constant: -5),
            self.followersCount.centerXAnchor.constraint(equalTo: self.followersButton.centerXAnchor),
            
            self.publicationsButton.centerYAnchor.constraint(equalTo: self.followersButton.centerYAnchor),
            self.publicationsButton.leadingAnchor.constraint(equalTo: self.followersButton.trailingAnchor, constant: 20),
            
            self.publicationsCount.bottomAnchor.constraint(equalTo: self.publicationsButton.topAnchor, constant: -5),
            self.publicationsCount.centerXAnchor.constraint(equalTo: self.publicationsButton.centerXAnchor),
            
            self.setStatusButton.topAnchor.constraint(equalTo: self.avatarImage.bottomAnchor, constant: 16),
            self.setStatusButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.setStatusButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.setStatusButton.heightAnchor.constraint(equalToConstant: 40),
            
            self.historyButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.historyButton.topAnchor.constraint(equalTo: self.setStatusButton.bottomAnchor, constant: 16),
            
            self.historyLabel.centerXAnchor.constraint(equalTo: self.historyButton.centerXAnchor),
            self.historyLabel.topAnchor.constraint(equalTo: self.historyButton.bottomAnchor,constant: 5),
            
            self.noteButton.centerYAnchor.constraint(equalTo: self.historyButton.centerYAnchor),
            self.noteButton.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: 50),
            
            self.noteLabel.centerXAnchor.constraint(equalTo: self.noteButton.centerXAnchor),
            self.noteLabel.topAnchor.constraint(equalTo: self.noteButton.bottomAnchor,constant: 5),
            
            self.fotoButton.centerYAnchor.constraint(equalTo: self.historyButton.centerYAnchor),
            self.fotoButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -50),
            
            self.fotoLabel.centerXAnchor.constraint(equalTo: self.fotoButton.centerXAnchor),
            self.fotoLabel.centerYAnchor.constraint(equalTo: self.historyLabel.centerYAnchor),
            
//            self.collectionView.topAnchor.constraint(equalTo: self.historyLabel.bottomAnchor, constant: 16),
//            self.collectionView.leftAnchor.constraint(equalTo: self.leftAnchor),
//            self.collectionView.rightAnchor.constraint(equalTo: self.rightAnchor),
//            self.collectionView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            
            self.tableView.topAnchor.constraint(equalTo: self.historyLabel.bottomAnchor, constant: 16),
            self.tableView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    func reload() {
        self.tableView.reloadData()
//        self.collectionView.reloadData()
        self.publicationsCount.text = "\(posts.count)"
    }
    
    func configureTableView(dataSource: UITableViewDataSource,
                            delegate: UITableViewDelegate) {
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        tableView.register(CustomHeaderView.self, forCellReuseIdentifier: CustomHeaderView.identifire)
//        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifire)
//        collectionView.dataSource = collectionViewDataSource
//        collectionView.delegate = collectionViewDelegate
    }
    
    private func gestureAvatar() {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: #selector(tapAvatar))
        self.avatarImage.addGestureRecognizer(gestureAvatar)
    }
    @objc func tapAvatar() {
        self.delegate?.changeLayout()
    }
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.addGestureRecognizer(tapGesture)
    }
    @objc private func hideKeyboard() {
        self.endEditing(true)
        
    }
    
}
