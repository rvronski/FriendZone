//
//  ProfileEditViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 28.05.2023.
//

import UIKit

class ProfileEditViewController: UIViewController {
    
    private let viewModel: ProfileViewModelProtocol
    
    private let avatarDataImage: Data
    
    init(viewModel: ProfileViewModelProtocol, avatarDataImage: Data) {
        self.viewModel = viewModel
        self.avatarDataImage = avatarDataImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var avatarImage = CustomImageView()
    
    private lazy var changeFotoButton = CustomButton(buttonText: "Поменять фотографию", textColor: .buttonColor, background: nil, fontSize: 13, fontWeight: .light)
    
    private lazy var nameTF = RegTextField(placeholderText: "", typeKeyBoard: .default, isSecureText: false)
    
    private lazy var lastNameTF = RegTextField(placeholderText: "Фамилия", typeKeyBoard: .default, isSecureText: false)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        gestureAvatar()
        setupNavigationBar()
        changeFotoButton.tapButton = { [weak self] in
            self?.tapAvatar()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userName = UserDefaults.standard.string(forKey: "UserName") else {return}
        self.nameTF.text = userName
        guard let lastName = UserDefaults.standard.string(forKey: "LastName") else {return}
        self.lastNameTF.text = lastName
        if currentReachabilityStatus == .notReachable {
            self.alertOk(title: "Проверьте интернет соединение", message: nil)
            return
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.height/2
        self.nameTF.layer.cornerRadius = 10
        self.lastNameTF.layer.cornerRadius = 10
        
    }
    
    private func setupNavigationBar() {
        let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveEdit))
        rightButton.tintColor = .buttonColor
        navigationItem.rightBarButtonItem = rightButton
    }
    
    
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.avatarImage)
        self.view.addSubview(self.changeFotoButton)
        self.view.addSubview(self.nameTF)
        self.view.addSubview(self.lastNameTF)
        self.avatarImage.image = UIImage(data: self.avatarDataImage)
       
        NSLayoutConstraint.activate([
        
            self.avatarImage.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            self.avatarImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.avatarImage.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3),
            self.avatarImage.heightAnchor.constraint(equalTo: self.avatarImage.widthAnchor),
            
            self.changeFotoButton.topAnchor.constraint(equalTo: self.avatarImage.bottomAnchor, constant: 10),
            self.changeFotoButton.centerXAnchor.constraint(equalTo: self.avatarImage.centerXAnchor),
            
            self.nameTF.topAnchor.constraint(equalTo: self.changeFotoButton.bottomAnchor,constant: 30),
            self.nameTF.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            self.nameTF.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            self.nameTF.heightAnchor.constraint(equalToConstant: 50),
            
            self.lastNameTF.topAnchor.constraint(equalTo: self.nameTF.bottomAnchor,constant: 16),
            self.lastNameTF.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            self.lastNameTF.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            self.lastNameTF.heightAnchor.constraint(equalToConstant: 50),
            
    
        ])
        
    }
    
    private func gestureAvatar() {
        let gestureAvatar = UITapGestureRecognizer(target: self, action: #selector(tapAvatar))
        self.avatarImage.addGestureRecognizer(gestureAvatar)
    }
    @objc func tapAvatar() {
        viewModel.openGallery(delegate: self)
    }
    
    @objc private func saveEdit() {
        if currentReachabilityStatus == .notReachable {
            self.alertOk(title: "Проверьте интернет соединение", message: nil)
            return
        }
        let image = self.avatarImage.image
        guard let imageData = image?.jpegData(compressionQuality: 0.4) else { return }
        guard let userID = UserDefaults.standard.string(forKey: "UserID") else { return }
        
        let name = nameTF.text
        let lastName = lastNameTF.text
        UserDefaults.standard.set(name, forKey: "UserName")
        UserDefaults.standard.set(lastName, forKey: "LastName")
        self.viewModel.uploadFoto(currentUserId: userID, photo: imageData)
        self.viewModel.changeName(userName: name ?? "", lastName: lastName ?? "")
        self.viewModel.pop()
    }
}
extension ProfileEditViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        self.avatarImage.image = image
        self.viewModel.dismiss()
    }
}
