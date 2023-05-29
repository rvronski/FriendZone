//
//  MainViewModel.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

protocol MainViewModelProtocol: ViewModelProtocol {
    var onStateDidChange: ((MainViewModel.State) -> Void)? { get set }
    func viewInputDidChange(viewInput: MainViewModel.ViewInput, userID: String?, postArray: [Post]?)
    func downloadAllUsers(completion: @escaping () -> Void)
    func downloadUserInfo(userID: String, completion: @escaping (_ userName: String?, _ avatarImageData: Data?) -> Void)
    func plusLike(userID: String, postID: String, likesCount: Int)
    func minusLike(userID: String, postID: String, likesCount: Int)
    func presentPhoto(delegate: UIViewControllerTransitioningDelegate, indexPath: IndexPath, userPost: [Post])
    func removeObservers()
       
}

class MainViewModel: MainViewModelProtocol {
    
    enum ViewInput {
        case tapUser
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
            let lastName = userId["lastName"] as? String ?? ""
            let name = username + " " + lastName
            let avatarURL = userId["avatarImageURL"] as? String
            let email = userId["email"] as? String ?? ""
            let user = User(userName: name, userID: userID, avatarImage: avatarURL, email: email)
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
            let lastName = value["lastName"] as? String ?? ""
            let name = username + " " + lastName
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
                     let answer = Post(author: name, description: postText, image: data, likesCount: likesCount, isLike: isLike, postID: postID, userID: userID)
                    if allPosts.contains(where: {$0.postID == answer.postID}) {
                        let index = allPosts.firstIndex(where: {$0.postID == answer.postID})
                        let post = allPosts[index!]
                        if post == answer {
                            self.state = .initial
                            print("contains")
                        } else {
                            allPosts.remove(at: index!)
                            allPosts.insert(answer, at: index!)
                            self.state = .reloadData
                        }
                        
                    } else {
                        allPosts.append(answer)
                        self.state = .reloadData
                    }
                }
            }
            guard let avatarURL = value["avatarImageURL"] as? String else {
                completion(name, nil)
                return
            }
            self.firebaseService.downloadImage(imageURL: avatarURL) { data in
                guard let data else {
                    completion(name, nil)
                    return}
                completion(name, data)
            }
            
        }
        
    }
    
    func plusLike(userID: String, postID: String, likesCount: Int) {
        firebaseService.plusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    func minusLike(userID: String, postID: String, likesCount: Int) {
        firebaseService.minusLike(userID: userID, postID: postID, likesCount: likesCount)
    }
    func presentPhoto(delegate: UIViewControllerTransitioningDelegate, indexPath: IndexPath, userPost: [Post]) {
        coordinator?.presentPhoto(delegate: delegate, indexPath: indexPath, postArray: userPost)
    }
    
    func viewInputDidChange(viewInput: ViewInput, userID: String?, postArray: [Post]?) {
        switch viewInput {
        case .tapUser:
            coordinator?.pushViewController(userID, nil, self, .user(userID!, self))
        case .tapPhoto:
            coordinator?.pushViewController(nil, postArray, self, .photo(postArray!, self))
        case .tapPost:
            coordinator?.pushViewController(nil, nil, nil, .post)
        }
    }
    func removeObservers() {
        firebaseService.removeObservers()
    }
}
