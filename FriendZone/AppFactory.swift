//
//  AppFactory.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit

class AppFactory {
    
    private let checkService: FirebaseServiceProtocol
    
    init(checkService: FirebaseServiceProtocol) {
        self.checkService = checkService
    }
    func makeModule(ofType moduleType: Module.ModuleType) -> Module {
        switch moduleType {
        case .login:
            let viewModel = LoginViewModel(checkService: checkService)
            let view = UINavigationController(rootViewController: LoginViewController(viewModel: viewModel))
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
        case .main:
            let viewModel = MainViewModel()
            let view = UINavigationController(rootViewController: MainViewController())
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
        case .profile:
            let viewModel = ProfileViewModel(checkService: checkService)
            let view = UINavigationController(rootViewController: ProfileViewController(viewModel: viewModel))
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
        case .like:
            let viewModel = LikeViewModel()
            let view = UINavigationController(rootViewController: LikeViewController())
            return Module(moduleType: moduleType, viewModel: viewModel, view: view)
       
        }
    }
}

