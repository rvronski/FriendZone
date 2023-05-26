//
//  MainViewModel.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import Foundation

protocol MainViewModelProtocol: ViewModelProtocol {
    func downloadAllUsers(completion: @escaping () -> Void)
    func downloadUserInfo(userID: String, completion: @escaping (_ userName: String?, _ avatarImageData: Data?) -> Void)
}

class MainViewModel: MainViewModelProtocol {
    
    var coordinator: MainViewCoordinator?
    
    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func downloadAllUsers(completion: @escaping () -> Void) {
        firebaseService.downloadAllUsers { value, usersID in
            guard let value,
                  let usersID else {return}
            print("downloadAllUsers")
            for userID in usersID {
            let userId = value[userID] as? NSDictionary ?? [:]
            let username = userId["userName"] as? String ?? ""
            let avatarURL = userId["avatarImageURL"] as? String ?? ""
            let email = userId["email"] as? String ?? ""
            let post = userId["posts"] as? NSDictionary ?? [:]
            let user = User(userName: username, userID: userID, avatarImage: avatarURL, email: email)
                users.append(user)
          }
            completion()
        }
    }
    
    func downloadUserInfo(userID: String, completion: @escaping (_ userName: String?, _ avatarImageData: Data?) -> Void) {
        print("downloadUserInfo")
        firebaseService.downloadUserInfo(userID: userID) { value, id in
            guard let value,
            let id else {
                completion(nil, nil)
                return }
            let username = value["userName"] as? String ?? ""
            let avatarURL = value["avatarImageURL"] as? String ?? ""
            let poste = value["posts"] as? NSDictionary ?? [:]
            for i in id {
                let post = poste[i] as? NSDictionary ?? [:]
                let userName = post["username"] as? String ?? ""
                let image = post["image"] as? String ?? ""
                let postID = post["postID"] as? String ?? ""
                let postText = post["postText"] as? String ?? ""
                let likesCount = post["likesCount"] as? Int ?? 0
                let isLike = post["isLike"] as? Bool ?? false
                self.firebaseService.downloadImage(imageURL: image) { data in
                    guard let data else {return}
                     let answer = Post(author: userName, description: postText, image: data, likesCount: likesCount, isLike: isLike, postID: postID, userID: userID)
                    if allPosts.contains(where: {$0 == answer}) {
                        print("contains")
                    } else {
                        allPosts.append(answer)
                    }
                }
            }
            self.firebaseService.downloadImage(imageURL: avatarURL) { data in
                guard let data else {
                    completion(username, nil)
                    return}
                completion(username, data)
            }
            
        }
        
    }
}
