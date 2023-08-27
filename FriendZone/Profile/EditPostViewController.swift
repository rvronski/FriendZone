//
//  EditPostViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 30.05.2023.
//

import UIKit

class EditPostViewController: UIViewController {

    private let viewModel: ProfileViewModelProtocol
    private let post: Post
    
    init(viewModel: ProfileViewModelProtocol, post: Post) {
        self.viewModel = viewModel
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var postTextView = TextView(frame: .zero, textContainer: nil)
    
    private lazy var photoButton = ButtonWithSystemImage(background: nil, image: "photo", imageSize: 20, symbolScale: .medium, tintcolor: .black)
    private lazy var deleteButton = ButtonWithSystemImage(background: nil, image: "trash", imageSize: 20, symbolScale: .medium, tintcolor: .black)
    
    private lazy var publicationutton = CustomButton(buttonText: "Отредактировать", textColor: .buttonColor, background: nil, fontSize: 15, fontWeight: .bold)
    
    private lazy var menuView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.systemGray2.cgColor
        view.layer.borderWidth = 0.2
        return view
    }()
    
    let imageView = CustomImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGesture()
        photoButton.tapButton = { [weak self] in
            self?.viewModel.openGallery(delegate: self!)
        }
        publicationutton.tapButton = {[weak self] in
            if self?.currentReachabilityStatus == .notReachable {
                self?.alertOk(title: "Проверьте интернет соединение", message: nil)
                return
            }
            self?.publication()
        }
        deleteButton.tapButton = { [weak self] in
            self?.alertOkCancel(title: "Удалить пост?", message: nil, completionHandler: {
                let postID = self?.post.postID
                self?.viewModel.deletePost(postID: postID!, completion: { result in
                    if result == false {
                        self?.alertOk(title: "Ошибка", message: "Невозможно удалить пост")
                        return
                    } else {
                        posts.removeAll(where: {$0 == self?.post})
                        allPosts.removeAll(where: {$0 == self?.post})
                        self?.viewModel.pop()
                    }
                })
            })
        }
    }

    private func setupView() {
        self.view.backgroundColor = .white
        self.view.layer.cornerRadius = 50
        self.view.addSubview(postTextView)
        self.view.addSubview(menuView)
        self.view.addSubview(imageView)
        self.menuView.addSubview(photoButton)
        self.menuView.addSubview(publicationutton)
        self.menuView.addSubview(deleteButton)
        self.postTextView.text = post.description
        self.imageView.image = UIImage(data: post.image)
        
        NSLayoutConstraint.activate([
            
            self.menuView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.menuView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.menuView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.menuView.heightAnchor.constraint(equalToConstant: 40),
           
            self.photoButton.centerYAnchor.constraint(equalTo: self.menuView.centerYAnchor),
            self.photoButton.leftAnchor.constraint(equalTo: self.menuView.leftAnchor, constant: 20),
            
            self.deleteButton.centerYAnchor.constraint(equalTo: self.photoButton.centerYAnchor),
            self.deleteButton.leftAnchor.constraint(equalTo: self.photoButton.rightAnchor, constant: 16),
            
            self.publicationutton.centerYAnchor.constraint(equalTo: self.menuView.centerYAnchor),
            self.publicationutton.rightAnchor.constraint(equalTo: self.menuView.rightAnchor, constant: -20),
            
            self.postTextView.topAnchor.constraint(equalTo: self.menuView.bottomAnchor, constant: 16),
            self.postTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
            self.postTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
            self.postTextView.heightAnchor.constraint(equalTo: self.postTextView.widthAnchor, multiplier: 0.3),
            
            self.imageView.topAnchor.constraint(equalTo: self.postTextView.bottomAnchor),
            self.imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),
            
            
        ])
    }
    
    private func publication() {
        guard let image = imageView.image else { self.alertOk(title: "Добавьте фотографию", message: nil)
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        let text = postTextView.text ?? ""
        let userName = UserDefaults.standard.string(forKey: "UserName") ?? ""
        let lastName = UserDefaults.standard.string(forKey: "LastName") ?? ""
        let name = userName + " " + lastName
        guard let userID = UserDefaults.standard.string(forKey: "UserID") else { return }
        let postID = self.post.postID
        let isLike = self.post.isLike
        let newPost = Post(author: name, description: text, image: imageData, likesCount: 0, isLike: isLike, postID: postID, userID: userID)
        let index = posts.firstIndex(where: {$0.postID == self.post.postID})
        posts.remove(at: index!)
        posts.insert(newPost, at: index!)
        if !allPosts.isEmpty {
            let indexInAllPosts = allPosts.firstIndex(where: {$0.postID == self.post.postID})
            allPosts.remove(at: indexInAllPosts!)
            allPosts.insert(newPost, at: indexInAllPosts!)
        }
        viewModel.addposts(userName: name, image: imageData, likesCount: 0, postText: text, postID: postID)
        self.viewModel.pop()
    }
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
}
extension EditPostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.imageView.image = image
        self.viewModel.dismiss()
    }
}

