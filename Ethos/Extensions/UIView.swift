//
//  UIView.swift
//  Ethos
//
//  Created by SoftGrid on 13/07/23.
//

import Foundation
import UIKit

extension UIView {
    
    
    func showBottomError(str : String) {
        let underLineView = UIView()
        let errorLabel = UIButton()
        
        underLineView.tag = 1500
        errorLabel.tag = 2000
        
        let frame = self.frame
        
        underLineView.frame = CGRect(x: Int(frame.minX), y: Int(frame.maxY), width: Int(frame.width), height: 1)
        underLineView.backgroundColor = .red
        errorLabel.setTitleColor(UIColor.red, for: .normal)
        errorLabel.setTitle( " \(str)", for: .normal)
        errorLabel.titleLabel?.font = EthosFont.Brother1816Regular(size: 10)
        errorLabel.titleLabel?.textAlignment = .left
        errorLabel.contentHorizontalAlignment = .leading
        errorLabel.setImage( UIImage(named: EthosConstants.required), for: .normal)
        errorLabel.frame = CGRect(x: Int(frame.minX), y:  Int(frame.maxY) + 5, width: Int(frame.width), height: 20)
        underLineView.frame = CGRect(x: Int(frame.minX), y: Int(frame.maxY), width: Int(frame.width), height: 1)
        errorLabel.frame = CGRect(x: Int(frame.minX), y:  Int(frame.maxY) + 5, width: Int(frame.width), height: 20)
        
        for view in self.superview?.subviews ?? [] {
            if view.frame == underLineView.frame && view.tag == 1500 {
                view.removeFromSuperview()
            }
            
            if view.frame == errorLabel.frame && view.tag == 2000 {
                view.removeFromSuperview()
            }
            
        }
        
        DispatchQueue.main.async {
            self.superview?.addSubview(errorLabel)
            self.superview?.addSubview(underLineView)
        }
        
        errorLabel.shake()
        
    }
    
    func removeBottomError() {
        for view in self.superview?.subviews ?? [] {
            if view.tag == 1500 || view.tag == 2000 {
                view.removeFromSuperview()
            }
        }
    }
    
    func setBorder(borderWidth : CGFloat, borderColor : UIColor, radius : CGFloat) {
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
    }
    
    func clipRightCorner(offset : CGFloat) {
        let path = UIBezierPath()
        path.move(to: .init(x: 0, y: 0))
        path.addLine(to: .init(x: self.bounds.size.width - offset, y: 0))
        path.addLine(to: .init(x: self.bounds.size.width, y: offset))
        path.addLine(to: .init(x: self.bounds.size.width, y: self.bounds.size.height))
        path.addLine(to: .init(x: 0, y: self.bounds.size.height))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        self.layer.mask = shapeLayer
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    
    @discardableResult
    func addBorders(edges: UIRectEdge,
                    color: UIColor,
                    inset: CGFloat = 0.0,
                    thickness: CGFloat = 1.0) -> [UIView] {
        
        var borders = [UIView]()
        
        @discardableResult
        func addBorder(formats: String...) -> UIView {
            let border = UIView(frame: .zero)
            border.backgroundColor = color
            border.translatesAutoresizingMaskIntoConstraints = false
            addSubview(border)
            addConstraints(formats.flatMap {
                NSLayoutConstraint.constraints(withVisualFormat: $0,
                                               options: [],
                                               metrics: ["inset": inset, "thickness": thickness],
                                               views: ["border": border]) })
            borders.append(border)
            return border
        }
        
        
        if edges.contains(.top) || edges.contains(.all) {
            addBorder(formats: "V:|-0-[border(==thickness)]", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            addBorder(formats: "V:[border(==thickness)]-0-|", "H:|-inset-[border]-inset-|")
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:|-0-[border(==thickness)]")
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            addBorder(formats: "V:|-inset-[border]-inset-|", "H:[border(==thickness)]-0-|")
        }
        
        return borders
    }
    
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
}
