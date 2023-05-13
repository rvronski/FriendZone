//
//  CheckerService.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import Foundation
import Firebase
import FirebaseDatabase


protocol CheckerServiceProtocol {
    func checkCredentials(email: String, password: String,  completion: @escaping ((Bool) -> Void))
    func signUp(email: String, password: String, userName: String, completion: @escaping ((Bool) -> Void))
}

class CheckerService: CheckerServiceProtocol {
    
    func checkCredentials(email: String, password: String,  completion: @escaping ((Bool) -> Void)) {
        Auth.auth().signIn(withEmail: email, password: password ) {  result, error in
            guard error == nil else {
                print("Need to registration")
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func signUp(email: String, password: String, userName: String, completion: @escaping ((Bool) -> Void)) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                            password: password,
                                            completion: { result, error  in
            guard error == nil else {
                print("Account creation failed")
                print(error!)
                completion(false)
                return
            }
            
            if let result = result {
                print("UID:", result.user.uid)
                let ref = Database.database().reference().child("Users")
                ref.child(result.user.uid).updateChildValues(["userName": userName,
                                                              "email": email,
                                                              "admin": false])
                completion(true)
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
}
