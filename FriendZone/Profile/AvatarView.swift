//
//  AvatarView.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import UIKit

protocol AvatarViewDelegate: AnyObject {
    func changeLayout()
}
class AvatarView: UIView {
    lazy var avatarImageView: UIImageView = {
        let avatarImage = UIImageView()
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.backgroundColor = .orange
        avatarImage.contentMode = .scaleToFill
        avatarImage.layer.borderWidth = 3
        avatarImage.alpha = 1
        avatarImage.layer.borderColor = UIColor.white.cgColor
        avatarImage.image = UIImage(named: "IMG_1824")
        avatarImage.clipsToBounds = true
        avatarImage.isUserInteractionEnabled = true
        return avatarImage
    }()
    
   
    
    lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.isHidden = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage(systemName: "multiply.circle"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return closeButton
    }()
    @objc func closeView() {
        self.delegate?.changeLayout()
        
    }
    
    weak var delegate: AvatarViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupAvatarView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.height/2
    }
    
    func setupAvatarView()  {
        self.addSubview(closeButton)
        self.addSubview(avatarImageView)
        self.backgroundColor = .black
        NSLayoutConstraint.activate([
            
            self.avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            self.avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.avatarImageView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.2415),
            self.avatarImageView.heightAnchor.constraint(equalTo: self.avatarImageView.widthAnchor),
            
            self.closeButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.closeButton.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor,constant: -10),
            self.closeButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor)
            
        ])
    }
}

