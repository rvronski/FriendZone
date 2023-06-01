//
//  CheckerService.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

protocol FirebaseServiceProtocol {
    func checkCredentials(email: String, password: String,  completion: @escaping ((Bool, String?) -> Void))
    func signUp(email: String, password: String, userName: String, completion: @escaping ((Bool, String?) -> Void))
    func upload(currentUserId: String, photo: Data, completion: @escaping (Result<URL, Error>) -> Void)
    func downloadUserInfo(userID: String ,completion: @escaping (NSDictionary?, [String]?) -> Void )
    func addposts(userName: String, image: Data, likesCount: Int, postText: String?, postID: String)
    func deletePost(postID: String, completion: @escaping (Bool?) -> Void)
    func plusLike(userID: String, postID: String, likesCount: Int)
    func minusLike(userID: String, postID: String, likesCount: Int)
    func downloadImage(imageURL: String, completion: @escaping (Data?) -> Void)
    func downloadAllUsers(completion: @escaping (NSDictionary?, [String]?) -> Void)
    func changeName(userName: String, lastName: String)
    
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
                UserDefaults.standard.set(true, forKey: "isFirstTime")
                UserDefaults.standard.set(result.user.uid, forKey: "UserID")
                let db = Firestore.firestore()
                db.collection("Users").addDocument(data: [
                    "firstname": userName,
                    "email": email,
                    "avatarURL": "",
                    "uid": result.user.uid ])
                completion(true, result.user.uid)
               
            }
        })
    }
    
    func upload(currentUserId: String, photo: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = Storage.storage().reference().child("avatars").child(currentUserId)
    
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        reference.putData(photo, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                completion(.failure(error!))
                print("Ошибка = \(String(describing: error))")
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
    
    
    func downloadImage(imageURL: String, completion: @escaping (Data?) -> Void) {
        let reference = Storage.storage().reference(forURL: imageURL)
        let megaByte = Int64(1 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { (data, error) in
            guard let imageData = data else {
                completion(nil)
                return }
            completion(imageData)
        }
    }
    
    func downloadUserInfo(userID: String ,completion: @escaping (NSDictionary?, [String]?) -> Void ) {
        
        var postStringIDs = [String]()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("Users").child(userID).observe(DataEventType.value, with: { snapshot in
            guard let value = snapshot.value, snapshot.exists() else {
                print("Error with getting data")
                return
            }
            
            for meterSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                for readingSnapshot in meterSnapshot.children.allObjects as! [DataSnapshot] {
                    postStringIDs.append(readingSnapshot.key)
                }
            }
            completion(value as? NSDictionary, postStringIDs)
        })
        
    }
    
    func downloadAllUsers(completion: @escaping (NSDictionary?, [String]?) -> Void) {
        var usersStringIDs = [String]()
        var ref: DatabaseReference!
        ref = Database.database().reference().child("Users")
        ref.observe(.value) { snapshot in
            let value = snapshot.value as? NSDictionary
            for meterSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                    usersStringIDs.append(meterSnapshot.key)
                }
            completion(value, usersStringIDs)
        }
    }
    
    func addposts(userName: String, image: Data, likesCount: Int, postText: String?, postID: String) {
        guard let uid = UserDefaults.standard.string(forKey: "UserID") else { return }
        let reference = Storage.storage().reference().child("\(uid)postImages").child(postID)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        reference.putData(image, metadata: metadata) { (metadata, error) in
            guard let _ = metadata else {
                
                return
            }
            reference.downloadURL { (url, error) in
                guard let url = url else {
                    return
                }
                var ref: DatabaseReference!
                ref = Database.database().reference()
                ref.child("Users").child(uid).child("posts").child(postID).setValue([
                    "postID": postID,
                    "username":  userName,
                    "postText": postText ?? "",
                    "image":  url.absoluteString,
                    "likesCount": likesCount,
                    "isLike": false
                ])
            }
        }
    }
    
    func deletePost(postID: String, completion: @escaping (Bool?) -> Void) {
        guard let uid = UserDefaults.standard.string(forKey: "UserID") else { return }
        let reference = Storage.storage().reference().child("\(uid)postImages/\(postID)")
        reference.delete { error in
            if error != nil {
              completion(false)
          } else {
              print("delete succsess")
              var ref: DatabaseReference!
              ref = Database.database().reference()
              ref.child("Users").child(uid).child("posts").child(postID).removeValue()
            completion(true)
          }
        }
    }
    
    func plusLike(userID: String, postID: String, likesCount: Int) {
        let newLikesCount = likesCount + 1
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("Users/\(userID)/posts/\(postID)/likesCount").setValue(newLikesCount)
        ref.child("Users/\(userID)/posts/\(postID)/isLike").setValue(true)
    }
    
    func minusLike(userID: String, postID: String, likesCount: Int) {
        let newLikesCount = likesCount - 1
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("Users/\(userID)/posts/\(postID)/likesCount").setValue(newLikesCount)
        ref.child("Users/\(userID)/posts/\(postID)/isLike").setValue(false)
    }
    
    func changeName(userName: String, lastName: String) {
        guard let uid = UserDefaults.standard.string(forKey: "UserID") else { return }
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("Users/\(uid)/userName").setValue(userName)
        ref.child("Users/\(uid)/lastName").setValue(lastName)
    }
}
