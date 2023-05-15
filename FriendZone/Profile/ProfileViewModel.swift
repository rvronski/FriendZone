//
//  ProfileViewModel.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit

protocol ProfileViewModelProtocol: ViewModelProtocol {
    func uploadFoto(currentUserId: String, photo: UIImage)
    func downloadAvatar(avatarURL: String, completion: @escaping (Data?) -> Void)
    func downloadUserInfo(completion: @escaping (String?) -> Void)
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
    func downloadUserInfo(completion: @escaping (String?) -> Void) {
        firebaseService.downloadUserInfo { userName in
            guard let userName else {
                completion(nil)
                return
            }
            completion(userName)
        }
    }
}

