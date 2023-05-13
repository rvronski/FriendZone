//
//  Module.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 13.05.2023.
//

import UIKit


protocol ViewModelProtocol: AnyObject {}

struct Module {
    enum ModuleType {
        case login
        case main
        case profile
        case like
        
    }
    
    let moduleType: ModuleType
    let viewModel: ViewModelProtocol
    let view: UIViewController
}

extension Module.ModuleType {
    var tabBarItem: UITabBarItem {
        switch self {
        case .login:
            fallthrough
        case .main:
            return UITabBarItem(title: "Главная", image: UIImage(systemName: "house"), tag: 0)
        case .profile:
            return UITabBarItem(title: "Профиль", image: UIImage(systemName: "person"), tag: 1)
        case .like:
            return UITabBarItem(title: "Нравится", image: UIImage(systemName: "heart.fill"), tag: 2)
       
        }
    }
}
