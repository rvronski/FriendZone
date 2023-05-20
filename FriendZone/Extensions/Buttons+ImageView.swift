//
//  Buttons+ImageView.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 20.05.2023.
//

import UIKit

class CustomButton: UIButton {
    var tapButton: ( () -> Void )?
    init(buttonText: String, textColor: UIColor, background: UIColor?, fontSize: CGFloat, fontWeight: UIFont.Weight) {
        super.init(frame: .zero )
        setTitle(buttonText, for: .normal)
        backgroundColor = background ?? .clear
        layer.cornerRadius = 20
        setTitleColor(textColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
       
    }
    
    @objc private func didTapButton() {
        tapButton?()
    }
}

class ButtonWithSystemImage: UIButton {
    var tapButton: ( () -> Void )?
    init(background: UIColor?, image: String, imageSize: CGFloat, symbolScale: UIImage.SymbolScale, tintcolor: UIColor) {
        super.init(frame: .zero)
        backgroundColor = background ?? .clear
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: imageSize, weight: .bold, scale: symbolScale)
        let largeBoldDoc = UIImage(systemName: image, withConfiguration: largeConfig)
        setImage(largeBoldDoc, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
       
    }
    
    @objc private func didTapButton() {
        tapButton?()
    }
}

class CustomImageView: UIImageView {
    init(imageName: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        image = UIImage(named: imageName)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class CustomSystemImageView: UIImageView {
    init(systemName: String, color: UIColor) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        image = UIImage(systemName: systemName)
        tintColor = color
        
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
