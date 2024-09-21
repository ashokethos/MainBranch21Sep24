//
//  ProductDetailViewController.swift
//  Ethos
//
//  Created by mac on 14/09/23.
//

import UIKit
import SafariServices
import Mixpanel
import SkeletonView

class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var tableViewProductDetails: EthosContentSizedTableView!
    @IBOutlet weak var checkSellingPriceMainBackView: UIView!
    @IBOutlet weak var checkSellingPriceBackView: UIView!
    @IBOutlet weak var checkSellingPriceBtn: UIButton!
    @IBOutlet weak var priceLbl: UILabel!
    
    
    var arrSections : [(String, Bool)] = []
    var calbreImage : String?
    var attributes = [AttributeDescription]()
    var attributedStrArr = [(NSAttributedString, NSAttributedString)]()
    var sku : String?
    var video : String?
    var movement : [String : String]?
    var recentProducts = [Product]()
    let refreshControl = UIRefreshControl()
    var viewModel = GetProductViewModel()
    var adViewModel = GetAdsViewModel()
    var forStoryRoute : Bool = false
    var story : Banner?
    var checkSellingPriceDelegate : SuperViewDelegate?
    
    var loadingProduct : Bool = true {
        didSet {
            self.setUI()
        }
    }
    
    var loadingBetterTogether : Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.tableViewProductDetails.reloadData()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        print(view.frame.width)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.callApi()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for index in tableViewProductDetails.indexPathsForVisibleRows ?? [] {
            if let cell = tableViewProductDetails.cellForRow(at: index) as? AdvertisementCell {
                cell.btnPausePlay.isSelected = false
                cell.playerLayer.player?.pause()
            }
            
            if let cell = tableViewProductDetails.cellForRow(at: index) as? EthosVideoTableViewCell {
                cell.btnPlayPause.isSelected = false
                cell.btnPlayPause.isHidden = false
                cell.playerLayer.player?.pause()
            }
            
            if let cell = tableViewProductDetails.cellForRow(at: index) as? FavreLeubaHeaderTableViewCell {
                cell.btnPlayPause.isSelected = false
                cell.playerLayer.player?.pause()
            }
        }
    }
    
    func callApi() {
        if let sku = self.sku {
            self.loadingProduct = true
            self.loadingBetterTogether = true
            self.adViewModel.getAdvertisment(site: .ethos, location: EthosConstants.product){
                DispatchQueue.main.async {
                    self.fetchRecentProductsFromDataBase(sku: sku) {
                        self.viewModel.getProductDetails(sku: sku, site: .ethos)
                        self.viewModel.betterTogether(sku: sku, site: .ethos)
                    }
                }
            }
        }
    }
    
    func fetchRecentProductsFromDataBase(sku : String,completion :  @escaping () -> ()) {
        
        DataBaseModel().fetchRecentProducts { products in
            DispatchQueue.main.async {
                var arrProducts = [Product]()
                
                let sortedProducts = products.sorted { p1, p2 in
                    (p1.addedDate ?? Date()) > (p2.addedDate ?? Date())
                }
                
                for product in sortedProducts {
                    if product.sku != sku, product.preowned == false {
                        let pro = Product()
                        pro.sku = product.sku
                        pro.name = product.name
                        pro.assets = [ProductAsset(id: 0, mediaType: EthosConstants.image, position: 0, disabled: false, types: [], file: product.thumbnailImage)]
                        pro.movement = [EthosConstants.brand: product.brand ?? ""]
                        pro.price = Int(product.price)
                        pro.currency = product.currency
                        let imagedata = ProductImageData(catalogImage: product.thumbnailImage, gallery: [ProductImage(image: product.thumbnailImage, order: 0)] )
                        pro.extensionAttributes = ExtensionAttributes(categoryLinks: [CategoryLink(position: 0, categoryID: String(product.categoryId))], ethProdCustomeData: EthProdCustomeData(sku: product.sku, brand: product.brand ,collection: product.collectionName, productName: product.name, images: imagedata, hidePrice: product.hidePrice, price: Int(product.customPrice)))
                        pro.forPreOwned = product.preowned
                        pro.recentDate = product.addedDate
                        pro.forPreOwned = product.preowned
                        arrProducts.append(pro)
                    }
                }
                
                self.recentProducts = arrProducts.sorted(by: { p1, p2 in
                    (p1.recentDate ?? Date()) > (p2.recentDate ?? Date())
                })
                completion()
            }
        }
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.tableViewProductDetails.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        callApi()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.tableViewProductDetails.refreshControl?.endRefreshing()
        }
    }
    
    func setup() {
        checkSellingPriceMainBackView.alpha = 0.0
        checkSellingPriceBackView.dropShadow(color: .lightGray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        checkSellingPriceBtn.setBorder(borderWidth: 0, borderColor: .clear, radius: 0)
        self.addTapGestureToDissmissKeyBoard()
        self.tableViewProductDetails.registerCell(className: SingleCollectionTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: SpecificationPairTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: EditorNotesTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: MovementTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: AdvertisementCell.self)
        self.tableViewProductDetails.registerCell(className: HeadingCell.self)
        self.tableViewProductDetails.registerCell(className: EthosVideoTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: HtmlContainerForAboutCollectionTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: HorizontalCollectionTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: SpacingTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: FavreLeubaHeaderTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: CornerCutImageTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: ProductDetailTableViewCell.self)
        viewModel.delegate = self
        checkSellingPriceDelegate = self
        self.addRefreshControl()
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func deleteExtraProducts(product : Product) {
        DataBaseModel().fetchRecentProducts { recentProducts in
            
            let products = recentProducts.filter { product in
                (product.preowned) == false
            }
            
            if products.count > 6 {
                let extraProducts = products.count - 6
                let sortedProducts = products.sorted { p1, p2 in
                    (p1.addedDate ?? Date()) > (p2.addedDate ?? Date())
                }
                
                let productToDelete = sortedProducts.suffix(extraProducts)
                
                for deletableProduct in productToDelete {
                    DispatchQueue.main.async {
                        if deletableProduct.sku != product.sku {
                            DataBaseModel().unsaveRecentProduct(product: Product(sku : deletableProduct.sku)) {}
                        }
                    }
                }
            }
        }
    }
    
    func addRecentProduct(product : Product) {
        DataBaseModel().checkRecentProductExists(product: product) { exist in
            if exist == false {
                DataBaseModel().saveRecentProduct(product: product, forPreOwn: false) {
                    self.deleteExtraProducts(product: product)
                    
                }
            } else {
                DataBaseModel().updateDateOfExistingProduct(product: product) {
                    self.deleteExtraProducts(product: product)
                }
            }
        }
    }
    
    func setUI() {
        
        guard let product = self.viewModel.product else {
            return
        }
        
        addRecentProduct(product: product)
        
        self.arrSections.removeAll()
        
        if product.extensionAttributes?.ethProdCustomeData?.showEditosNote == true {
            if product.extensionAttributes?.ethProdCustomeData?.editorDescription != nil && product.extensionAttributes?.ethProdCustomeData?.editorDescription != "" && self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.brand != EthosConstants.FavreLeuba{
                self.arrSections.append((product.extensionAttributes?.ethProdCustomeData?.editorHeading?.uppercased() ?? "",false))
            }
        }
        
        if let customData = product.extensionAttributes?.ethProdCustomeData?.attributesDictionary {
            self.arrSections.append(((EthosConstants.FullSpecification), false))
            var attributes = [AttributeDescription]()
            for (key, value) in customData {
                
                let containsKey = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.specificationAttributes?.contains(key) ?? false
                
                if key == "" || containsKey == false {
                    print("\(key) not added in attributes")
                } else {
                    if let dict = value as? [String:Any] {
                        let attr = AttributeDescription(json: dict)
                        attributes.append(attr)
                    }
                }
            }
            
            var filteredAttributes = [AttributeDescription]()
            
            for attr in attributes {
                if (attr.displayName != nil) && (attr.displayName != "") {
                    filteredAttributes.append(attr)
                }
            }
            
            self.attributes = filteredAttributes.sorted(by: { a, b in
                (b.displayName ?? "").lowercased() > (a.displayName ?? "").lowercased()
            })
            
            var arrtributedStringArr = [(NSAttributedString, NSAttributedString)]()
            
            for attribute in filteredAttributes {
                
                let displayName = attribute.displayName ?? ""
                var valueText = ""
                if let value = attribute.value?.displayName {
                    valueText = value
                } else if let values = attribute.values {
                    var valueStr = ""
                    for val in values {
                        if let displayname = val.displayName {
                            valueStr.append(displayname + ", ")
                        }
                    }
                    if valueStr.hasSuffix(", ") {
                        let str = valueStr.dropLast(2)
                        valueStr = String(str)
                    }
                    valueText = valueStr
                }
                
                let titleStr = displayName.htmlToAttributedString
                let descriptionStr = valueText.htmlToAttributedString
                
                
                if titleStr?.string != "" && descriptionStr?.string != "" {
                    titleStr?.addAttribute(NSAttributedString.Key.font, value: EthosFont.Brother1816Medium(size: 12), range: NSRange(location: 0, length: titleStr?.length ?? 0))
                    
                    descriptionStr?.addAttribute(NSAttributedString.Key.font, value: EthosFont.Brother1816Regular(size: 12), range: NSRange(location: 0, length: descriptionStr?.length ?? 0))
                    
                    if let attribute : NSAttributedString = titleStr, let description : NSAttributedString = descriptionStr {
                        arrtributedStringArr.append((attribute, description))
                    }
                }
            }
            
            self.attributedStrArr = arrtributedStringArr.sorted(by: { a, b in
                b.0.string.lowercased() > a.0.string.lowercased()
            })
        }
        
        if product.extensionAttributes?.ethProdCustomeData?.showVideo == true && self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.brand != EthosConstants.FavreLeuba && product.extensionAttributes?.ethProdCustomeData?.productVideos.count ?? 0 > 0 {
            self.arrSections.append(((EthosConstants.Video), false))
        }
        
        if product.aboutCollection?.htmlToString != nil && product.aboutCollection?.htmlToString != "" && self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.brand != EthosConstants.FavreLeuba  {
            self.arrSections.append((EthosConstants.AboutTheCollection,false))
        }
        
        if product.extensionAttributes?.ethProdCustomeData?.showMovement == true && self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.brand != EthosConstants.FavreLeuba {
            self.arrSections.append(((EthosConstants.Movement), false))
            if let movement = product.extensionAttributes?.ethProdCustomeData?.movement {
                self.calbreImage = product.extensionAttributes?.ethProdCustomeData?.calibreImage
                self.movement = movement
            }
        }
        
        DispatchQueue.main.async {
            if let btnText = product.extensionAttributes?.ethProdCustomeData?.buttonText, btnText != "" {
                self.checkSellingPriceBtn.setAttributedTitleWithProperties(title: btnText.uppercased(), font: EthosFont.Brother1816Bold(size: self.view.frame.width > 390 ? 12 : 10),foregroundColor: .white,kern: 0.5)
            } else {
                self.checkSellingPriceBtn.setAttributedTitleWithProperties(title: "Check our selling price".uppercased(), font: EthosFont.Brother1816Bold(size: self.view.frame.width > 390 ? 12 : 10),foregroundColor: .white,kern: 0.5)
            }
            
            if let price = product.price, let currency = product.currency {
//                if self.isForPreOwned == true {
//                    self.priceLbl.setAttributedTitleWithProperties(title: (currency == EthosConstants.INR ? EthosConstants.RupeesSymbol : (currency)) + " " + (price.getCommaSeperatedStringValue() ?? "") , font: EthosFont.Brother1816Bold(size: 12), foregroundColor: .black, lineHeightMultiple: 1, kern: 1)
//                } else {
                self.priceLbl.setAttributedTitleWithProperties(title: (currency == EthosConstants.INR ? EthosConstants.MRPWithRupeesSymbol : (EthosConstants.MRP + " " + currency)) + " " + (price.getCommaSeperatedStringValue() ?? "") , font: EthosFont.Brother1816Bold(size: self.view.frame.width > 390 ? 12 : 10), foregroundColor: .black, lineHeightMultiple: 1, kern: 1)
//                }
            }
            self.tableViewProductDetails.reloadData()
        }
    }
    
    @IBAction func checkSellingPriceBtnAction(_ sender: UIButton) {
        guard let product = self.viewModel.product else {
            return
        }
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
            self.checkSellingPriceDelegate?.updateView(info: [EthosKeys.key : EthosKeys.checkOurSellingPrice, EthosKeys.Product : product])
    }
    
}

extension ProductDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.loadingProduct {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section == 2 {
                return self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.favreLeubaData?.subText?.count ?? 0
            } else if section == 3 {
                return 4
            } else if section == 4  {
                return adViewModel.ads.count > 0 ? 1 : 0
            } else {
                return 1
            }
        } else {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section == 2 {
                return self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.favreLeubaData?.subText?.count ?? 0
            } else if section < arrSections.count + 3 {
                
                if arrSections[section - 3].1 == true {
                    return 0
                } else {
                    if arrSections[section - 3].0 == EthosConstants.Video {
                        return self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.productVideos.count ?? 0
                    } else if arrSections[section - 3].0 == EthosConstants.FullSpecification {
                        if self.attributedStrArr.count%2 == 0 {
                            return self.attributedStrArr.count/2
                        } else {
                            return self.attributedStrArr.count/2 + 1
                        }
                    } else {
                        return 1
                    }
                }
                
            } else if section ==  arrSections.count + 2 + 2  {
                return adViewModel.ads.count > 0 ? 1 : 0
            } else {
                return 1
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.loadingProduct ? 8 : 3 + self.arrSections.count + 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if self.loadingProduct {
            if section == 0 {
                return nil
            } else if section == 1 {
                return nil
            } else if section == 2 {
                return nil
            } else if section == 3 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    cell.setHeading(
                        title: EthosConstants.FullSpecification.uppercased(),
                        leading: 30,
                        trailling: 30,
                        showDisclosure: true,
                        isSelected: true,
                        disclosureImageDefault: UIImage(named: EthosConstants.upArrow),
                        disclosureImageSelected: UIImage(named: EthosConstants.downArrow),
                        disclosureHeight: 16,
                        disclosureWidth: 16,
                        showTopLine: true,
                        
                        action: {
                            
                        })
                    
                    return cell
                }
            }
        } else {
            if section == 0 {
                return nil
            } else if section == 1 {
                return nil
            } else if section == 2 {
                return nil
            } else if section < (arrSections.count + 3) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    cell.setHeading(
                        title: arrSections[section - 3].0.uppercased(),
                        leading: 30,
                        trailling: 30,
                        showDisclosure: true,
                        isSelected: self.arrSections[section - 3].1,
                        disclosureImageDefault: UIImage(named: EthosConstants.upArrow),
                        disclosureImageSelected: UIImage(named: EthosConstants.downArrow),
                        disclosureHeight: 16,
                        disclosureWidth: 16,
                        showTopLine: true,
                        
                        action: {
                            self.arrSections[section - 3].1 = !self.arrSections[section - 3].1
                            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)), cell is HtmlContainerTableViewCell {
                                (cell as? HtmlContainerTableViewCell)?.unloadUrl()
                            }
                            self.tableViewProductDetails.reloadData()
                        })
                    
                    return cell
                }
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.loadingProduct {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section == 2 {
                return 1
            } else if section == 3 {
                return 70
            } else {
                return 1
            }
        } else {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section == 2 {
                return 1
            } else if section >= arrSections.count + 3 {
                return 1
            } else {
                return 70
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section != 0 && section != 1 && section != 2 && section < arrSections.count + 3 && arrSections[section - 3].0 == EthosConstants.Video && arrSections[section - 3].1 == false {
            return 16
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.loadingProduct {
            if indexPath.section == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductDetailTableViewCell.self), for: indexPath) as? ProductDetailTableViewCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionViewProductImage.showAnimatedGradientSkeleton()
                    return cell
                }
                
            } else if indexPath.section == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2 , color: .clear)
                    return cell
                }
            } else if indexPath.section == 2 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2 , color: .clear)
                    return cell
                }
            } else if indexPath.section == 3 {
                
                // Specification
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpecificationPairTableViewCell.self), for: indexPath) as? SpecificationPairTableViewCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                
                // Similar Products
                if indexPath.section == 4 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        cell.constraintHeightTopSeperator.constant = 8
                        cell.setTitle(title: EthosConstants.SimilarProducts.uppercased())
                        cell.key = .forSimilarWatches
                        return cell
                    }
                }
                
                // Advertisements
                if indexPath.section == 5 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2 , color: .clear)
                        return cell
                    }
                }
                
                // Better Together
                if indexPath.section == 6 {
                    if self.loadingBetterTogether {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            
                            if self.adViewModel.ads.count == 0 {
                                cell.constraintHeightTopSeperator.constant = 8
                            }
                            
                            cell.forSecondMovement = false
                            cell.key = .forBetterTogether
                            cell.setTitle(title: EthosConstants.BetterTogether.uppercased())
                            cell.contentView.showAnimatedGradientSkeleton()
                            cell.collectionView.showAnimatedGradientSkeleton()
                            cell.delegate = self
                            
                            cell.didGetProducts(site : nil, CategoryId : nil)
                            return cell
                        }
                    } else {
                        if self.viewModel.betterTogetherProducts.count > 0 {
                            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                                
                                cell.contentView.hideSkeleton()
                                cell.collectionView.hideSkeleton()
                                
                                if self.adViewModel.ads.count == 0 {
                                    cell.constraintHeightTopSeperator.constant = 8
                                }
                                
                                cell.productViewModel.betterTogetherProducts = self.viewModel.betterTogetherProducts
                                cell.forSecondMovement = false
                                cell.key = .forBetterTogether
                                cell.setTitle(title: EthosConstants.BetterTogether.uppercased())
                                cell.delegate = self
                                
                                cell.didGetProducts(site : nil, CategoryId : nil)
                                return cell
                            }
                        } else {
                            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                                cell.setSpacing(height: 2 , color: .clear)
                                return cell
                            }
                        }
                    }
                }
                
                // Recent Products
                if indexPath.section == 7 {
                    if self.recentProducts.count > 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            
                            if self.viewModel.similarProducts.count != 0  {
                                cell.constraintHeightTopSeperator.constant = 8
                            } else if self.viewModel.similarProducts.count != 0 {
                                cell.constraintHeightTopSeperator.constant = 8
                            } else if self.adViewModel.ads.count == 0 {
                                cell.constraintHeightTopSeperator.constant = 8
                            }
                            
                            cell.forSecondMovement = false
                            cell.setTitle(title: EthosConstants.RecentlyViewed.uppercased())
                            cell.delegate = self
                            cell.productViewModel.products = self.recentProducts
                            cell.key = .forRecentProducts
                            cell.viewBtnViewAll.isHidden = true
                            cell.didGetProducts(site: nil, CategoryId: nil)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2 , color: .clear)
                            return cell
                        }
                    }
                }
            }
        } else {
            if indexPath.section == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductDetailTableViewCell.self), for: indexPath) as? ProductDetailTableViewCell {
                    cell.isForPreOwned = false
                    cell.contentView.hideSkeleton()
                    cell.collectionViewProductImage.hideSkeleton()
                    cell.index = indexPath
                    cell.superViewController = self
                    cell.superTableView = self.tableViewProductDetails
                    cell.delegate = self
                    
                    if let product = self.viewModel.product {
                        cell.product = product
                    }
                    return cell
                }
                
            } else if indexPath.section == 1 {
                if self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.brand == EthosConstants.FavreLeuba {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FavreLeubaHeaderTableViewCell.self), for: indexPath) as? FavreLeubaHeaderTableViewCell {
                        if let data = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.favreLeubaData {
                            cell.data = data
                        }
                        
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2 , color: .clear)
                        return cell
                    }
                }
            } else if indexPath.section == 2 {
                
                if self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.brand == EthosConstants.FavreLeuba , self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.favreLeubaData?.subText?.count ?? 0 > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CornerCutImageTableViewCell.self), for: indexPath) as? CornerCutImageTableViewCell {
                        if let subtext = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.favreLeubaData?.subText?[safe : indexPath.row] {
                            cell.data = subtext
                        }
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2 , color: .clear)
                        return cell
                    }
                }
                
            } else if indexPath.section < arrSections.count + 3 {
                
                // Specifications
                if arrSections[indexPath.section - 3].0 == EthosConstants.FullSpecification {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpecificationPairTableViewCell.self), for: indexPath) as? SpecificationPairTableViewCell {
                        
                        cell.contentView.hideSkeleton(transition: .none)
                        
                        let indx = (indexPath.row*2)
                        
                        var str1 : NSAttributedString?
                        var str2 : NSAttributedString?
                        var str3 : NSAttributedString?
                        var str4 : NSAttributedString?
                        
                        if indx < attributedStrArr.count {
                            str1 = attributedStrArr[ safe : indx]?.0
                            str2 = attributedStrArr[ safe : indx]?.1
                        }
                        
                        if indx + 1 < attributedStrArr.count {
                            str3 = attributedStrArr[ safe : indx + 1]?.0
                            str4 = attributedStrArr[ safe : indx + 1]?.1
                        }
                        
                        cell.attribute = (str1, str2, str3, str4)
                        cell.layoutSubviews()
                        return cell
                    }
                }
                
                if arrSections[indexPath.section - 3].0 == self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.editorHeading?.uppercased() {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EditorNotesTableViewCell.self), for: indexPath) as? EditorNotesTableViewCell {
                        if let descriptionStr = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.editorDescription {
                                cell.descriptionString = descriptionStr
                            }
                        return cell
                    }
                }
                
                // Video
                if arrSections[indexPath.section - 3].0 == EthosConstants.Video {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosVideoTableViewCell.self), for: indexPath) as? EthosVideoTableViewCell {
                        cell.productVideo = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.productVideos[safe : indexPath.row]
                        cell.product = self.viewModel.product
                        return cell
                    }
                }
                
                // About collection
                if arrSections[indexPath.section - 3].0 == EthosConstants.AboutTheCollection {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HtmlContainerForAboutCollectionTableViewCell.self), for: indexPath) as? HtmlContainerForAboutCollectionTableViewCell {
                        cell.delegate = self
                        cell.index = indexPath
                        cell.webKitView.allowsLinkPreview = true
                        cell.superTableView = self.tableViewProductDetails
                        if let html = self.viewModel.product?.aboutCollection {
                            let imageCount = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.images?.gallery.count ?? 0
                            if let collectionImage =  self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.collectionImage {
                                cell.data = (collectionImage, html)
                            } else {
                                cell.htmlString = html
                            }
                            
                        }
                        return cell
                    }
                }
                
                // Movement
                if arrSections[indexPath.section - 3].0 == EthosConstants.Movement {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MovementTableViewCell.self), for: indexPath) as? MovementTableViewCell {
                        cell.calibreImage = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.calibreImage
                        cell.callibreDescription = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.calibreDescription
                        cell.movement = self.movement
                        
                        if cell.calibreImage != nil && cell.calibreImage != "" {
                            cell.constraintTopCalibreDescription.constant = 16
                        } else {
                            cell.constraintTopCalibreDescription.constant = 0
                        }
                        
                        return cell
                    }
                }
                
                
            } else {
                
                // Similar Products
                if indexPath.section == arrSections.count + 3 {
                    if self.viewModel.similarProducts.count == 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2 , color: .clear)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            cell.contentView.hideSkeleton()
                            cell.collectionView.hideSkeleton()
                            cell.constraintHeightTopSeperator.constant = 8
                            
                            cell.delegate = self
                            cell.forSecondMovement = false
                            cell.setTitle(title: EthosConstants.SimilarProducts.uppercased())
                            cell.productViewModel.similarProducts = self.viewModel.similarProducts
                            cell.key = .forSimilarWatches
                            return cell
                        }
                    }
                }
                
                // Advertisements
                if indexPath.section == (arrSections.count + 4) {
                    if self.adViewModel.ads.count == 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2 , color: .clear)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AdvertisementCell.self), for: indexPath) as? AdvertisementCell {
                            cell.delegate = self
                            cell.advertisment = self.adViewModel.ads[safe : indexPath.row]
                            cell.superTableView = self.tableViewProductDetails
                            cell.superViewController = self
                            cell.index = indexPath
                            return cell
                        }
                    }
                }
                
                // Better Together
                if indexPath.section == (arrSections.count + 5) {
                    if self.loadingBetterTogether {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            
                            if self.adViewModel.ads.count == 0 {
                                cell.constraintHeightTopSeperator.constant = 8
                            }
                            
                            
                            cell.forSecondMovement = false
                            cell.key = .forBetterTogether
                            cell.setTitle(title: EthosConstants.BetterTogether.uppercased())
                            cell.contentView.showAnimatedGradientSkeleton()
                            cell.collectionView.showAnimatedGradientSkeleton()
                            cell.delegate = self
                            
                            cell.didGetProducts(site : nil, CategoryId : nil)
                            return cell
                        }
                    } else {
                        if self.viewModel.betterTogetherProducts.count > 0 {
                            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                                
                                cell.contentView.hideSkeleton()
                                cell.collectionView.hideSkeleton()
                                
                                if self.adViewModel.ads.count == 0 {
                                    cell.constraintHeightTopSeperator.constant = 8
                                }
                                
                                cell.productViewModel.betterTogetherProducts = self.viewModel.betterTogetherProducts
                                cell.forSecondMovement = false
                                cell.key = .forBetterTogether
                                cell.setTitle(title: EthosConstants.BetterTogether.uppercased())
                                cell.delegate = self
                                
                                cell.didGetProducts(site : nil, CategoryId : nil)
                                return cell
                            }
                        } else {
                            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                                cell.setSpacing(height: 2 , color: .clear)
                                return cell
                            }
                        }
                    }
                }
                
                // Recent Products
                if indexPath.section == (arrSections.count + 6) {
                    if self.recentProducts.count > 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            
                            if self.viewModel.similarProducts.count != 0  {
                                cell.constraintHeightTopSeperator.constant = 8
                            } else if self.viewModel.similarProducts.count != 0 {
                                cell.constraintHeightTopSeperator.constant = 8
                            } else if self.adViewModel.ads.count == 0 {
                                cell.constraintHeightTopSeperator.constant = 8
                            }
                            
                            cell.forSecondMovement = false
                            cell.setTitle(title: EthosConstants.RecentlyViewed.uppercased())
                            cell.delegate = self
                            cell.productViewModel.products = self.recentProducts
                            cell.key = .forRecentProducts
                            cell.viewBtnViewAll.isHidden = true
                            cell.didGetProducts(site: nil, CategoryId: nil)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2 , color: .clear)
                            return cell
                        }
                    }
                }
            }
        }
        
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell is EthosVideoTableViewCell {
            (cell as? EthosVideoTableViewCell)?.playerLayer.player?.pause()
            (cell as? EthosVideoTableViewCell)?.btnPlayPause.isSelected = false
            (cell as? EthosVideoTableViewCell)?.btnPlayPause.isHidden = false
        }
        
        if cell is AdvertisementCell {
            (cell as? AdvertisementCell)?.playerLayer.player?.pause()
            (cell as? AdvertisementCell)?.btnPausePlay.isSelected = false
        }
        
        if cell is FavreLeubaHeaderTableViewCell {
            (cell as? FavreLeubaHeaderTableViewCell)?.playerLayer.player?.pause()
            (cell as? FavreLeubaHeaderTableViewCell)?.btnPlayPause.isSelected = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                if offsetY > 590 {
                    self.checkSellingPriceMainBackView.alpha = 1.0
                } else {
                    self.checkSellingPriceMainBackView.alpha = 0.0
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            if scrollView == self.tableViewProductDetails {
                for cell in tableViewProductDetails.visibleCells {
                    if cell is AdvertisementCell, UIApplication.topViewController() == self,
                       let index = tableViewProductDetails.indexPath(for: cell) {
                        let rectOfCell = self.tableViewProductDetails.rectForRow(at: index)
                        let rectOfCellInSuperview = self.tableViewProductDetails.convert(rectOfCell, to: self.tableViewProductDetails.superview)
                        if rectOfCellInSuperview.origin.y < cell.contentView.frame.height, rectOfCellInSuperview.origin.y > 0  {
                            (cell as? AdvertisementCell)?.playerLayer.player?.play()
                            (cell as? AdvertisementCell)?.btnPausePlay.isSelected = true
                        } else {
                            (cell as? AdvertisementCell)?.playerLayer.player?.pause()
                            (cell as? AdvertisementCell)?.btnPausePlay.isSelected = false
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.tableViewProductDetails {
            for cell in tableViewProductDetails.visibleCells {
                if cell is AdvertisementCell, UIApplication.topViewController() == self,
                   let index = tableViewProductDetails.indexPath(for: cell) {
                    let rectOfCell = self.tableViewProductDetails.rectForRow(at: index)
                    let rectOfCellInSuperview = self.tableViewProductDetails.convert(rectOfCell, to: self.tableViewProductDetails.superview)
                    if rectOfCellInSuperview.origin.y < cell.contentView.frame.height, rectOfCellInSuperview.origin.y > 0  {
                        (cell as? AdvertisementCell)?.playerLayer.player?.play()
                        (cell as? AdvertisementCell)?.btnPausePlay.isSelected = true
                    } else {
                        (cell as? AdvertisementCell)?.playerLayer.player?.pause()
                        (cell as? AdvertisementCell)?.btnPausePlay.isSelected = false
                    }
                }
            }
        }
    }
}

extension ProductDetailViewController : GetProductViewModelDelegate {
    func errorInGettingFilters() {
        
    }
    
    func didGetFilters() {
        
    }
    
    func didGetProducts(site : Site?, CategoryId : Int?) {
        self.loadingBetterTogether = false
    }
    
    func errorInGettingProducts(error: String) {
        self.loadingBetterTogether = false
    }
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
    
    func didGetProductDetails(details: Product) {
        self.loadingProduct = false
        DispatchQueue.main.async {
            if self.forStoryRoute {
                Mixpanel.mainInstance().trackWithLogs(
                    event: EthosConstants.EthosProductDiscovered,
                    properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.ProductTitle : self.story?.title,
                        EthosConstants.ProductName : details.name,
                        EthosConstants.SKU : details.sku,
                        EthosConstants.Price : details.extensionAttributes?.ethProdCustomeData?.price
                    ]
                )
            }
        }
    }
    
    func failedToGetProductDetails() {
        stopIndicator()
    }
}

extension ProductDetailViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        
        if info?[EthosKeys.key] as? EthosKeys == .routeToArticleList , let categoryName = info?[EthosKeys.categoryName] as? String {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                    vc.isForPreOwn = forSecondMovement
                }
                vc.key = .readListCategory
                vc.articleCategory = ArticlesCategory(id: 0, name: categoryName, categoryDescription: "", image: "")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys {
            if key == .openWebPage, let urlstr = info?[EthosKeys.url] as? String {
                UserActivityViewModel().getDataFromActivityUrl(url: urlstr)
            }
        }
        
        
        if info?[EthosKeys.key] as? EthosKeys == .reloadHeightOfTableView {
            self.tableViewProductDetails.beginUpdates()
            self.tableViewProductDetails.endUpdates()
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToArticleDetail,
           let  articleId = info?[EthosKeys.value] as? Int,
           let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                vc.isForPreOwned = forSecondMovement
            }
            vc.articleId = articleId
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToProductDetails,
           let product = info?[EthosKeys.value] as? Product {
            
            let forSecondMovement = (info?[EthosKeys.forSecondMovement] as? Bool) ?? false
            if forSecondMovement {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = product.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                    vc.sku = product.sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToProductDetails,
           let product = info?[EthosKeys.value] as? ProductLite {
            
            let forSecondMovement = (info?[EthosKeys.forSecondMovement] as? Bool) ?? false
            
            if forSecondMovement {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = product.sku
                    if let forStoryRoute = info?[EthosKeys.forStoryRoute] as? Bool {
                        vc.forStoryRoute = forStoryRoute
                        if let story = info?[EthosKeys.story] as? Banner {
                            vc.story = story
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                    vc.sku = product.sku
                    if let forStoryRoute = info?[EthosKeys.forStoryRoute] as? Bool {
                        vc.forStoryRoute = forStoryRoute
                        if let story = info?[EthosKeys.story] as? Banner {
                            vc.story = story
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToProducts,
           let categoryId = info?[EthosKeys.categoryId] as? Int,
           let categoryName = info?[EthosKeys.categoryName] as? String {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                    vc.isForPreOwned = forSecondMovement
                }
                vc.productViewModel.categoryName = categoryName
                vc.productViewModel.categoryId = categoryId
                
                if let filters = info?[EthosKeys.filters] as? [FilterModel] {
                    vc.productViewModel.selectedFilters = filters
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToSpecificProducts,
           let categoryName = info?[EthosKeys.categoryName] as? String {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: BetterTogetherViewController.self)) as? BetterTogetherViewController {
                if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                    vc.isForPreOwned = forSecondMovement
                }
                vc.categoryName = categoryName
                vc.sku = self.sku
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToProductDetails,
           let sku = info?[EthosKeys.value] as? String {
            let forSecondMovement = (info?[EthosKeys.forSecondMovement] as? Bool) ?? false
            if forSecondMovement {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                    vc.sku = sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        if let key = (info?[EthosKeys.key] as? EthosKeys), key == EthosKeys.checkOurSellingPrice,
           let product = info?[EthosKeys.Product] as? Product {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: CheckYourSellingPriceViewController.self)) as? CheckYourSellingPriceViewController {
                vc.product = product
                self.present(vc, animated: true)
            }
        }
    }
}
