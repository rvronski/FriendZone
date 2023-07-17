//
//  ProfileViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit
import CoreLocation
import UniformTypeIdentifiers

class ProfileViewController: UIViewController {
    
    let userID = UserDefaults.standard.string(forKey: "UserID")
    var avatarUrl: String?
    var userName = ""
    let coreManager = CoreDataManager.shared
    let locationManager = CLLocationManager()
    
    private let viewModel: ProfileViewModelProtocol
    
    init(viewModel: ProfileViewModelProtocol) {
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
    
   
    lazy var profileView: ProfileView = {
        let profileView = ProfileView()
        profileView.avatarImage.image = UIImage(named: "navigationLogo")
        profileView.nameLabel.text = ""
        profileView.delegate = self
        
        return profileView
    }()
    
    override func loadView() {
        super.loadView()
        view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupGesture()
        bindViewModel()
        setupNavigationBar()
        UserDefaults.standard.set(true, forKey: "isFirstTime")
        self.tabBarController?.tabBar.isHidden = false
        profileView.configureTableView(dataSource: self, delegate: self)
        profileView.delegate = self
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    private func downloadUserInfo(completion: @escaping () -> Void) {
        guard  (userID != nil) else {return}
        self.viewModel.downloadUserInfo(userID: userID!) { userName, avatarURL in
            guard let userName else {
                completion()
                return }
            self.userName = userName
            guard let avatarURL else {
                completion()
                return }
            self.avatarUrl = avatarURL
                completion()
        }
    }
    
    func bindViewModel() {
        ProfileViewModel.onStateDidChange = { [weak self] state in
            guard let self = self else {
                return
            }
            switch state {
            case .initial:
                break
            case .reloadData:
                DispatchQueue.main.async {
                    self.profileView.reload()
                    CustomHeaderView().reload()
                }
            case .addPost:
                self.viewModel.viewInputDidChange(viewInput: .tapPublication)
            }
        }
    }
    
    func getUserInfo() {
        downloadUserInfo {
            if self.currentReachabilityStatus == .notReachable {
                self.alertOk(title: "Проверьте интернет соединение", message: nil)
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                return
            }
            guard (self.avatarUrl != nil) else {
                DispatchQueue.main.async {
                    self.profileView.nameLabel.text = self.userName
                    self.profileView.reload()
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                return }
            self.viewModel.downloadImage(imageURL: self.avatarUrl!) { data in
                DispatchQueue.main.async {
                    self.profileView.avatarImage.image = UIImage(data: data)
                    self.profileView.nameLabel.text = self.userName
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.profileView.reload()
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
        getUserInfo()
        profileView.reload()
        CustomHeaderView().reload()
        let userName = UserDefaults.standard.string(forKey: "UserName") ?? ""
        let lastName = UserDefaults.standard.string(forKey: "LastName") ?? ""
        profileView.nameLabel.text = userName + " " + lastName
    }
    
    private func setupNavigationBar() {
        let rightButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), target: self, action: #selector(popToLogin))
        rightButton.tintColor = .buttonColor
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func setupView(){
        
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(self.activityIndicator)
        
        NSLayoutConstraint.activate([
    
            self.activityIndicator.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: -16),
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            
            
        ] )
    }
    private var avatarWidthConstraint: NSLayoutConstraint?
    private var avatarHeightConstraint: NSLayoutConstraint?
    
    var isAvatarIncreased = false
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeObservers()
    }
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
        
    }
    @objc private func popToLogin() {
        self.alertOkCancel(title: "Выйти из профиля?", message: nil) { [weak self] in
            UserDefaults.standard.set(nil, forKey: "UserID")
            UserDefaults.standard.set(nil, forKey: "UserName")
            UserDefaults.standard.set(nil, forKey: "LastName")
            posts.removeAll()
            allPosts.removeAll()
            self?.viewModel.popToLogin()
        }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
   
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if  section == 0  {
            let headerView = CustomHeaderView()
            headerView.delegate = self
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if  section == 0  {
            return "Фотографии"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifire, for: indexPath) as! PostTableViewCell
            cell.setup(with: posts[indexPath.row], index: indexPath.row, editButtonIsHidden: false)
           
        if posts[indexPath.row].isLike {
                cell.likeButton.tintColor = .systemRed
            } else {
                cell.likeButton.tintColor = .lightGray
            }
            
            cell.delegat = self
            return cell
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
}

extension ProfileViewController: ProfileViewDelegate {
    
    func pushEditButton() {
        let image = profileView.avatarImage.image
        guard let data = image?.jpegData(compressionQuality: 0.4) else {return}
        self.viewModel.viewInputDidChange(viewInput: .tapEdit(data))
    }
    
    func pushPhotoButton() {
        self.viewModel.viewInputDidChange(viewInput: .tapPhoto)
    }
    
    func tapAvatar() {
        
        self.presenActionSheet(title1: "Поменять аватар", title2: "Посмотреть аватар") { [weak self] in
            self?.viewModel.openGallery(delegate: self!)
        } completionTwo: { [weak self] in
            let data = self?.profileView.avatarImage.image?.pngData()
            self?.viewModel.presentAvatar(delegate: self!, data: data!)
        }
    }
    
    func pushNoteButton() {
        viewModel.viewInputDidChange(viewInput: .tapPublication)
    }
}

extension ProfileViewController: CellDelegate {
    func editPost(index: Int) {
        let post = posts[index]
        viewModel.viewInputDidChange(viewInput: .tapEditPost(post))
        
    }
    
    func minusLike(userID: String, postID: String, likesCount: Int) {
        viewModel.minusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    
    func plusLike(userID: String, postID: String, likesCount: Int) {
        viewModel.plusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    
    func reload() {
        profileView.reload()
    }
}
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        if currentReachabilityStatus == .notReachable {
            self.viewModel.dismiss()
            self.alertOk(title: "Проверьте интернет соединение", message: nil)
            
        }
        self.profileView.avatarImage.image = image
        self.viewModel.uploadFoto(currentUserId: userID!, photo: imageData)
        self.viewModel.dismiss()
    }
}

extension ProfileViewController: CustomHeaderViewDelegate {
    func tapCell() {
        self.viewModel.viewInputDidChange(viewInput: .tapPhoto)
    }
}
extension ProfileViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AvatarTransitionAnimator(presentationStartView: self.profileView.avatarImage, isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AvatarTransitionAnimator(presentationStartView: self.profileView.avatarImage, isPresenting: false)
    }
}
