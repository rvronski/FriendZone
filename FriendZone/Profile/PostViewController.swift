//
//  PostViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 16.05.2023.
//

import UIKit

protocol PostViewControllerDelegate: AnyObject {
    func presentImagePicker()
}

class PostViewController: UIViewController {
    
    private let viewModel: ProfileViewModelProtocol
    
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var delegate: PostViewControllerDelegate?
    
    private lazy var postTextView = TextView(frame: .zero)
    
    private lazy var photoButton = ButtonWithSystemImage(background: nil, image: "photo", imageSize: 20, symbolScale: .medium, tintcolor: .black)
    
    private lazy var publicationutton = CustomButton(buttonText: "Опубликовать", textColor: .buttonColor, background: nil, fontSize: 15, fontWeight: .bold)
    
    private lazy var menuView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.systemGray2.cgColor
        view.layer.borderWidth = 0.2
        return view
    }()
    
    let imageView = CustomImageViewForTextView(img: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGesture()
        photoButton.tapButton = { [weak self] in
            self?.viewModel.uploadFoto(delegate: self!)
        }
        publicationutton.tapButton = {[weak self] in
            self?.publication()
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
        
        NSLayoutConstraint.activate([
            
            self.menuView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 60),
            self.menuView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.menuView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.menuView.heightAnchor.constraint(equalToConstant: 40),
           
            self.photoButton.centerYAnchor.constraint(equalTo: self.menuView.centerYAnchor),
            self.photoButton.leftAnchor.constraint(equalTo: self.menuView.leftAnchor, constant: 20),
            
            self.publicationutton.centerYAnchor.constraint(equalTo: self.menuView.centerYAnchor),
            self.publicationutton.rightAnchor.constraint(equalTo: self.menuView.rightAnchor, constant: -20),
            
            self.postTextView.topAnchor.constraint(equalTo: self.menuView.bottomAnchor),
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
        let text = postTextView.text
        let image = imageView.image
        let userName = UserDefaults.standard.string(forKey: "userName")
        let post = Post(author: userName ?? "", description: text, image: image, likes: 0, views: 0)
        posts.append(post)
        viewModel.addposts(userName: userName ?? "", image: "image", likes: 0)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
}
extension PostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
//        self.profileView.avatarImage.image = image
//        self.viewModel.uploadFoto(currentUserId: userID!, photo: image)
       
        self.imageView.image = image
        self.viewModel.dismiss()
    }
}
