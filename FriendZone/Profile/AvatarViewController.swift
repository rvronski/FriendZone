//
//  AvatarViewController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 30.05.2023.
//

import UIKit

class AvatarViewController: UIViewController {
    
    let avatarData: Data
    
    init(avatarData: Data) {
        self.avatarData = avatarData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var avatarView = CustomImageView()
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        gestureCollectionView()
    }
    
    private func setupView()  {
        self.view.backgroundColor = .white.withAlphaComponent(0.4)
        self.view.addSubview(avatarView)
        avatarView.image = UIImage(data: avatarData)
        
        NSLayoutConstraint.activate([
            
            self.avatarView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.avatarView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.avatarView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.avatarView.heightAnchor.constraint(equalTo: self.avatarView.widthAnchor)
            
        ])
    }
    
    private func gestureCollectionView() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        self.avatarView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: self.avatarView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1,options: .curveEaseOut) {
                self.avatarView.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                
            }
        case .ended:
            if viewTranslation.y > -100 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1,options: .curveEaseOut) {
                    self.avatarView.transform = .identity
                }
            } else {
                self.view.backgroundColor = .white.withAlphaComponent(0)
                self.popVC()
            }
            
        default:
            break
        }
        
    }
    @objc private func popVC() {
        self.navigationController?.dismiss(animated: true)
    }
}
