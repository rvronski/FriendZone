//
//  CheckerService.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

protocol FirebaseServiceProtocol {
    func checkCredentials(email: String, password: String,  completion: @escaping ((Bool, String?) -> Void))
    func signUp(email: String, password: String, userName: String, completion: @escaping ((Bool, String?) -> Void))
    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void)
    func downloadAvatar(avatarURL: String, completion: @escaping (Data?) -> Void)
    func downloadUserInfo(completion: @escaping (NSDictionary?, [String]?) -> Void )
    func addposts(userName: String, image: UIImage?, likes: Int, postText: String?)
    func downloadImagePost(imageURL: String, completion: @escaping (Data?) -> Void)
}

class FirebaseService: FirebaseServiceProtocol {
    
    func checkCredentials(email: String, password: String,  completion: @escaping ((Bool, String?) -> Void)) {
        Auth.auth().signIn(withEmail: email, password: password ) {  result, error in
            guard error == nil else {
                print("Need to registration")
                completion(false, nil)
                return
            }
            guard let result else { return }
            let uid = result.user.uid
            UserDefaults.standard.set(uid, forKey: "UserID")
            print("🍎 \(uid)")
            completion(true, uid)
        }
    }
    
    func signUp(email: String, password: String, userName: String, completion: @escaping ((Bool, String?) -> Void)) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                            password: password,
                                            completion: { result, error  in
            guard error == nil else {
                print("Account creation failed")
                print(error!)
                completion(false, nil)
                return
            }
            
            if let result = result {
                print("UID:", result.user.uid)
                let ref = Database.database().reference().child("Users")
                ref.child(result.user.uid).updateChildValues(["userName": userName,
                                                              "email": email,
                                                              "admin": false])
                let db = Firestore.firestore()
                db.collection("Users").addDocument(data: [
                    "firstname": userName,
                    "email": email,
                    "avatarURL": "",
                    "uid": result.user.uid ])
                UserDefaults.standard.set(result.user.uid, forKey: "UserID")
                completion(true, result.user.uid)
                //
                //                Auth.auth().currentUser?.sendEmailVerification { error in
                //                    if let error = error {
                //                        print("error sendEmailVerification", error)
                //                        completion(2)
                //                    } else {
                //                        completion(3)
                //                    }
                //                }
            }
        })
    }
    
    func upload(currentUserId: String, photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = Storage.storage().reference().child("avatars").child(currentUserId)
        
        guard let imageData = photo.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        reference.putData(imageData, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            reference.downloadURL { (url, error) in
                guard let url = url else {
                    completion(.failure(error!))
                    return
                }
                var ref: DatabaseReference!
                ref = Database.database().reference()
                ref.child("Users/\(currentUserId)/avatarImageURL").setValue(url.absoluteString)
                print("🍎 \(url)")
                completion(.success(url))
            }
        }
    }
    
    func downloadAvatar(avatarURL: String, completion: @escaping (Data?) -> Void) {
        let reference = Storage.storage().reference(forURL: avatarURL)
        let megaByte = Int64(1 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { (data, error) in
            guard let imageData = data else {
                completion(nil)
                return }
            completion(imageData)
        }
    }
    
    func downloadImagePost(imageURL: String, completion: @escaping (Data?) -> Void) {
        let reference = Storage.storage().reference(forURL: imageURL)
        let megaByte = Int64(1 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { (data, error) in
            guard let imageData = data else {
                completion(nil)
                return }
            completion(imageData)
        }
    }
    
    func downloadUserInfo(completion: @escaping (NSDictionary?, [String]?) -> Void ) {
        
        guard let uid = UserDefaults.standard.string(forKey: "UserID") else { return }
        var postStringIDs = [String]()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("Users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            
            let value = snapshot.value as? NSDictionary
            for meterSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                for readingSnapshot in meterSnapshot.children.allObjects as! [DataSnapshot] {
                    postStringIDs.append(readingSnapshot.key)
                }
            }
            completion(value, postStringIDs)
            
        }) { error in
            print(error.localizedDescription)
            completion(nil, nil)
        }
        
    }
    
    func addposts(userName: String, image: UIImage?, likes: Int, postText: String?) {
        guard let uid = UserDefaults.standard.string(forKey: "UserID") else { return }
        let postID = UUID().uuidString
        let reference = Storage.storage().reference().child("\(uid)postImages").child(postID)
        if let image {
            
            guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            reference.putData(imageData, metadata: metadata) { (metadata, error) in
                guard let _ = metadata else {
                    
                    return
                }
                reference.downloadURL { (url, error) in
                    guard let url = url else {
                        return
                    }
                    
                    var ref: DatabaseReference!
                    ref = Database.database().reference()
                    ref.child("Users").child(uid).child("posts").childByAutoId().setValue([
                        "postID": postID,
                        "username":  userName,
                        "image":  url.absoluteString,
                        "likes": likes,
                        "postText": postText ?? ""
                    ])
                }
            }
            
        } else {
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("Users").child(uid).child("posts").childByAutoId().setValue( [
                "postID": postID,
                "username":  userName,
                "image":  "",
                "likes": likes,
                "postText": postText ?? ""
            ])
        }
    }
}
