//
//  AppFactory.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit

class AppFactory {
    
    private let firebaseService: FirebaseServiceProtocol
    
    init(firebaseService: FirebaseServiceProtocol) {
        self.firebaseService = firebaseService
    }
    func makeModule(ofType moduleType: Module.ModuleType) -> Module {
        switch moduleType {
        case .login:
            let viewModel = LoginViewModel(firebaseService: firebaseService)
            let view = UINavigationController(rootViewController: LoginViewController(viewModel: viewModel))
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
        case .main:
            let viewModel = MainViewModel(firebaseService: firebaseService)
            let view = UINavigationController(rootViewController: MainViewController(viewModel: viewModel))
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
        case .profile:
            let viewModel = ProfileViewModel(firebaseService: firebaseService)
            let view = UINavigationController(rootViewController: ProfileViewController(viewModel: viewModel))
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
        case .addPost:
            let viewModel = AddPostViewModel()
            let view = UINavigationController(rootViewController: AddPostViewController())
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
       
        }
    }
}

