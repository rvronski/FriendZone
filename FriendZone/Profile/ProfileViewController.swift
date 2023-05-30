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
    
    var userID = UserDefaults.standard.string(forKey: "UserID")
    var imageURL = UserDefaults.standard.string(forKey: "imageURL")
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
        
        self.tabBarController?.tabBar.isHidden = false
        //        UserDefaults.standard.set(false, forKey: "isLike")
        profileView.configureTableView(dataSource: self, delegate: self)
        profileView.delegate = self
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
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
    
    private func downloadUserInfo(completion: @escaping () -> Void) {
        guard let userID else {return}
        self.viewModel.downloadUserInfo(userID: userID) { userName, avatarURL in
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
        viewModel.onStateDidChange = { [weak self] state in
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
        
        profileView.reload()
        CustomHeaderView().reload()
        let userName = UserDefaults.standard.string(forKey: "UserName") ?? ""
        let lastName = UserDefaults.standard.string(forKey: "LastName") ?? ""
        profileView.nameLabel.text = userName + " " + lastName
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
    
    func changeLayoutAvatar() {
//        let closeButton = avatarView.closeButton
//        let avatarImage = self.avatarView.avatarImageView
//        let widthScreen = UIScreen.main.bounds.width
//        let widthAvatar = avatarImage.bounds.width
//        let width = widthScreen / widthAvatar
//
//        UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeCubic) {
//            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) { [self] in
//                self.avatarView.isHidden = false
//                self.avatarView.bringSubviewToFront(avatarImage)
//                self.avatarView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//                avatarImage.transform = self.isAvatarIncreased ? .identity : CGAffineTransform(scaleX: width, y: width)
//                avatarImage.layer.borderWidth = self.isAvatarIncreased ? 3 : 0
//                avatarImage.center = self.isAvatarIncreased ? CGPoint(x: 63.166666666666664, y: 63.166666666666664) : CGPoint(x: self.avatarView.bounds.midX, y: self.avatarView.bounds.midY)
//                avatarImage.layer.cornerRadius = self.isAvatarIncreased ? avatarImage.frame.height/2 : 0
//                closeButton.isHidden = self.isAvatarIncreased ? true : false
//            }
//
//        } completion: { _ in
//            self.isAvatarIncreased.toggle()
//            if self.isAvatarIncreased == false {
//                self.avatarView.isHidden = true
//            }
//        }
    }
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
    var string = ""
    var image: UIImage?
    var postDragAtIndex = Int()
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
            cell.setup(with: posts[indexPath.row], index: indexPath.row)
//            if coreManager.likes.count == 0  {
//                UserDefaults.standard.set(false, forKey: "isLike\(indexPath.row)")
//            }
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.viewModel.viewInputDidChange(viewInput: .tapPost)
    }
    
}

extension ProfileViewController: ProfileViewDelegate {
    func changeLayout() {
        //
    }
    
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
            print("tap")
        }

            
    }
    
    func pushNoteButton() {
        viewModel.viewInputDidChange(viewInput: .tapPublication)
    }
}

extension ProfileViewController: CellDelegate {
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
extension ProfileViewController: PostViewControllerDelegate {
    func presentImagePicker() {
        viewModel.openGallery(delegate: self)
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
