//
//  UIColor+Extensions.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 20.05.2023.
//

import UIKit

extension UIColor {
    static var buttonColor: UIColor = #colorLiteral(red: 0.0608272329, green: 0.488943398, blue: 0.9880504012, alpha: 1)
    static func createColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? light : dark
        }
    }
}
