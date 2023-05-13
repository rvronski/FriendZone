//
//  ProfileCoordinator.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit

class ProfileCoordinator: ModuleCoordinatable {
    let moduleType: Module.ModuleType

    private let factory: AppFactory

    private(set) var coordinators: [Coordinatable] = []
    private(set) var module: Module?
    private var navigationController: UINavigationController
    init(moduleType: Module.ModuleType, factory: AppFactory, navigationController: UINavigationController) {
        self.moduleType = moduleType
        self.factory = factory
        self.navigationController = navigationController
    }
    
    func start() -> UIViewController {
        let module = factory.makeModule(ofType: .profile)
        let viewController = module.view
        viewController.tabBarItem = moduleType.tabBarItem
        (module.viewModel as! ProfileViewModel).coordinator = self
        self.module = module
        return viewController
    }
    func photoCellDidTap() {
        let vc = PhotosViewController()
        (module?.view as? UINavigationController)?.pushViewController(vc, animated: true)
    }
    
}
