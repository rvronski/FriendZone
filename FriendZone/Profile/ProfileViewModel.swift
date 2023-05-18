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
    func downloadAvatar(avatarURL: String, completion: @escaping (Data?) -> Void)
    func downloadUserInfo(completion: @escaping (String?, Data?) -> Void)
    func uploadFoto(delegate: UIViewController)
    func dismiss()
    func addposts(userName: String, image: UIImage?, likes: Int, postText: String?)
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
    func downloadAvatar(avatarURL: String, completion: @escaping (Data?) -> Void) {
        firebaseService.downloadAvatar(avatarURL: avatarURL) { data in
            guard let data else {
                completion(nil)
                return }
            completion(data)
        }
    }
    func downloadUserInfo(completion: @escaping (String?, Data?) -> Void) {
        var username = ""
        var avatarURL = ""
        firebaseService.downloadUserInfo { value, id in
            guard let value,
            let id else {
                completion(nil, nil)
                return }
            var poste = [PostAnswer]()
            username = value["userName"] as? String ?? ""
            avatarURL = value["avatarImageURL"] as? String ?? ""
            let email = value["email"] as? String ?? ""
            let posts = value["posts"] as? NSDictionary ?? [:]
            for i in id {
                let post = posts[i] as? NSDictionary ?? [:]
                let userName = post["userName"] as? String ?? ""
                let image = post["image"] as? String ?? ""
                let postID = post["postID"] as? String ?? ""
                let postText = post["postText"] as? String ?? ""
                let likes = post["likes"] as? Int ?? 0
                let answer = PostAnswer(userName: userName, image: image, likes:  likes, postText: postText)
                poste.append(answer)
            }
           
            print("🍅 \(value)")
            print("🍇 \(poste)")
            UserDefaults.standard.set(username, forKey: "userName")
            self.firebaseService.downloadAvatar(avatarURL: avatarURL) { data in
                guard let data else {
                    completion(username, nil)
                    return }
                completion(username,data)
            }
        }
        
    }
    
    func addposts(userName: String, image: UIImage?, likes: Int, postText: String?) {
        firebaseService.addposts(userName: userName, image: image, likes: likes, postText: postText)
    }
    
    func uploadFoto(delegate: UIViewController) {
        coordinator?.presentImagePicker(delegate: delegate)
    }
    func dismiss() {
        coordinator?.dismiss()
    }
}

