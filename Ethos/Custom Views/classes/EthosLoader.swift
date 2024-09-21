//
//  CustomLoader.swift
//  Ethos
//
//  Created by SoftGrid on 14/07/23.
//

import Foundation
import UIKit

class EthosLoader : UIView {
    @IBOutlet weak var imageViewLoader : UIImageView!

    public static var shared = EthosLoader()
    
    func show(view : UIView, frame: CGRect) {
        self.frame = frame
        self.imageViewLoader.image = UIImage.gifImageWithName("loader")
        view.addSubview(EthosLoader.shared)
    }
    
    func instantiate() {
        let nib = UINib(nibName: String(describing: EthosLoader.self), bundle: nil)
        let view = nib.instantiate(withOwner: nil).first as! EthosLoader
        EthosLoader.shared = view
    }
   
    
    func hide() {
      EthosLoader.shared.removeFromSuperview()
    }
   
}
