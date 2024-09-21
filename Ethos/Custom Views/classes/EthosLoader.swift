//
//  CustomLoader.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation
import UIKit
import Lottie

class EthosLoader : UIView {
    
    
    public static var shared = EthosLoader()
    var animatedView : LottieAnimationView = LottieAnimationView(name: "ethos_loader_animation")
    
    
    
    @IBOutlet weak var viewAnimation: UIView!
    
    
    
    
    func show(view : UIView, frame: CGRect) {
        EthosLoader.shared.animatedView.play()
        self.frame = frame
        view.addSubview(EthosLoader.shared)
    }
    
    func instantiate() {
        let nib = UINib(nibName: String(describing: EthosLoader.self), bundle: nil)
        let view = nib.instantiate(withOwner: nil).first as! EthosLoader
        EthosLoader.shared = view
        EthosLoader.shared.animatedView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        EthosLoader.shared.viewAnimation.addSubview(EthosLoader.shared.animatedView)
        var imageLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        
        EthosLoader.shared.animatedView.loopMode = .loop
        EthosLoader.shared.animatedView.animationSpeed = 2
        EthosLoader.shared.animatedView.addSubview(imageLogo)
        
        EthosLoader.shared.animatedView.setBorder(borderWidth: 0, borderColor: .clear, radius: 40)
        EthosLoader.shared.animatedView.backgroundColor = .white
        
    }
   
    
    func hide() {
      EthosLoader.shared.removeFromSuperview()
    }
   
}
