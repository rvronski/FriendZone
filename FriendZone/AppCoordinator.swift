//
//  AppCoordinator.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit

final class AppCoordinator: Coordinatable {
    
    enum PushVC {
        case registration(ViewModelProtocol)
        case tabBar
    }
                        
    private(set) var coordinators: [Coordinatable] = []
    
    private let factory: AppFactory
    private(set) var module: Module?
    var navigationController: UINavigationController
    init(factory: AppFactory, navigationController: UINavigationController) {
        self.factory = factory
        self.navigationController = navigationController
    }
    func start() -> UIViewController {
        let module = factory.makeModule(ofType: .login)
        let viewController = module.view
        (module.viewModel as! LoginViewModel).coordinator = self
        self.module = module
        return viewController
    }
    
    func goTo(viewModel: ViewModelProtocol, pushTo: PushVC) {
        switch pushTo {
            
        case let .registration(viewModel):
            let viewControllerToPush = RegisterViewController(viewModel: viewModel as! LoginViewModelProtocol)
            (module!.view as? UINavigationController)?.pushViewController(viewControllerToPush, animated: true)
        case .tabBar:
            let profileCoordinator = ProfileCoordinator(moduleType: .profile, factory: factory, navigationController: navigationController)
            let addPostCoordinator = AddPostCoordinator(factory: factory, moduleType: .addPost)
            let mainViewCoordinator = MainViewCoordinator(moduleType: .main, factory: factory, navigationController: navigationController)
            let tabBarController = AppTabBarController(viewControllers:
                                                        [profileCoordinator.start(),
                                                         addPostCoordinator.start(),
                                                         mainViewCoordinator.start()
                                                         ])
            addCoordinator(coordinator: profileCoordinator)
            addCoordinator(coordinator: addPostCoordinator)
            addCoordinator(coordinator: mainViewCoordinator)
        
            (module!.view as? UINavigationController)?.pushViewController(tabBarController, animated: true)
        }
    }
    
    func addCoordinator(coordinator: Coordinatable) {
        guard coordinators.contains(where: { $0 === coordinator }) else {
            return
        }
        coordinators.append(coordinator)
    }

    func removeCoordinator(coordinator: Coordinatable) {
        coordinators = coordinators.filter { $0 === coordinator }
    }
    
}

