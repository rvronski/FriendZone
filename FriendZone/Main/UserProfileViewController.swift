//
//  UserProfileViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 26.05.2023.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    var userID: String
    private let viewModel: MainViewModelProtocol
    
    init(userID: String, viewModel: MainViewModelProtocol) {
        self.userID = userID
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var nameLabel = CustomLabel(inform: "", size: 18, weight: .bold, color: .createColor(light: .black, dark: .white))

    lazy var publicationsButton = CustomButton(buttonText: "Публикации", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var publicationsCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var followButton = CustomButton(buttonText: "Подписок", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var followCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var followersButton =  CustomButton(buttonText: "Подписчики", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var followersCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var fotoLabel = CustomLabel(inform: "Фотографии", size: 20, weight: .bold, color: .createColor(light: .black, dark: .white))
    
    private var userPosts = [Post]()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.dragInteractionEnabled = true
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifire)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.identifire)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
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
    
    weak var delegate: ProfileViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.gestureAvatar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for post in allPosts {
            if post.userID == self.userID {
                if userPosts.contains(post) {
                    continue
                } else {
                    self.userPosts.append(post)
                    self.tableView.reloadData()
                }
            }
        }
        if avatarArray.contains(where: {$0.userID == self.userID}) {
            guard let avatar = avatarArray.first(where: {$0.userID == self.userID}) else {return}
            let data = UIImage(named: "navigationLogo")!.pngData()
            self.avatarImage.image = UIImage(data: avatar.image ?? data!)
            self.nameLabel.text = avatar.name
        }
        print(self.userPosts.count)
        self.publicationsCount.text = "\(self.userPosts.count)"
        self.tableView.reloadData()
    }
        
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.fotoLabel)
        self.view.addSubview(self.avatarImage)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.followButton)
        self.view.addSubview(self.followCount)
        self.view.addSubview(self.followersButton)
        self.view.addSubview(self.followersCount)
        self.view.addSubview(self.publicationsButton)
        self.view.addSubview(self.publicationsCount)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.collectionView)
        NSLayoutConstraint.activate([
            
            self.avatarImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.avatarImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            self.avatarImage.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0.2415),
            self.avatarImage.heightAnchor.constraint(equalTo: self.avatarImage.widthAnchor),
            
            self.nameLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant:27),
            self.nameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.57),
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
            
            self.fotoLabel.topAnchor.constraint(equalTo: self.avatarImage.bottomAnchor, constant: 20),
            self.fotoLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
            
            self.collectionView.topAnchor.constraint(equalTo: self.fotoLabel.bottomAnchor, constant: 10),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.collectionView.heightAnchor.constraint(equalTo: self.collectionView.widthAnchor, multiplier: 0.25),
            
            self.tableView.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    func reload() {
        self.tableView.reloadData()
        self.publicationsCount.text = "\(posts.count)"
    }
    
    private func gestureAvatar() {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: #selector(tapAvatar))
        self.avatarImage.addGestureRecognizer(gestureAvatar)
    }
    @objc func tapAvatar() {
        let data = self.avatarImage.image?.pngData()
        self.viewModel.presentAvatar(delegate: self, data: data!)
    }
}
extension UserProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.userPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifire, for: indexPath) as! PostTableViewCell
        cell.setup(with: userPosts[indexPath.row], index: indexPath.row)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("table cell tap \(indexPath.row)")
    }
    
}
extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosCollectionViewCell.identifire, for: indexPath) as! PhotosCollectionViewCell
        cell.setup(model: self.userPosts[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = (collectionView.frame.width - 50) / 4
        let itewHeight = itemWidth * 0.8
        return CGSize(width: itemWidth, height: itewHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.viewInputDidChange(viewInput: .tapPhoto, userID: nil, postArray: self.userPosts)
    }
}
extension UserProfileViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AvatarTransitionAnimator(presentationStartView: self.avatarImage, isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AvatarTransitionAnimator(presentationStartView: self.avatarImage, isPresenting: false)
    }
}
