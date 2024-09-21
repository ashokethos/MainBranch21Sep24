//
//  ProductDetailTableViewCell.swift
//  Ethos
//
//  Created by mac on 12/12/23.
//

import UIKit
import Lottie
import Mixpanel
import SkeletonView

class ProductDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionViewProductImage: UICollectionView!
    @IBOutlet weak var constraintHeightScrollIndicator: NSLayoutConstraint!
    @IBOutlet weak var viewInnerScrollIndicator: UIView!
    @IBOutlet weak var viewOuterScrollIndicator: UIView!
    @IBOutlet weak var lblProductSerialNumber: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductPrice: UILabel!
    @IBOutlet weak var lblProductPriceMessage: UILabel!
    @IBOutlet weak var btnCheckOurSellingPrice: UIButton!
    @IBOutlet weak var btnWishList: UIButton!
    
    @IBOutlet weak var viewWishList: UIView!
    @IBOutlet weak var constraintSpacingPriceMessage: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingPrice: NSLayoutConstraint!
    
    var animaedView : LottieAnimationView = LottieAnimationView(name: "wishlist_animation")
    
    var delegate  : SuperViewDelegate?
    var index : IndexPath?
    var superTableView : UITableView?
    var superViewController : UIViewController?
    var isForPreOwned = false
    var images = [ProductImage]()
    
    var product : Product? {
        didSet {
            if let product = self.product {
                self.setUI(product: product)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewWishList.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        self.collectionViewProductImage.registerCell(className: ProductImageCell.self)
        self.collectionViewProductImage.dataSource = self
        self.collectionViewProductImage.delegate = self
        self.btnCheckOurSellingPrice.setBorder(borderWidth: 0, borderColor: .clear, radius: 0)
        animaedView.contentMode = .scaleAspectFill
        animaedView.frame = self.btnWishList.bounds
        animaedView.isUserInteractionEnabled = false
        self.btnWishList.addSubview(self.animaedView)
        self.lblProductName.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(20)
    }
    
    override func prepareForReuse() {
        self.isForPreOwned = false
        self.contentView.hideSkeleton()
        self.collectionViewProductImage.hideSkeleton()
    }
    
    @IBAction func btnWishListDidTapped(_ sender: UIButton) {
        VibrationHelper.vibrate()
        if let product = self.product {
            if !btnWishList.isSelected {
                DataBaseModel().checkProductExists(product: product, completion: { exist in
                    if !exist {
                        DataBaseModel().saveProduct(product: product, forPreOwn: self.isForPreOwned) {
                            DataBaseModel().checkProductExists(product: product) { exist in
                                self.btnWishList.isSelected = exist
                                self.animaedView.play(fromProgress: exist ? 0 : 0.5, toProgress: exist ? 0.5 : 1)
                                self.superViewController?.showToast(message: exist ? "Product added to your wishlist" : "Product removed from your wishlist")
                            }
                        }
                    } else {
                        self.btnWishList.isSelected = true
                        self.animaedView.play(fromProgress: 0, toProgress: 0.5)
                        self.superViewController?.showToast(message: "Product added to your wishlist")
                    }
                })
                
            } else {
                
                DataBaseModel().checkProductExists(product: product) { exist in
                    if exist {
                        DataBaseModel().unsaveProduct(product: product) {
                            
                            DataBaseModel().checkProductExists(product: product) { exist in
                                self.btnWishList.isSelected = exist
                                self.animaedView.play(fromProgress: exist ? 0 : 0.5, toProgress: exist ? 0.5 : 1)
                                
                                self.superViewController?.showToast(message: exist ? "Product added to your wishlist" : "Product removed from your wishlist")
                                
                            }
                        }
                    } else {
                        self.btnWishList.isSelected = false
                        self.animaedView.play(fromProgress: 0.5, toProgress: 1)
                        self.superViewController?.showToast(message: "Product removed from your wishlist")
                    }
                }
            }
        }
    }
    
    func setUI(product : Product) {
        
        DataBaseModel().checkProductExists(product: product) { exist in
            if exist {
                self.animaedView.currentProgress = 0.5
                self.btnWishList.isSelected = true
            }
        }
        
        let productName = product.extensionAttributes?.ethProdCustomeData?.productName ?? ""
        
        let productBrand = product.extensionAttributes?.ethProdCustomeData?.brand ?? ""
        
        var title = productBrand + "\n" + productName
        
        if title.last == "\n" {
            title.removeLast()
        }
        
        
        self.lblProductName.setAttributedTitleWithProperties(title: title, font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), foregroundColor: .black, lineHeightMultiple: 1.25, kern: 0.5)
        
        self.lblProductPriceMessage.setAttributedTitleWithProperties(title: "*Inclusive of all taxes" , font: EthosFont.Brother1816Regular(size: 10), foregroundColor: EthosColor.seperatorColor, lineHeightMultiple: 1, kern: 0.1)
        
        if let btnText = product.extensionAttributes?.ethProdCustomeData?.buttonText, btnText != "" {
            self.btnCheckOurSellingPrice.setAttributedTitleWithProperties(title: btnText.uppercased(), font: EthosFont.Brother1816Bold(size: 10),foregroundColor: .white,kern: 0.5)
        } else {
            self.btnCheckOurSellingPrice.setAttributedTitleWithProperties(title: "Check our selling price".uppercased(), font: EthosFont.Brother1816Bold(size: 10),foregroundColor: .white,kern: 0.5)
        }
        
        if let model = product.sku {
            self.lblProductSerialNumber.setAttributedTitleWithProperties(title: model, font: EthosFont.Brother1816Regular(size: 12), foregroundColor: .black, lineHeightMultiple: 1, kern: 1)
        }
        
        if let images = product.extensionAttributes?.ethProdCustomeData?.images?.gallery {
            self.images = images
            self.collectionViewProductImage.reloadData()
        }
        
        if let price = self.isForPreOwned ? product.extensionAttributes?.ethProdCustomeData?.price : product.price, let currency = product.currency {
            if self.isForPreOwned == true {
                self.lblProductPrice.setAttributedTitleWithProperties(title: (currency == EthosConstants.INR ? EthosConstants.RupeesSymbol : (currency)) + " " + (price.getCommaSeperatedStringValue() ?? "") , font: EthosFont.Brother1816Bold(size: 12), foregroundColor: .black, lineHeightMultiple: 1, kern: 1)
            } else {
                self.lblProductPrice.setAttributedTitleWithProperties(title: (currency == EthosConstants.INR ? EthosConstants.MRPWithRupeesSymbol : (EthosConstants.MRP + " " + currency)) + " " + (price.getCommaSeperatedStringValue() ?? "") , font: EthosFont.Brother1816Bold(size: 12), foregroundColor: .black, lineHeightMultiple: 1, kern: 1)
            }
        }
        
        if let hidePrice = (product.extensionAttributes?.ethProdCustomeData?.hidePrice),
           self.isForPreOwned == true, hidePrice == true {
            self.lblProductPrice.setAttributedTitleWithProperties(title: "" , font: EthosFont.Brother1816Bold(size: 12), foregroundColor: .black, lineHeightMultiple: 1, kern: 1)
            self.lblProductPriceMessage.setAttributedTitleWithProperties(title: "" , font: EthosFont.Brother1816Bold(size: 12), foregroundColor: .black, lineHeightMultiple: 1, kern: 0.1)
            self.btnCheckOurSellingPrice.setAttributedTitleWithProperties(title: EthosConstants.RequestAnOffer.uppercased(), font: EthosFont.Brother1816Bold(size: 10),foregroundColor: .white,kern: 0.5)
            self.constraintSpacingPrice.constant = 0
            self.constraintSpacingPriceMessage.constant = 0
        } else {
            self.constraintSpacingPrice.constant = 10
            self.constraintSpacingPriceMessage.constant = 24
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            let multiplier = self.viewOuterScrollIndicator.frame.height/self.collectionViewProductImage.contentSize.height
            if multiplier.isFinite {
                self.constraintHeightScrollIndicator.constant = multiplier*(self.collectionViewProductImage.contentOffset.y + self.collectionViewProductImage.frame.height)
            }
        }
        
    }
    
    @IBAction func btnCheckOurSellingpriceDidTapped(_ sender: UIButton) {
        if let product = self.product {
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.CheckProductSellingPriceClicked,
                properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ProductType : product.extensionAttributes?.ethProdCustomeData?.brand,
                    EthosConstants.ProductName : product.extensionAttributes?.ethProdCustomeData?.productName,
                    EthosConstants.SKU :  product.sku,
                    EthosConstants.Price : product.price
                ])
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.checkOurSellingPrice, EthosKeys.Product : product])
        }
    }
}

