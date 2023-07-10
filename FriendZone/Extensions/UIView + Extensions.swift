//
//  UIView + Extensions.swift
//  FriendZone
//
//  Created by Roman Vronsky on 10/07/23.
//

import UIKit

extension UIView {
    
    /// Draw dotted border line
    func addShapeLayer(widthLine: NSNumber, widthSpace: NSNumber, shapeColor: UIColor?, radius: Int){
        removeShapeLayer()
        let layer = CAShapeLayer()
        
        if radius > 0 {
            layer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        } else {
            layer.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0, height: 0)).cgPath
        }
        layer.name = "shapeLayer"
        layer.strokeColor = shapeColor?.cgColor
        layer.fillColor = nil
        layer.lineDashPattern = [widthLine, widthSpace]
        layer.borderWidth = 1
        self.layer.addSublayer(layer)
    }
    /// Draw dotted line
    func drawDottedLine(widthLine: NSNumber, widthSpace: NSNumber) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.systemGray2.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [widthLine, widthSpace]

        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: self.bounds.minX, y: self.bounds.midY), CGPoint(x: self.bounds.maxX, y: self.bounds.midY)])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    func removeShapeLayer(){
        if let sublayer = self.layer.sublayers {
            for layer in sublayer {
                if layer.name == "shapeLayer" {
                     layer.removeFromSuperlayer()
                }
            }
        }
    }
}
