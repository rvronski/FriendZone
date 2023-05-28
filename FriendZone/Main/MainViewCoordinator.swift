//
//  MainCoordinator.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

class MainViewCoordinator: ModuleCoordinatable {
    
    enum Push {
        case user(String, ViewModelProtocol)
        case photo([Post],ViewModelProtocol)
        case post
    }
    
    var module: Module?
    private let factory: AppFactory
    private(set) var moduleType: Module.ModuleType
    
    private(set) var coordinators: [Coordinatable] = []
    init(factory:AppFactory, moduleType: Module.ModuleType){
        self.factory = factory
        self.moduleType = moduleType
    }
    
    func start() -> UIViewController {
        let module = factory.makeModule(ofType: .main)
        let viewController = module.view
        viewController.tabBarItem = moduleType.tabBarItem
        (module.viewModel as! MainViewModel).coordinator = self
        self.module = module
        return viewController
    }
    
    func presentPhoto(delegate: UIViewControllerTransitioningDelegate, indexPath: IndexPath) {
        let presentViewController = UserDetailPhotoViewController(indexPath: indexPath)
        let navController =  UINavigationController(rootViewController: presentViewController)
        navController.transitioningDelegate = delegate
        navController.modalPresentationStyle = .fullScreen
        (module!.view as? UINavigationController)?.present(navController, animated: true, completion: nil)
    }
    
    func pushViewController(_ userID: String?, _ postArray: [Post]?, _ viewModel: ViewModelProtocol?, _ pushTo: Push ) {
        switch pushTo {
        case let .user(userID, viewModel):
            let userVC = UserProfileViewController(userID: userID, viewModel: viewModel as! MainViewModelProtocol)
            (module!.view as? UINavigationController)?.pushViewController(userVC, animated: true)
        case let .photo(postArray, viewModel):
            let photoVC = UserPhotoViewController(viewModel: viewModel as! MainViewModelProtocol, userPosts: postArray)
            (module!.view as? UINavigationController)?.pushViewController(photoVC, animated: true)
        case .post:
            print("post")
        }
    }
}
