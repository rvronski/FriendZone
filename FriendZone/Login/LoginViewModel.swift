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
    
    private let checkService: CheckerServiceProtocol

    init(checkService: CheckerServiceProtocol) {
        self.checkService = checkService
    }
    var coordinator: AppCoordinator?
    
    func authorization(email: String, password: String, completion: @escaping () -> Void) {
        checkService.checkCredentials(email: email, password: password) { [weak self] result in
            if result {
                self?.viewInputDidChange(viewInput: .tapLogin)
            } else {
                completion()
            }
        }
    }
    func registration(email: String, password: String, userName: String, completion: @escaping () -> Void) {
        checkService.signUp(email: email, password: password, userName: userName) { [weak self] result in
            if result {
                self?.viewInputDidChange(viewInput: .tapLogin)
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
