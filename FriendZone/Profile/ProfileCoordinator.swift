//
//  ProfileCoordinator.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit

class ProfileCoordinator: ModuleCoordinatable {
    
    enum Push {
        case publication(ViewModelProtocol)
        case photo(ViewModelProtocol)
        case editPost(ViewModelProtocol, Post)
        case edit(ViewModelProtocol, Data)
    }
    
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
    
    func presentImagePicker(delegate: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate as? any UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.allowsEditing = true
        module?.view.present(imagePicker, animated: true)
    }
    
    func presentPhoto(delegate: UIViewControllerTransitioningDelegate, indexPath: IndexPath) {
        let presentViewController = PhotosDetailViewController(indexPath: indexPath)
        let navController =  UINavigationController(rootViewController: presentViewController)
         navController.transitioningDelegate = delegate
         navController.modalPresentationStyle = .fullScreen
        (module!.view as? UINavigationController)?.present(navController, animated: true, completion: nil)
        
    }
    
    func presentAvatar(delegate: UIViewControllerTransitioningDelegate, data: Data) {
        let presentViewController = AvatarViewController(avatarData: data)
        let navController = UINavigationController(rootViewController: presentViewController)
        navController.transitioningDelegate = delegate
        navController.modalPresentationStyle = .fullScreen
       (module!.view as? UINavigationController)?.present(navController, animated: true, completion: nil)
    }
    
    func dismiss() {
        module?.view.dismiss(animated: true)
    }
    
    func pop() {
        (module?.view as? UINavigationController)?.popViewController(animated: true)
    }
    
    func pushViewController(_ viewModel: ViewModelProtocol?, _ pushTo: Push ) {
        switch pushTo {
        case let .publication(viewModel):
            let publicationVC = PostViewController(viewModel: viewModel as! ProfileViewModelProtocol)
            (module!.view as? UINavigationController)?.pushViewController(publicationVC, animated: true)
        case let .photo(viewModel):
            let photoVC = PhotosViewController(viewModel: viewModel as! ProfileViewModelProtocol)
            (module!.view as? UINavigationController)?.pushViewController(photoVC, animated: true)
        case let .editPost(viewModel, post):
            let editPostVC = EditPostViewController(viewModel: viewModel as! ProfileViewModelProtocol, post: post)
            (module!.view as? UINavigationController)?.pushViewController(editPostVC, animated: true)
        case let .edit(viewModel, data):
            let editVC = ProfileEditViewController(viewModel: viewModel as! ProfileViewModelProtocol, avatarDataImage: data)
            (module!.view as? UINavigationController)?.pushViewController(editVC, animated: true)
        }
    }
}
