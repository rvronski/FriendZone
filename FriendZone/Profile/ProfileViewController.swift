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
    var avatarUrl = ""
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
    
    
    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.delegate = self
        return avatarView
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
        self.tabBarController?.tabBar.isHidden = false
        //        UserDefaults.standard.set(false, forKey: "isLike")
        profileView.configureTableView(dataSource: self, delegate: self)
        profileView.delegate = self
        downloadUserInfo {
            self.viewModel.downloadImage(imageURL: self.avatarUrl) { data in
                DispatchQueue.main.async {
                    self.profileView.avatarImage.image = UIImage(data: data)
                    self.profileView.nameLabel.text = self.userName
                    self.profileView.reload()
                }
            }
        }
        
    }
    
    private func downloadUserInfo(completion: @escaping () -> Void) {
        self.viewModel.downloadUserInfo { userName, avatarURL in
            guard let userName,
                  let avatarURL else {return}
                 self.avatarUrl = avatarURL
                 self.userName = userName
                completion()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.avatarView.isHidden = true
        profileView.reload()
        CustomHeaderView().reload()
    }
    
    private func setupView(){
        
        self.view.backgroundColor = .systemBackground
        self.view.addSubview(avatarView)
        self.view.bringSubviewToFront(avatarView)
        
        NSLayoutConstraint.activate([
            
            
            
            self.avatarView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.avatarView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.avatarView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.avatarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.avatarView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
        ] )
    }
    private var avatarWidthConstraint: NSLayoutConstraint?
    private var avatarHeightConstraint: NSLayoutConstraint?
    
    var isAvatarIncreased = false
    
    
    
    func changeLayoutAvatar() {
        let closeButton = avatarView.closeButton
        let avatarImage = self.avatarView.avatarImageView
        let widthScreen = UIScreen.main.bounds.width
        let widthAvatar = avatarImage.bounds.width
        let width = widthScreen / widthAvatar
        
        UIView.animateKeyframes(withDuration: 1, delay: 0, options: .calculationModeCubic) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) { [self] in
                self.avatarView.isHidden = false
                self.avatarView.bringSubviewToFront(avatarImage)
                self.avatarView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                avatarImage.transform = self.isAvatarIncreased ? .identity : CGAffineTransform(scaleX: width, y: width)
                avatarImage.layer.borderWidth = self.isAvatarIncreased ? 3 : 0
                avatarImage.center = self.isAvatarIncreased ? CGPoint(x: 63.166666666666664, y: 63.166666666666664) : CGPoint(x: self.avatarView.bounds.midX, y: self.avatarView.bounds.midY)
                avatarImage.layer.cornerRadius = self.isAvatarIncreased ? avatarImage.frame.height/2 : 0
                closeButton.isHidden = self.isAvatarIncreased ? true : false
            }
            
        } completion: { _ in
            self.isAvatarIncreased.toggle()
            if self.isAvatarIncreased == false {
                self.avatarView.isHidden = true
            }
        }
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

extension ProfileViewController: AvatarViewDelegate, ProfileViewDelegate {
    func pushPhotoButton() {
        self.viewModel.viewInputDidChange(viewInput: .tapPhoto)
    }
    
    func changeLayout() {
        self.viewModel.openGallery(delegate: self)
    }
    
    func pushNoteButton() {
        viewModel.viewInputDidChange(viewInput: .tapPublication)
    }
}

extension ProfileViewController: CellDelegate {
    func minusLike(postID: String, likesCount: Int) {
        viewModel.minusLike(postID: postID, likesCount: likesCount)
    }
    
    func plusLike(postID: String, likesCount: Int) {
        viewModel.plusLike(postID: postID, likesCount: likesCount)
    }
    
    func reload() {
        profileView.reload()
    }
}
extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
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
