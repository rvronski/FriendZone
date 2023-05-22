//
//  ProfileViewModel.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit
import FirebaseDatabase
import FirebaseCore
protocol ProfileViewModelProtocol: ViewModelProtocol {
    func uploadFoto(currentUserId: String, photo: UIImage)
    func downloadUserInfo(completion: @escaping (_ userName: String?, _ postInfo: [PostAnswer]?, _ avatarURL: String?) -> Void)
    func uploadFoto(delegate: UIViewController)
    func dismiss()
    func addposts(userName: String, image: UIImage?, likes: Int, postText: String?, postID: String)
    func downloadImage(imageURL: String, completion: @escaping (Data) -> Void)
    func downloadPostImage(postID: String, completion: @escaping (Data) -> Void)
}

class ProfileViewModel: ProfileViewModelProtocol {
    
    var coordinator: ProfileCoordinator?
    
    private let firebaseService: FirebaseServiceProtocol

    init(checkService: FirebaseServiceProtocol) {
        self.firebaseService = checkService
    }
    
    func uploadFoto(currentUserId: String, photo: UIImage) {
        firebaseService.upload(currentUserId: currentUserId, photo: photo) { (result) in
            switch result {
                
            case .success(let url):
                UserDefaults.standard.set(url.absoluteString, forKey: "imageURL")
               
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func downloadUserInfo(completion: @escaping (_ userName: String?, _ postInfo: [PostAnswer]?, _ avatarURL: String?) -> Void) {
        firebaseService.downloadUserInfo { value, id in
            guard let value,
            let id else {
                completion(nil, nil, nil)
                return }
            var postsAnswer = [PostAnswer]()
            let username = value["userName"] as? String ?? ""
            UserDefaults.standard.set(username, forKey: "userName")
            let avatarURL = value["avatarImageURL"] as? String ?? ""
            UserDefaults.standard.set(avatarURL, forKey: "imageURL")
            let poste = value["posts"] as? NSDictionary ?? [:]
            for i in id {
                let post = poste[i] as? NSDictionary ?? [:]
                let userName = post["username"] as? String ?? ""
                let image = post["image"] as? String ?? ""
                let postID = post["postID"] as? String ?? ""
                let postText = post["postText"] as? String ?? ""
                let likes = post["likes"] as? Int ?? 0

                    let answer = PostAnswer(userName: userName, image: image, likes: likes, postText: postText, postID: postID)
                    postsAnswer.append(answer)
                }

            completion(username,postsAnswer, avatarURL)
        }

    }
    
    func downloadImage(imageURL: String, completion: @escaping (Data) -> Void) {
        firebaseService.downloadImage(imageURL: imageURL) { data in
            guard let data else {
                return }
            completion(data)
        }
        
    }
    func downloadPostImage(postID: String, completion: @escaping (Data) -> Void) {
        firebaseService.downloadAllPostImages(postID: postID) { data in
            completion(data)
        }
    }
    
    func addposts(userName: String, image: UIImage?, likes: Int, postText: String?, postID: String) {
        firebaseService.addposts(userName: userName, image: image, likes: likes, postText: postText, postID: postID)
    }
    
    func uploadFoto(delegate: UIViewController) {
        coordinator?.presentImagePicker(delegate: delegate)
    }
    func dismiss() {
        coordinator?.dismiss()
    }
}

