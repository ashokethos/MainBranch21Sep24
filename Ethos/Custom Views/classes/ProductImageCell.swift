//
//  ProductImageCell.swift
//  Ethos
//
//  Created by mac on 04/07/23.
//

import UIKit

class ProductImageCell: UICollectionViewCell {

    @IBOutlet weak var scrollViewImage: UIScrollView!
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var btnYoutube: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    var shouldShowVideo : Bool = false {
        didSet {
            if shouldShowVideo == true {
                self.btnYoutube.isHidden = false
            } else {
                self.btnYoutube.isHidden = true
            }
        }
    }
    
    var tapGesture : UITapGestureRecognizer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollViewImage.delegate = self
        self.scrollViewImage.minimumZoomScale = 1
        self.scrollViewImage.maximumZoomScale = 4
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        tapGesture?.numberOfTapsRequired = 2
        self.imageProduct.isUserInteractionEnabled = true
        self.imageProduct.addGestureRecognizer(tapGesture ?? UITapGestureRecognizer())
    }
    
    override func prepareForReuse() {
        self.btnYoutube.isHidden = true
        self.imageProduct.image = nil
        self.imageProduct.frame = self.scrollViewImage.frame
        self.contentView.layoutIfNeeded()
        
    }
    
    @objc func tapAction(_ sender : UITapGestureRecognizer) {
        if self.scrollViewImage.zoomScale == 1 {
            self.scrollViewImage.zoomScale = 2.5
        } else {
            self.scrollViewImage.zoomScale = 1
        }
    }
    
    var asset : ProductAsset?
    
    var image : ProductImage? {
        didSet {
            if let img = image?.image {
                UIImage.loadFromURL(url: img) { image in
                    self.imageProduct.image = image
                    self.imageProduct.frame = self.scrollViewImage.frame
                    self.contentView.layoutIfNeeded()
                }
            }
        }
    }
}

extension ProductImageCell : UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageProduct
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
}
