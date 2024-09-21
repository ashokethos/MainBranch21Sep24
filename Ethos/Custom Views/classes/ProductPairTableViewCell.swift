//
//  ProductPairTableViewCell.swift
//  Ethos
//
//  Created by Mac on 08/04/24.
//

import UIKit
import SkeletonView
import Mixpanel

class ProductPairTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productImage1: UIImageView!
    
    @IBOutlet weak var productImage2: UIImageView!
    
    @IBOutlet weak var lblTitle1: UILabel!
    
    @IBOutlet weak var lblTitle2: UILabel!
    
    @IBOutlet weak var lblDescription1: UILabel!
    
    @IBOutlet weak var lblDescription2: UILabel!
    
    @IBOutlet weak var viewProduct1: UIView!
    
    @IBOutlet weak var viewProduct2: UIView!
    
    @IBOutlet weak var btn1: UIButton!
    
    @IBOutlet weak var btn2: UIButton!
    
    var superViewController : NewCatalogViewController?
    var isForPreOwned : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblTitle1.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        self.lblTitle2.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        
        self.lblTitle1.skeletonTextNumberOfLines = 2
        self.lblTitle2.skeletonTextNumberOfLines = 2
        
        self.lblTitle1.skeletonLineSpacing = 10
        self.lblTitle2.skeletonLineSpacing = 10

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isForPreOwned = false
        self.contentView.hideSkeleton()
        
        self.product1 = nil
        self.product2 = nil
        
        self.productImage1.image = UIImage()
        self.productImage2.image = UIImage()
        
        self.lblTitle1.setAttributedTitleWithProperties(title: "", font: UIFont())
        
        self.lblTitle2.setAttributedTitleWithProperties(title: "", font: UIFont())
        
        self.lblDescription1.setAttributedTitleWithProperties(title: "", font: UIFont())
        
        self.lblDescription2.setAttributedTitleWithProperties(title: "", font: UIFont())
    }
    
    
    
    var product1 : Product? {
        didSet {
            
            var brandName = ""
            
            if let brand = self.product1?.extensionAttributes?.ethProdCustomeData?.brand {
                brandName = brand.uppercased()
            }
            
            let collectionName = product1?.extensionAttributes?.ethProdCustomeData?.collection?.uppercased() ?? ""
            
            var title = brandName + "\n" + collectionName
            
            if title.last == "\n" {
                title.removeLast()
            }
            
            self.lblTitle1.setAttributedTitleWithProperties(title: title, font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
            
            
            if let price =  self.isForPreOwned ? product1?.extensionAttributes?.ethProdCustomeData?.price : product1?.price,
               let currency = product1?.currency , currency == EthosConstants.INR {
                
                self.lblDescription1.setAttributedTitleWithProperties(title: EthosConstants.RupeesSymbol + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
                
            } else if let price = self.isForPreOwned ? product1?.extensionAttributes?.ethProdCustomeData?.price : product1?.price,
                      let currency = product1?.currency {
                self.lblDescription1.setAttributedTitleWithProperties(title: currency.uppercased() + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
            }
            
            if let urlfile = self.product1?.extensionAttributes?.ethProdCustomeData?.images?.catalogImage, let url = URL(string: urlfile) {
                self.productImage1.kf.setImage(
                    with: url
                )
            } else if let urlfile = self.product1?.assets?.first?.file, let url = URL(string: urlfile) {
                self.productImage1.kf.setImage(
                    with: url
                )
            }
            
            if let hidePrice = (product1?.extensionAttributes?.ethProdCustomeData?.hidePrice), self.isForPreOwned == true , hidePrice == true {
                self.lblDescription1.setAttributedTitleWithProperties(title: EthosConstants.RequestAnOffer.uppercased(), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
            }
        }
    }
    
    
    var product2 : Product? {
        didSet {
            
            var brandName = ""
            
            if let brand = self.product2?.extensionAttributes?.ethProdCustomeData?.brand {
                brandName = brand.uppercased()
            }
            
            let collectionName = product2?.extensionAttributes?.ethProdCustomeData?.collection?.uppercased() ?? ""
            
            var title = brandName + "\n" + collectionName
            
            if title.last == "\n" {
                title.removeLast()
            }
            
            self.lblTitle2.setAttributedTitleWithProperties(title: title, font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
            
            
            if let price =  self.isForPreOwned ? product2?.extensionAttributes?.ethProdCustomeData?.price : product2?.price,
               let currency = product2?.currency , currency == EthosConstants.INR {
                
                self.lblDescription2.setAttributedTitleWithProperties(title: EthosConstants.RupeesSymbol + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
                
            } else if let price = self.isForPreOwned ? product2?.extensionAttributes?.ethProdCustomeData?.price : product2?.price,
                      let currency = product2?.currency {
                self.lblDescription2.setAttributedTitleWithProperties(title: currency.uppercased() + " " + (price.getCommaSeperatedStringValue() ?? ""), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
                
            }
            
            if let urlfile = self.product2?.extensionAttributes?.ethProdCustomeData?.images?.catalogImage, let url = URL(string: urlfile) {
                self.productImage2.kf.setImage(
                    with: url
                )
            } else if let urlfile = self.product2?.assets?.first?.file, let url = URL(string: urlfile) {
                self.productImage2.kf.setImage(
                    with: url
                )
            }
            
            if let hidePrice = (product2?.extensionAttributes?.ethProdCustomeData?.hidePrice), self.isForPreOwned == true , hidePrice == true {
                self.lblDescription2.setAttributedTitleWithProperties(title: EthosConstants.RequestAnOffer.uppercased(), font: EthosFont.Brother1816Medium(size: 10),alignment: .center, lineHeightMultiple: 1.32, kern: 1)
            }
        }
    }
    
    func routeToProductDetails(product : Product) {
        if self.isForPreOwned {
            if let vc = self.superViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                vc.sku = product.sku
                self.superViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = self.superViewController?.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                vc.sku = product.sku
                
                      Mixpanel.mainInstance().trackWithLogs(
                          event: EthosConstants.ProductClicked,
                          properties: [
                          EthosConstants.Email : Userpreference.email,
                          EthosConstants.UID : Userpreference.userID,
                          EthosConstants.Gender : Userpreference.gender,
                          EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                          EthosConstants.Platform : EthosConstants.IOS,
                          EthosConstants.ProductSKU : product.sku,
                          EthosConstants.ProductType : product.extensionAttributes?.ethProdCustomeData?.brand,
                          EthosConstants.ProductName : product.extensionAttributes?.ethProdCustomeData?.productName,
                          EthosConstants.SKU : product.sku,
                          EthosConstants.Price : product.price,
                          EthosConstants.ShopType : EthosConstants.Ethos,
                          EthosConstants.ProductSubCategory : EthosConstants.Catalog
                      ]
                      )
                self.superViewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

    @IBAction func btn1DidTapped(_ sender: UIButton) {
        if let product = self.product1 {
            self.routeToProductDetails(product: product)
        }
    }
    
    
    @IBAction func btn2DidTapped(_ sender: UIButton) {
        if let product = self.product2 {
            self.routeToProductDetails(product: product)
        }
    }
    
    
}
