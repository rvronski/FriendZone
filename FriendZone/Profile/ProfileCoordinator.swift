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
        case photo
        case post
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
    func photoCellDidTap() {
        let vc = PhotosViewController()
        (module?.view as? UINavigationController)?.pushViewController(vc, animated: true)
    }
    
    func presentImagePicker(delegate: UIViewController) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate as? any UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.allowsEditing = true
        module?.view.present(imagePicker, animated: true)
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
        case .photo:
            let photoVC = PhotosViewController()
            (module!.view as? UINavigationController)?.pushViewController(photoVC, animated: true)
        case .post:
            print("post")
        }
    }
}
