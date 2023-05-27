//
//  ProfileViewModel.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import Foundation
import FirebaseDatabase
import FirebaseCore
protocol ProfileViewModelProtocol: ViewModelProtocol {
    var onStateDidChange: ((ProfileViewModel.State) -> Void)? { get set }
    func uploadFoto(currentUserId: String, photo: Data)
    func downloadUserInfo(userID: String, completion: @escaping (_ userName: String?, _ avatarURL: String?) -> Void)
    func openGallery(delegate: UIViewController)
    func dismiss()
    func pop()
    func addposts(userName: String, image: Data, likesCount: Int, postText: String?, postID: String)
    func downloadImage(imageURL: String, completion: @escaping (Data) -> Void)
    func viewInputDidChange(viewInput: ProfileViewModel.ViewInput)
    func plusLike(userID: String, postID: String, likesCount: Int)
    func minusLike(userID: String, postID: String, likesCount: Int)
    func presentPhoto(delegate: UIViewControllerTransitioningDelegate, indexPath: IndexPath)
}

class ProfileViewModel: ProfileViewModelProtocol {
    
    enum ViewInput {
        case tapPublication
        case tapPhoto
        case tapPost
    }
    
    enum State {
        case initial
        case reloadData
    }
    
    var onStateDidChange: ((State) -> Void)?

    private(set) var state: State = .initial {
        didSet {
            onStateDidChange?(state)
        }
    }

    var coordinator: ProfileCoordinator?
    
    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func uploadFoto(currentUserId: String, photo: Data) {
        firebaseService.upload(currentUserId: currentUserId, photo: photo) { (result) in
            switch result {
                
            case .success(let url):
                UserDefaults.standard.set(url.absoluteString, forKey: "imageURL")
               
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func downloadUserInfo(userID: String, completion: @escaping (_ userName: String?, _ avatarURL: String?) -> Void) {
       
        
        firebaseService.downloadUserInfo(userID: userID) { value, id in
            guard let value,
            let id else {
                completion(nil, nil)
                return }
            let username = value["userName"] as? String ?? ""
            UserDefaults.standard.set(username, forKey: "userName")
            guard let avatarURL = value["avatarImageURL"] as? String else {
                completion(username, nil)
                return
            }
            UserDefaults.standard.set(avatarURL, forKey: "imageURL")
            guard let poste = value["posts"] as? NSDictionary else {
                completion(username, avatarURL)
                return}
            for i in id {
                let post = poste[i] as? NSDictionary ?? [:]
                let userName = post["username"] as? String ?? ""
                let image = post["image"] as? String ?? ""
                let postID = post["postID"] as? String ?? ""
                let postText = post["postText"] as? String ?? ""
                let likesCount = post["likesCount"] as? Int ?? 0
                let isLike = post["isLike"] as? Bool ?? false
                self.downloadImage(imageURL: image) { data in
                    let answer = Post(author: userName, description: postText, image: data, likesCount: likesCount, isLike: isLike, postID: postID, userID: userID)
                    posts.append(answer)
                    self.state = .reloadData
                }
                
            }
            completion(username, avatarURL)
        }
        
    }
    
    func downloadImage(imageURL: String, completion: @escaping (Data) -> Void) {
        firebaseService.downloadImage(imageURL: imageURL) { data in
            guard let data else {
                return }
            completion(data)
        }
        
    }
    
    func addposts(userName: String, image: Data, likesCount: Int, postText: String?, postID: String) {
        firebaseService.addposts(userName: userName, image: image, likesCount: likesCount, postText: postText, postID: postID)
    }
    
    func openGallery(delegate: UIViewController) {
        coordinator?.presentImagePicker(delegate: delegate)
    }
    func dismiss() {
        coordinator?.dismiss()
    }
    
    func pop() {
        coordinator?.pop()
    }
    
    func viewInputDidChange(viewInput: ViewInput) {
        switch viewInput {
        case .tapPublication:
            coordinator?.pushViewController(self, .publication(self))
        case .tapPhoto:
            coordinator?.pushViewController(self, .photo(self))
        case .tapPost:
            coordinator?.pushViewController(nil, .post)
        }
    }
    func plusLike(userID: String, postID: String, likesCount: Int) {
        firebaseService.plusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    func minusLike(userID: String, postID: String, likesCount: Int) {
        firebaseService.minusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    
    func presentPhoto(delegate: UIViewControllerTransitioningDelegate, indexPath: IndexPath) {
        coordinator?.presentPhoto(delegate: delegate, indexPath: indexPath)
    }
}

