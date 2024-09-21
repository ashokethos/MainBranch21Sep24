//
//  ProductCollectionViewCell.swift
//  Ethos
//
//  Created by mac on 27/06/23.
//

import UIKit
import Kingfisher
import SkeletonView

class ProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageProduct: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var btnCrossArea: UIButton!
    @IBOutlet weak var contraintHeightCrossBtn: NSLayoutConstraint!
    var isForPreOwned = false
    @IBOutlet weak var constraintBottomPrice: NSLayoutConstraint!
    
    var delegate : SuperViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle.skeletonTextNumberOfLines = 2
        self.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblTitle.skeletonLineSpacing = 10
      
        self.btnCross.isHidden = true
        self.contraintHeightCrossBtn.constant = 0
    }
    
    var product : Product? {
        didSet {
            
            var brandName = ""
            
            if let brand = self.product?.extensionAttributes?.ethProdCustomeData?.brand {
                brandName = brand.uppercased()
            }
            
            let collectionName = product?.extensionAttributes?.ethProdCustomeData?.collection?.uppercased() ?? ""
            
            var title = brandName + "\n" + collectionName
            
            if title.last == "\n" {
                title.removeLast()
            }
            
            self.lblTitle.setAttributedTitleWithProperties(title: title, font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
            
            
            if let price =  self.isForPreOwned ? product?.extensionAttributes?.ethProdCustomeData?.price : product?.price,
               let currency = product?.currency , currency == EthosConstants.INR {
                
                self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.RupeesSymbol + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
                
            } else if let price = self.isForPreOwned ? product?.extensionAttributes?.ethProdCustomeData?.price : product?.price,
                      let currency = product?.currency {
                self.lblDescription.setAttributedTitleWithProperties(title: currency.uppercased() + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
            }
            
            if let urlfile = self.product?.extensionAttributes?.ethProdCustomeData?.images?.catalogImage, let url = URL(string: urlfile) {
                self.imageProduct.kf.setImage(
                    with: url
                )
            } else if let urlfile = self.product?.assets?.first?.file, let url = URL(string: urlfile) {
                self.imageProduct.kf.setImage(
                    with: url
                )
            }
            
            if let hidePrice = (product?.extensionAttributes?.ethProdCustomeData?.hidePrice), self.isForPreOwned == true , hidePrice == true {
                self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.RequestAnOffer.uppercased(), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
            }
        }
    }
    
    var productLite : ProductLite? {
        didSet {
            
            guard let product = self.productLite else {
                return
            }
            
            var brandName = ""
            self.btnCross.isHidden = true
            if let brand = product.brand {
                brandName = brand.uppercased()
            }
            
            let collectionName = product.collection?.uppercased() ?? ""
            
            var title = brandName + "\n" + collectionName
            
            if title.last == "\n" {
                title.removeLast()
            }
            
            self.lblTitle.setAttributedTitleWithProperties(title: title, font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
            
            
            if let price =  product.price,
               let currency = product.currency , currency == EthosConstants.INR {
                
                self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.RupeesSymbol + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
                
            } else if let price = product.price,
                      let currency = product.currency {
                self.lblDescription.setAttributedTitleWithProperties(title: currency.uppercased() + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
            }
            
            if let urlfile = product.catalogImage, let url = URL(string: urlfile) {
                self.imageProduct.kf.setImage(
                    with: url
                )
            }
        }
    }
    
    override func prepareForReuse() {
        self.isForPreOwned = false
        self.imageProduct.image = nil
        self.btnCross.isHidden = true
        self.btnCrossArea.isHidden = true
        self.lblTitle.text = ""
        self.lblDescription.text = ""
        self.btnCross.isHidden = true
        self.contraintHeightCrossBtn.constant = 0
        self.constraintBottomPrice.constant = 24
        
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        if let product = self.product {
            DispatchQueue.main.async {
                if let alertController = UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                    alertController.setActions(title: EthosConstants.AreYouSureToWantToDeleteThisItem, message: "", firstActionTitle: EthosConstants.Cancel.uppercased(), secondActionTitle: EthosConstants.Confirm.uppercased(), firstAction: {
                    }) {
                        DataBaseModel().checkProductExists(product: product) { exist in
                            if  exist {
                                DataBaseModel().unsaveProduct(product: product) {
                                    self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.reloadCollectionView])
                                }
                            }
                        }
                    }
                    
                    UIApplication.topViewController()?.present(alertController, animated: true)
                }
            }
        }
    }
}




