//
//  User.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 26.05.2023.
//

import Foundation

public struct User {
    public var userName: String
    public var userID: String
    public var avatarImage: String?
    public var email: String
}
var users = [User]() {
    didSet {
       print("user reload")
        }
    }


