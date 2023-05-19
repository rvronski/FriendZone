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
    func downloadUserInfo(completion: @escaping (_ userName: String?, _ avatarImage:Data?, _ postImage: [Data]?, _ postInfo: [PostAnswer]?) -> Void)
    func uploadFoto(delegate: UIViewController)
    func dismiss()
    func addposts(userName: String, image: UIImage?, likes: Int, postText: String?, postID: String)
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
    
    func downloadUserInfo(completion: @escaping (_ userName: String?, _ avatarImage:Data?, _ postImage: [Data]?, _ postInfo: [PostAnswer]?) -> Void) {
        var username = ""
        var avatarURL = ""
        firebaseService.downloadUserInfo { value, id in
            guard let value,
            let id else {
                completion(nil, nil, nil, nil)
                return }
            var postsAnswer = [PostAnswer]()
            var datasArray = [Data]()
            username = value["userName"] as? String ?? ""
            avatarURL = value["avatarImageURL"] as? String ?? ""
            let email = value["email"] as? String ?? ""
            let poste = value["posts"] as? NSDictionary ?? [:]
            for i in id {
                let post = poste[i] as? NSDictionary ?? [:]
                let userName = post["username"] as? String ?? ""
                let image = post["image"] as? String ?? ""
                let postID = post["postID"] as? String ?? ""
                let postText = post["postText"] as? String ?? ""
                let likes = post["likes"] as? Int ?? 0
                self.firebaseService.downloadImage(imageURL: image) { data in
                        guard let data else { return }
                    datasArray.append(data)
                    }
                let answer = PostAnswer(userName: userName, image: image, likes: likes, postText: postText, postID: postID)
                postsAnswer.append(answer)
            }
            
            UserDefaults.standard.set(username, forKey: "userName")
            self.firebaseService.downloadImage(imageURL: avatarURL) { data in
                guard let data else {
                    completion(username, nil, datasArray, postsAnswer)
                    return }
                completion(username, data, datasArray, postsAnswer)
            }
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

