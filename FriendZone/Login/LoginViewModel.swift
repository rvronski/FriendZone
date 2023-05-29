//
//  LoginViewModel.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import Foundation

protocol LoginViewModelProtocol: ViewModelProtocol {
    func viewInputDidChange(viewInput: LoginViewModel.ViewInput)
    func authorization(email: String, password: String, completion: @escaping () -> Void)
    func registration(email: String, password: String, userName: String, completion: @escaping () -> Void)
}

class LoginViewModel: LoginViewModelProtocol {
    enum ViewInput {
        case tapSignUp
        case tapLogin
        case tapFaceID
    }
    
    private let firebaseService: FirebaseServiceProtocol

    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
   weak var coordinator: AppCoordinator?
    
    func authorization(email: String, password: String, completion: @escaping () -> Void) {
        firebaseService.checkCredentials(email: email, password: password) { [weak self] result, uid  in
            guard let uid else { return }
            if result {
                self?.viewInputDidChange(viewInput: .tapLogin)
                UserDefaults.standard.set(uid, forKey: "UserID")
            } else {
                completion()
            }
        }
    }
    func registration(email: String, password: String, userName: String, completion: @escaping () -> Void) {
        firebaseService.signUp(email: email, password: password, userName: userName) { [weak self] result, uid  in
            guard let uid else {return}
            if result {
                self?.viewInputDidChange(viewInput: .tapLogin)
                UserDefaults.standard.set(uid, forKey: "UserID")
            } else {
                completion()
            }
        }
    }
    
    func viewInputDidChange(viewInput: ViewInput) {
        switch viewInput {
        case .tapSignUp:
            coordinator?.goTo(viewModel: self, pushTo: .registration(self))
        case .tapLogin:
            coordinator?.goTo(viewModel: self, pushTo: .tabBar)
        case .tapFaceID:
            break
        }
    }
}