extension ProductDetailTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionViewProductImage {
            let multiplier = viewOuterScrollIndicator.frame.height/collectionViewProductImage.contentSize.height
            if multiplier.isFinite {
                constraintHeightScrollIndicator.constant = multiplier*(collectionViewProductImage.contentOffset.y + collectionViewProductImage.frame.height)
            }
        }
        
    }
}

extension ProductDetailTableViewCell : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return String(describing: ProductImageCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductImageCell.self), for: indexPath) as? ProductImageCell {
            cell.contentView.showAnimatedGradientSkeleton()
            return cell
        }
        return UICollectionViewCell()
    }
}

extension ProductDetailTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductImageCell.self), for: indexPath) as? ProductImageCell {
            cell.hideSkeleton()
            if self.isForPreOwned {
                cell.shouldShowVideo = (self.product?.extensionAttributes?.ethProdCustomeData?.showVideo == true)
                cell.btnYoutube.addTarget(self, action: #selector(btnYouTubeAction), for: .touchUpInside)
            } else {
                if self.product?.extensionAttributes?.ethProdCustomeData?.brand == EthosConstants.FavreLeuba {
                    cell.shouldShowVideo = (self.product?.extensionAttributes?.ethProdCustomeData?.favreLeubaData?.videoUrl != nil && self.product?.extensionAttributes?.ethProdCustomeData?.favreLeubaData?.videoUrl != "")
                    cell.btnYoutube.addTarget(self, action: #selector(favreLeubaVideo), for: .touchUpInside)
                } else  {
                    cell.shouldShowVideo = (self.product?.extensionAttributes?.ethProdCustomeData?.showVideo == true && self.product?.extensionAttributes?.ethProdCustomeData?.productVideos.count ?? 0 > 0)
                    cell.btnYoutube.addTarget(self, action: #selector(btnYouTubeAction), for: .touchUpInside)
                }
            }
            
            cell.btnShare.addTarget(self, action: #selector(btnShareAction), for: .touchUpInside)
            
            cell.image = images[indexPath.item]
            
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    @objc func favreLeubaVideo() {
        if self.isForPreOwned == false {
            self.superTableView?.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }
    }
    
    @objc func btnShareAction() {
        if let product = self.product {
            let activityViewController = UIActivityViewController(activityItems: [ product.extensionAttributes?.ethProdCustomeData?.url ?? "https://www.ethoswatches.com/"], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {
                type, complete, res, error in
                if complete {
                    Mixpanel.mainInstance().trackWithLogs(
                        event: EthosConstants.ProductShared,
                        properties: [
                            "Email" : Userpreference.email ?? "",
                            EthosConstants.UID : Userpreference.userID ?? "",
                            EthosConstants.Gender : Userpreference.gender ?? "",
                            EthosConstants.Platform : EthosConstants.IOS,
                            EthosConstants.Registered : (Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y,
                            EthosConstants.ProductName : product.extensionAttributes?.ethProdCustomeData?.productName ?? "",
                            EthosConstants.SKU : product.sku ?? "",
                            EthosConstants.Price : product.price,
                            EthosConstants.ProductType : product.extensionAttributes?.ethProdCustomeData?.brand,
                            EthosConstants.SharedVia : type?.rawValue
                        ]
                    )
                }
            }
            self.superViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @objc func btnYouTubeAction() {
        if self.isForPreOwned {
            if let index = (self.superViewController as? SecondMovementProductDetailsVC)?.arrSections.firstIndex(where: { sectionHeader in
                sectionHeader.0 == "Video" && sectionHeader.1 == true
            }) {
                (self.superViewController as? SecondMovementProductDetailsVC)?.arrSections[index].1 = false
                self.superTableView?.reloadData()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.superTableView?.scrollToRow(at: IndexPath(row: 0, section: index + 2), at: .top, animated: true)
                }
            } else if let index = (self.superViewController as? SecondMovementProductDetailsVC)?.arrSections.firstIndex(where: { sectionHeader in
                sectionHeader.0 == "Video" && sectionHeader.1 == false
            }) {
                DispatchQueue.main.async {
                    self.superTableView?.scrollToRow(at: IndexPath(row: 0, section: index + 2), at: .top, animated: true)
                }
            }
        } else {
            if let index = (self.superViewController as? ProductDetailViewController)?.arrSections.firstIndex(where: { sectionHeader in
                sectionHeader.0 == "Video" && sectionHeader.1 == true
            }) {
                (self.superViewController as? ProductDetailViewController)?.arrSections[index].1 = false
                self.superTableView?.reloadData()
                DispatchQueue.main.async {
                    self.superTableView?.scrollToRow(at: IndexPath(row: 0, section: index + 3), at: .top, animated: true)
                }
            } else if let index = (self.superViewController as? ProductDetailViewController)?.arrSections.firstIndex(where: { sectionHeader in
                sectionHeader.0 == "Video" && sectionHeader.1 == false
            }) {
                DispatchQueue.main.async {
                    self.superTableView?.scrollToRow(at: IndexPath(row: 0, section: index + 3), at: .top, animated: true)
                }
            }
        }
    }
}
