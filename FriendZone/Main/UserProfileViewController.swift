//
//  UserProfileViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 26.05.2023.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    lazy var nameLabel = CustomLabel(inform: "", size: 18, weight: .bold, color: .createColor(light: .black, dark: .white))

    lazy var publicationsButton = CustomButton(buttonText: "Публикации", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var publicationsCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var followButton = CustomButton(buttonText: "Подписок", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var followCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    lazy var followersButton =  CustomButton(buttonText: "Подписчики", textColor: .createColor(light: .black, dark: .white), background: nil, fontSize: 14, fontWeight: .regular)
    
    lazy var followersCount = CustomLabel(inform: "0", size: 14, weight: .regular, color: .createColor(light: .black, dark: .white))
    
    private var userPosts = [Post]()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 1
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
    
    weak var delegate: ProfileViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupGesture()
        self.gestureAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.height/2
    }
        
    private func setupView() {
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.avatarImage)
        self.view.addSubview(self.nameLabel)
        self.view.addSubview(self.followButton)
        self.view.addSubview(self.followCount)
        self.view.addSubview(self.followersButton)
        self.view.addSubview(self.followersCount)
        self.view.addSubview(self.publicationsButton)
        self.view.addSubview(self.publicationsCount)
       
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
            
            
            self.tableView.topAnchor.constraint(equalTo: self.avatarImage.bottomAnchor, constant: 20),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    func reload() {
        self.tableView.reloadData()
        self.publicationsCount.text = "\(posts.count)"
    }
    
    func configureTableView(dataSource: UITableViewDataSource,
                            delegate: UITableViewDelegate) {
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifire)

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
        self.view.addGestureRecognizer(tapGesture)
    }
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
        
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
    
    
}
