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
var posts = [Post]() {
    didSet {
        DispatchQueue.main.async {
            ProfileView().reload()
            CustomHeaderView().reload()
        }
    }
}

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
        var count = 0
            for post in postAnswer {
                let author = post.userName
                let description = post.postText
                let likes = post.likes
                let postID = post.postID
                let image = UIImage(data: dataImage[count])
                let item = Post(author: author, description: description, image: image, likes: likes, postID: postID)
                postArray.append(item)
                count += 1
            }

           return postArray
    }
}
