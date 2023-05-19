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
extension Post {
    static func getPost(_ postAnswer: [PostAnswer], _ dataImage: [Data]) -> [Post] {
        var postArray = [Post]()
        for post in postAnswer {
            for image in dataImage {
                let author = post.userName
                let description = post.postText
                let likes = post.likes
                let postID = post.postID
                let image = UIImage(data: image)
                let item = Post(author: author, description: description, image: image, likes: likes, postID: postID)
                postArray.append(item)
            }
        }
            return postArray
    }
}
