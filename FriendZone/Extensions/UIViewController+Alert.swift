//
//  UIViewController+Alert.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 20.05.2023.
//

import UIKit


extension UIViewController {
    
    func alertOkCancel(title: String, message: String?, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    func alertOk(title: String, message: String?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ОК", style: .default)
        
        alertController.addAction(ok)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func alertDismiss(title: String, message: String?, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ОК", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(ok)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presenActionSheet(title1: String, title2: String, completionOne: @escaping () -> Void, completionTwo: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let oneAction = UIAlertAction(title: title1, style: .default) { _ in
            completionOne()
        }
        let twoAction = UIAlertAction(title: title2, style: .default) { _ in
            completionTwo()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(oneAction)
        alertController.addAction(twoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
        
    }
}

