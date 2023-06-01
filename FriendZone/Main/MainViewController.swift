//
//  MainViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    
    private let viewModel: MainViewModelProtocol
    
    init(viewModel: MainViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
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
        collectionView.register(MainAvatarCollectionViewCell.self, forCellWithReuseIdentifier: MainAvatarCollectionViewCell.identifire)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 1
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifire)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        if currentReachabilityStatus == .notReachable {
            self.alertOk(title: "Проверьте интернет соединение", message: nil)
            return
        }
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        viewModel.downloadAllUsers { 
            for user in users {
                let userID = user.userID
                self.viewModel.downloadUserInfo(userID: userID) { userName, avatarData in
                    if self.currentReachabilityStatus == .notReachable {
                        self.alertOk(title: "Проверьте интернет соединение", message: nil)
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    guard let userName else {return}
                    let avatar = Avatar(image: avatarData, name: userName, userID: userID)
                    if avatarArray.contains(where: {$0.userID == avatar.userID}) {
                        let index = avatarArray.firstIndex(where: {$0.userID == avatar.userID})
                        let avtar = avatarArray[index!]
                        if avtar.image == avatar.image, avtar.name == avatar.name {
                            print("contains Avatar")
                        } else {
                            avatarArray.remove(at: index!)
                            avatarArray.insert(avatar, at: index!)
                            self.collectionView.reloadData()
                        }
                    } else {
                        avatarArray.append(avatar)
                    }
                }
            }
        }
        
    }
    
    func bindViewModel() {
        viewModel.onStateDidChange = { [weak self] state in
            guard let self = self else {
                return
            }
            switch state {
            case .initial:
                break
            case .reloadData:
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.tableView.reloadData()
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentReachabilityStatus == .notReachable {
            self.alertOk(title: "Проверьте интернет соединение", message: nil)
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            return
        }
        self.collectionView.reloadData()
        self.tableView.reloadData()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeObservers()
    }
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
        
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.collectionView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.4),
            
            self.tableView.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        
            self.activityIndicator.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -16),
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            
            
        ])
    }
    
}
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatarArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainAvatarCollectionViewCell.identifire, for: indexPath) as! MainAvatarCollectionViewCell
        
        cell.setup(model: avatarArray[indexPath.row])
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = (collectionView.frame.width - 50) / 4.2
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let user = avatarArray[indexPath.row]
        let userID = user.userID
        viewModel.viewInputDidChange(viewInput: .tapUser, userID: userID, postArray: nil)
    }
}
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifire, for: indexPath) as! PostTableViewCell
        
        cell.setup(with: allPosts[indexPath.row], index: indexPath.row, editButtonIsHidden: true)
        
    if allPosts[indexPath.row].isLike {
            cell.likeButton.tintColor = .systemRed
        } else {
            cell.likeButton.tintColor = .lightGray
        }
        
        cell.delegat = self
        return cell
  
    }
    
}
extension MainViewController: MainAvatarCollectionDelegate {
    func reload() {
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
}
extension  MainViewController: CellDelegate {
    func editPost(index: Int) {}
    
    func minusLike(userID: String, postID: String, likesCount: Int) {
        viewModel.minusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    
    func plusLike(userID: String, postID: String, likesCount: Int) {
        viewModel.plusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    
    
    
}
