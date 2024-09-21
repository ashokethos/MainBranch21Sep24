//
//  WishlistViewController.swift
//  Ethos
//
//  Created by mac on 03/08/23.
//

import UIKit
import Mixpanel

class EthosProfileCollectionViewController: UIViewController {

    @IBOutlet weak var viewNoArticles: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var btnAddProductsToWishList: UIButton!
    var savedProducts = [Product]()
    var forPreOwn : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       fetchProducts()
    }
    
    func setup() {
        self.lblTitle.setAttributedTitleWithProperties(title: "You haven’t added any products yet", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), alignment: .center, lineHeightMultiple: 1.25, kern: 0.1)
        self.addTapGestureToDissmissKeyBoard()
        self.collectionView.registerCell(className: ProductCollectionViewCell.self)
        self.setViewNoData()
        self.btnAddProductsToWishList.setAttributedTitleWithProperties(title: "ADD PRODUCTS TO YOUR WISHLIST", font: EthosFont.Brother1816Medium(size: 12),  alignment: .center, foregroundColor: .white , backgroundColor: .black, lineHeightMultiple: 1.5, kern: 1)
    }
    
    func fetchProducts() {
        DataBaseModel().fetchProducts { products in
            DispatchQueue.main.async {
                
                var arrProducts = [Product]()
                
                for product in products {
                    let pro = Product()
                    pro.sku = product.sku
                    pro.name = product.name
                    pro.assets = [ProductAsset(id: 0, mediaType: "image", position: 0, disabled: false, types: [], file: product.thumbnailImage)]
                    
                    
                    
                    pro.movement =  [EthosConstants.brand: product.brand ?? ""]
                    pro.price = Int(product.price)
                    pro.currency = product.currency
                    
                    let imagedata = ProductImageData(catalogImage: product.thumbnailImage, gallery: [ProductImage(image: product.thumbnailImage, order: 0)] )
                   
                    pro.extensionAttributes = ExtensionAttributes(categoryLinks: [CategoryLink(position: 0, categoryID: String(product.categoryId))], ethProdCustomeData: EthProdCustomeData(sku: product.sku, brand: product.brand, collection: product.collectionName , productName: product.name, images: imagedata, hidePrice: product.hidePrice, price: Int(product.customPrice)))
                    
                    pro.forPreOwned = product.preowned
                    arrProducts.append(pro)
                }
                
                self.savedProducts = arrProducts
                self.reloadView()
            }
        }
    }
    
    func reloadView() {
        self.collectionView.reloadData()
        self.viewNoArticles.isHidden = !savedProducts.isEmpty
        
    }
    
    func setViewNoData() {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named:EthosConstants.profileWishlist)
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: imageAttachment.image?.size.width ?? 0, height: imageAttachment.image?.size.height ?? 0)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: EthosConstants.Click + "  ")
        completeText.append(attachmentString)
        let textAfterIcon = NSAttributedString(string: EthosConstants.tosaveproducts)
        completeText.append(textAfterIcon)
        self.lblMessage.textAlignment = .center
        self.lblMessage.attributedText = completeText
        
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnExploreNowDidTapped(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 2
//        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
//            vc.screenType = "view_all"
//            vc.productViewModel.categoryName = "All Watches"
//            vc.productViewModel.categoryId = 110
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension EthosProfileCollectionViewController  : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as! ProductCollectionViewCell
        cell.isForPreOwned = savedProducts[indexPath.item].forPreOwned
        cell.product = savedProducts[indexPath.item]
        cell.delegate = self
        cell.btnCross.isHidden = false
        cell.btnCrossArea.isHidden = false
        cell.contraintHeightCrossBtn.constant = 20
        cell.constraintBottomPrice.constant = 60
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.cellSize(noOfCellsInRow: 2, Height: 356)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if savedProducts[indexPath.item].forPreOwned {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                vc.sku = savedProducts[indexPath.item].sku
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                vc.sku = savedProducts[indexPath.item].sku
                
                Mixpanel.mainInstance().trackWithLogs(
                    event: EthosConstants.ProductClicked,
                    properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ProductSKU : savedProducts[indexPath.item].sku,
                    EthosConstants.ProductType : savedProducts[indexPath.item].extensionAttributes?.ethProdCustomeData?.brand,
                    EthosConstants.ProductName : savedProducts[indexPath.item].extensionAttributes?.ethProdCustomeData?.productName,
                    EthosConstants.SKU : savedProducts[indexPath.item].sku,
                    EthosConstants.Price : savedProducts[indexPath.item].price,
                    EthosConstants.ShopType : EthosConstants.Ethos,
                    EthosConstants.ProductSubCategory :  "Saved Products"
                ]
                )
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

    }
    
}

extension EthosProfileCollectionViewController : SuperViewDelegate {
    
    func updateView(info: [EthosKeys : Any?]?) {
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.reloadCollectionView {
            fetchProducts()
        }
    }
}
