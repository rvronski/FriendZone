//
//  TextFields.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 20.05.2023.
//

import UIKit

class RegTextField: UITextField {
    init(placeholderText: String, typeKeyBoard: UIKeyboardType, isSecureText: Bool) {
        super.init(frame: .zero)
        placeholder = placeholderText
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .black
        layer.borderWidth = 0.2
        autocapitalizationType = .none
        textAlignment = .left
        keyboardType = typeKeyBoard
        isSecureTextEntry = isSecureText
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        leftView = paddingView
        leftViewMode = .always
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ShowHideTextField: UITextField {

    lazy var rightButton: UIButton = {
        let rightButton = UIButton(type: .custom)
        rightButton.tintColor = .systemGray2
        rightButton.setImage(UIImage(systemName: "eye.slash") , for: .normal)
        rightButton.addTarget(self, action: #selector(toggleShowHide), for: .touchUpInside)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
       return rightButton
    }()

    init() {
        super.init(frame: .zero)
        placeholder = "Password"
        translatesAutoresizingMaskIntoConstraints = false
        textColor = .black
        layer.cornerRadius = 15
        autocapitalizationType = .none
        textAlignment = .left
        keyboardType = .emailAddress
        isSecureTextEntry = true
        rightViewMode = .always
        rightView = rightButton
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        leftView = paddingView
        leftViewMode = .always
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        super.rightViewRect(forBounds: bounds)
        let rightPoint = self.frame.maxX
        let centerY = self.frame.height/6
        print(centerY)
        let origin = CGPoint(x: rightPoint-40, y: centerY)
        let size = CGSize(width: 30, height: 35)
        return CGRect(origin: origin, size: size)
    }
    
    @objc func toggleShowHide() {
        isSecureTextEntry = !isSecureTextEntry
        if let existingText = text, isSecureTextEntry {
            rightButton.setImage(UIImage(systemName: "eye.slash") , for: .normal)
            deleteBackward()
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
            if let existingSelectedTextRange = selectedTextRange {
                selectedTextRange = nil
                selectedTextRange = existingSelectedTextRange
            }
        } else {
            rightButton.setImage(UIImage(systemName: "eye") , for: .normal)
        }
    }
   
}

class TextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: CGRect.zero, textContainer: nil)
        translatesAutoresizingMaskIntoConstraints = false
        text = "Что у вас нового?"
        font = UIFont.systemFont(ofSize: 15, weight: .bold)
        textColor = .systemGray2
        delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        text = ""
        textColor = .black
    }
}
