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
    public var image: UIImage?
    public var likes: Int
    public var postID: String
}
var posts = [Post]()

struct PostAnswer {
    let userName: String
    let image: String
    let likes: Int
    let postText: String
    let postID: String
}
