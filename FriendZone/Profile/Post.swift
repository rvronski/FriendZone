//
//  Post.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

public struct Post {
    public var author: String
    public var description: String?
    public var image: Data
    public var likesCount: Int
    public var isLike: Bool
    public var postID: String
}
var posts = [Post]() {
    didSet {
        DispatchQueue.main.async {
            ProfileView().reload()
            CustomHeaderView().reload()
        }
    }
}

