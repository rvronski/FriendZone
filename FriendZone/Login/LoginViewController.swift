//
//  ViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit
import Firebase
import LocalAuthentication


class LoginViewController: UIViewController {
   
    enum LoginErrors: Error {
        case noLogin
        case userNotFound
        
    }
    
    private let localAuth = LocalAuthorizationService()
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
    private lazy var faceIDButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(faceIDAuth), for: .touchUpInside)
        return button
    }()
    
    private lazy var passwordTextField = PasswordTF()
    private lazy var loginTextField = LoginTF()
   
    private lazy var signUpButton: UIButton = {
        let signUpButton = UIButton()
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.setTitle("SignUp", for: .normal)
        signUpButton.setTitleColor(.systemBlue, for: .normal)
        signUpButton.addTarget(self, action: #selector(didPushSignUpButton), for: .touchUpInside)
        return signUpButton
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .darkGray
//        activityIndicator.isHidden = true
        return activityIndicator
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.clipsToBounds = true
        return stackView
    }()
    
    private lazy var button = CustomButton(buttonText: "Log in", textColor: .white, background: .buttonColor, fontSize: 15, fontWeight: .bold)

    private lazy var logoImage: UIImageView = {
        let logoImage = UIImageView()
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        logoImage.backgroundColor = .clear
        logoImage.image = UIImage(named: "navigationLogo")
        logoImage.clipsToBounds = true
        return logoImage
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupGesture()
        self.tabBarController?.tabBar.isHidden = true
        button.tapButton = { [weak self] in
            self?.didTapButton()
        }
        UserDefaults.standard.set(nil, forKey: "imageURL")
        UserDefaults.standard.set(nil, forKey: "UserID")
    }
    private func setupView() {
        self.view.addSubview(scrollView)
        self.view.backgroundColor = .createColor(light: .white, dark: .darkGray)
        self.scrollView.addSubview(self.stackView)
        self.scrollView.addSubview(self.signUpButton)
        self.stackView.addArrangedSubview(loginTextField)
        self.stackView.addArrangedSubview(activityIndicator)
        self.stackView.addArrangedSubview(passwordTextField)
        self.scrollView.addSubview(self.button)
        self.scrollView.addSubview(self.logoImage)
        self.scrollView.addSubview(self.faceIDButton)
        self.passwordTextField.bringSubviewToFront(activityIndicator)
       
        loginTextField.text = "rv@gmail.com"
        passwordTextField.text = "qwerty"
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.logoImage.centerYAnchor.constraint(lessThanOrEqualTo: self.scrollView.centerYAnchor, constant: -220),
            self.logoImage.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor),
            self.logoImage.widthAnchor.constraint(equalTo: self.view.widthAnchor,multiplier: 0.3),
            self.logoImage.heightAnchor.constraint(equalTo: self.logoImage.widthAnchor),
            
            self.stackView.topAnchor.constraint(lessThanOrEqualTo: self.logoImage.bottomAnchor, constant: 120),
            self.stackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
            self.stackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
            self.stackView.heightAnchor.constraint(equalToConstant: 100),
            
            self.button.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 16),
            self.button.leftAnchor.constraint(equalTo: self.stackView.leftAnchor),
            self.button.rightAnchor.constraint(equalTo: self.stackView.rightAnchor),
            self.button.heightAnchor.constraint(equalToConstant: 50),
            
            self.signUpButton.topAnchor.constraint(equalTo: self.button.bottomAnchor, constant: 16),
            self.signUpButton.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor),
            self.signUpButton.widthAnchor.constraint(equalToConstant: 100),
            self.signUpButton.heightAnchor.constraint(equalToConstant: 20),
            
            self.activityIndicator.centerYAnchor.constraint(equalTo: self.passwordTextField.centerYAnchor),
            self.activityIndicator.centerXAnchor.constraint(equalTo: self.passwordTextField.centerXAnchor),
            
            self.faceIDButton.topAnchor.constraint(equalTo: self.signUpButton.bottomAnchor,constant: 16),
            self.faceIDButton.centerXAnchor.constraint(equalTo: self.signUpButton.centerXAnchor),
           
//
        ])
    }
 
//    func showRegistrationVC() {
//        let regVC = RegisterViewController(viewModel: LoginViewModel())
//        self.window?.rootViewController?.present(regVC, animated: true)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localAuth.isFaceIdSupported()
        let config = UIImage.SymbolConfiguration(textStyle: .largeTitle)
        switch localAuth.biometricType {
        case 0:
            self.faceIDButton.isHidden = true
            self.faceIDButton.isEnabled = true
        case 1:
            let image = UIImage(systemName: "touchid", withConfiguration: config)
            self.faceIDButton.setImage(image, for: .normal)
        case 2:
            let image = UIImage(systemName: "faceid", withConfiguration: config)
            self.faceIDButton.setImage(image, for: .normal)
        default:
            self.faceIDButton.isHidden = true
            self.faceIDButton.isEnabled = true
        }
        
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
        self.loginTextField.becomeFirstResponder()
    }
    
    
    @objc func didTapButton()  {
        guard let email = loginTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.alertOk(title: "Заполните все поля", message: nil)
            return
        }
        guard email.isValidEmail else {
            self.alertOk(title: "Неверный формат email", message: "Проверьте email адрес")
            return
        }
        
        viewModel.authorization(email: email, password: password) { [weak self] in
            DispatchQueue.main.async {
                self?.alertOk(title: "Ошибка авторизации", message: "Пользователь не найден")
            }
        }
        
    }
    
    
    
    @objc func didShowKeyboard(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            let loginButtonBottomPointY = self.button.frame.origin.y + self.button.frame.height
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
    
    @objc private func faceIDAuth() {
       let authLocal = LocalAuthorizationService()
        authLocal.authorizeIfPossible { success, error  in
            if let error = error {
                let errorCode = error._code
                if [LAError.biometryLockout.rawValue,
                    LAError.biometryNotEnrolled.rawValue].contains(where: { $0 == errorCode }) {
                    DispatchQueue.main.async {
                        self.alertDismiss(title: "Невозможно пройти аутентификацию", message: "Перейти в настройки приватности?") {
                            self.showDeviceSettings()
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertOk(title: "Не возможно пройти аутентификацию", message: "Проверьте настройки приватности")
                    }
                }
            }
            DispatchQueue.main.async {
                if let success = success {
                    if success {
                        self.viewModel.viewInputDidChange(viewInput: .tapLogin)
                    } else {
                        self.alertOk(title: "Не возможно пройти аутентификацию", message: "Проверьте настройки приватности")
                    }
                }
            }
        }
    }
    
    @objc private func didPushSignUpButton() {
        viewModel.viewInputDidChange(viewInput: .tapSignUp)
    }
    
    func showDeviceSettings() {
        guard let settingURL = URL(string: "App-Prefs:") else { return }
        if UIApplication.shared.canOpenURL(settingURL){
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(settingURL)
            }
        }
    }
}
