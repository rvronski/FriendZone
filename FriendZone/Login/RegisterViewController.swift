//
//  RegisterViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 20.05.2023.
//

import UIKit

import FirebaseDatabase


class RegisterViewController: UIViewController {
    
    private let viewModel: LoginViewModelProtocol
    
    init(viewModel: LoginViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
private lazy var logoImage = CustomImageView()
    
    private lazy var registerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Регистрация"
        label.font = UIFont(name: "sysemFont", size: 22)
        return label
    }()
    
    private lazy var userNameTextField: UITextField = {
        let userNameTextField = UITextField()
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        userNameTextField.placeholder = "Ваше имя"
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        userNameTextField.leftView = paddingView
        userNameTextField.leftViewMode = .always
//        userNameTextField.becomeFirstResponder()
        return userNameTextField
    }()
    
    private lazy var emailTextField: UITextField = {
        let emailTextField = UITextField()
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Введите email"
        emailTextField.keyboardType = .emailAddress
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        emailTextField.leftView = paddingView
        emailTextField.leftViewMode = .always
        return emailTextField
    }()
    
    private lazy var passwordTextField = ShowHideTextField() //UITextField = {
//        let passwordTextField = UITextField()
//        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
//        passwordTextField.placeholder = "Придумайте пароль"
//        passwordTextField.isSecureTextEntry = true
//        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
//        passwordTextField.leftView = paddingView
//        passwordTextField.leftViewMode = .always
//        //        passwordTextField.textInputMode =
//        //        passwordTextField.becomeFirstResponder()
//        return passwordTextField
//    }()
    
    private lazy var registrationButton = CustomButton(buttonText: "Зарегистрироваться", textColor: .white, background: .buttonColor, fontSize: 15, fontWeight: .bold)
    
    private lazy var OutButton: UIButton = {
        let OutButton = UIButton()
        OutButton.translatesAutoresizingMaskIntoConstraints = false
        OutButton.setTitle("Выход", for: .normal)
        OutButton.setTitleColor(.systemBlue, for: .normal)
        OutButton.addTarget(self, action: #selector(didPushOutButton), for: .touchUpInside)
        return OutButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupGesture()
        registrationButton.tapButton = { [weak self] in
            self?.didTapRegButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didShowKeyboard(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didHideKeyboard(_:)),
                                               name: UIResponder.keyboardDidHideNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.userNameTextField.becomeFirstResponder()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.registerLabel)
        self.scrollView.addSubview(self.logoImage)
        self.scrollView.addSubview(self.emailTextField)
        self.scrollView.addSubview(self.passwordTextField)
        self.scrollView.addSubview(self.registrationButton)
        self.scrollView.addSubview(self.userNameTextField)
        self.scrollView.addSubview(self.OutButton)
        self.logoImage.image = UIImage(named: "navigationLogo")
        self.passwordTextField.placeholder = "Придумайте пароль"
        
        NSLayoutConstraint.activate([
       
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
           
            
            self.registerLabel.heightAnchor.constraint(equalToConstant: 20),
            self.registerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.registerLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            self.logoImage.topAnchor.constraint(equalTo: self.registerLabel.bottomAnchor, constant: 20),
            self.logoImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.logoImage.widthAnchor.constraint(equalTo: self.view.widthAnchor,multiplier: 0.3),
            self.logoImage.heightAnchor.constraint(equalTo: self.logoImage.widthAnchor),
            
            self.userNameTextField.heightAnchor.constraint(equalToConstant: 50),
            self.userNameTextField.topAnchor.constraint(equalTo: self.logoImage.bottomAnchor, constant: 40),
            self.userNameTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            self.userNameTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            
            self.emailTextField.heightAnchor.constraint(equalToConstant: 50),
            self.emailTextField.topAnchor.constraint(equalTo: self.userNameTextField.bottomAnchor, constant: 16),
            self.emailTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            self.emailTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            
            self.passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            self.passwordTextField.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 16),
            self.passwordTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            self.passwordTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            
            self.registrationButton.heightAnchor.constraint(equalToConstant: 40),
            self.registrationButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 30),
            self.registrationButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            self.registrationButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            
            self.OutButton.heightAnchor.constraint(equalToConstant: 20),
            self.OutButton.topAnchor.constraint(equalTo: self.registrationButton.bottomAnchor, constant: 16),
            self.OutButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
           
        ])
        
    }
    
    
    @objc private func didPushOutButton() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func didShowKeyboard(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let loginButtonBottomPointY = self.OutButton.frame.origin.y + self.OutButton.frame.height
            let keyboardOriginY = self.view.frame.height - keyboardHeight
            
            let offset = keyboardOriginY <= loginButtonBottomPointY
            ? loginButtonBottomPointY - keyboardOriginY + 16
            : 0
            
            self.scrollView.contentOffset = CGPoint(x: 0, y: offset)
        }
    }
    
    @objc private func didHideKeyboard(_ notification: Notification) {
        self.hideKeyboard()
    }
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
        self.scrollView.setContentOffset(.zero, animated: true)
    }
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func didTapRegButton() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let userName = userNameTextField.text, !userName.isEmpty
        else {
            self.alertOk(title: "Заполните все поля", message: nil)
            return
        }
        guard email.isValidEmail else {
            self.alertOk(title: "Неверный формат email", message: "Проверьте email адрес")
            return
        }
        viewModel.registration(email: email, password: password, userName: userName) { [weak self] in
            self?.alertOk(title: "Ошибка создания аккаунта", message: nil)
        }
    }
}

