//
//  TabBarController.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 20.05.2023.
//

import UIKit

final class AppTabBarController: UITabBarController {
    
    private var buttonIsTapped = false
    
    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        addMiddleButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var index = Int()
    private var optionButton = [UIButton]()
    
    private lazy var middleButton: UIButton = {
        let button = UIButton()
        let image = UIImage.SymbolConfiguration(pointSize: 15, weight: .heavy, scale: .large)
        button.setImage(UIImage(systemName: "plus", withConfiguration: image), for: .normal)
        button.imageView?.tintColor = .white
        button.backgroundColor = .buttonColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    private func addMiddleButton() {
        
        DispatchQueue.main.async {
            if let items = self.tabBar.items {
                items[1].isEnabled = false
            }
        }
        self.tabBar.addSubview(self.middleButton)
        let size = CGFloat(30)
        
        
        NSLayoutConstraint.activate([
            self.middleButton.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor),
            self.middleButton.topAnchor.constraint(equalTo: self.tabBar.topAnchor, constant: 8),
            self.middleButton.heightAnchor.constraint(equalToConstant: size),
            self.middleButton.widthAnchor.constraint(equalToConstant: size)
        ])
        
        self.middleButton.layer.cornerRadius = size / 2
        self.middleButton.addTarget(self, action: #selector(middleButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func middleButtonDidTap() {
        if buttonIsTapped == false {
            UIView.animate(withDuration: 0.3) {
                self.middleButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                self.middleButton.backgroundColor = .white
                self.middleButton.imageView?.tintColor = .buttonColor
                self.middleButton.layer.borderWidth = 2
                self.middleButton.layer.borderColor = UIColor.buttonColor.cgColor
                self.buttonIsTapped = true
                self.setUpButton()
                
            }
            
        } else {
            UIView.animate(withDuration: 0.15) { [weak self] in
                self?.middleButton.transform = CGAffineTransform(rotationAngle: 0)
                self?.middleButton.backgroundColor = .buttonColor
                self?.middleButton.layer.borderWidth = 0
                self?.middleButton.imageView?.tintColor = .white
                self?.buttonIsTapped = false
                self?.removeButton()
            }
        }
    }
    private func createButton(size: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .buttonColor
        button.translatesAutoresizingMaskIntoConstraints = false
        //        button.bottomAnchor.constraint(equalTo: self.middleButton.topAnchor, constant: 16).isActive = true
        button.widthAnchor.constraint(equalToConstant: 180).isActive = true
        button.layer.cornerRadius = 15
        
        if buttonIsTapped == true {
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut) {
                button.imageView?.tintColor = .clear
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                button.imageView?.tintColor = .white
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        return button
    }
    
    private func ctraeteBackground() -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.titleLabel?.text = ""
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        return button
        
    }
    
    @objc func backgroundPressed(sender: UIButton) {
        if buttonIsTapped == true {
            middleButton.sendActions(for: .touchUpInside)
        } else {
            sender.isUserInteractionEnabled = false
            sender.removeFromSuperview() }
        
    }
    
    func setUpButton() {
        
        let background = ctraeteBackground()
        background.addTarget(self, action: #selector(backgroundPressed(sender:)), for: .touchUpInside)
        background.addTarget(self, action: #selector(backgroundPressed(sender:)), for: .touchDragInside)
        self.optionButton.append(background)
        tabBar.bringSubviewToFront(middleButton)
        
        let button = createButton(size: 200)
        self.optionButton.append(button)
        self.view.addSubview(button)
        button.imageView?.isHidden = false
        
        button.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: self.tabBar.topAnchor, constant: -16).isActive = true
        
        button.setTitle("Добавить пост", for: .normal)
        self.view.bringSubviewToFront(button)
        button.addTarget(self, action: #selector(optionHandler(sender:)), for: .touchUpInside)
        
    }
    
    
    @objc func optionHandler(sender: UIButton) {
        self.selectedIndex = 0
        ProfileViewModel.state = .addPost
        self.middleButtonDidTap()
        removeButton()
    }
    
    func removeButton() {
        for button in self.optionButton {
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
                button.transform = CGAffineTransform(scaleX: 1.15, y: 1.1)
            }, completion: { _ in
                button.alpha = 0
                if button.alpha == 0 {
                    button.removeFromSuperview()
                }
            })
        }
    }
}

