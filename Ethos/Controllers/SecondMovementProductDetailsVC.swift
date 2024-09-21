//
//  SecondMovementProductDetailsVC.swift
//  Ethos
//
//  Created by mac on 14/09/23.
//

import UIKit
import SafariServices
import Mixpanel
import SkeletonView

class SecondMovementProductDetailsVC: UIViewController {
    
    @IBOutlet weak var constraintCenterBlackTriangle: NSLayoutConstraint!
    @IBOutlet weak var textViewWarrantyDescription: UITextView!
    @IBOutlet weak var viewWarrantyDescription: UIView!
    @IBOutlet weak var imgBlackTriangle: UIImageView!
    @IBOutlet weak var viewTrasnsParent: UIView!
    @IBOutlet weak var tableViewProductDetails: EthosContentSizedTableView!
    
    @IBOutlet weak var constraintTopBlackTriangle: NSLayoutConstraint!
    
    var arrSections : [(String, Bool)] = []
    var attributes = [AttributeDescription]()
    var attributedStrArr = [(NSAttributedString, NSAttributedString)]()
    var viewModel = GetProductViewModel()
    var forStoryRoute : Bool = false

    var loadingProduct : Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.setUI()
            }
        }
    }
    
    var story : Banner?
    
    var loadingNewArrivals : Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.tableViewProductDetails.reloadData()
            }
        }
    }
    
    var sku : String?
    var video : String?
    var recentProducts = [Product]()
    let refreshControl = UIRefreshControl()
    var noWarrantyText = "No warranty is provided or implied due to the absence of official authorisation or an authorised service centre within the country. Second Movement owns no official authorisation for this brand, therefore, this product comes with no warranty, either expressed or implied."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.callApi()
            
        }
    }
    
    func callApi() {
        self.loadingProduct = true
        self.loadingNewArrivals = true
        if let sku = self.sku {
            DispatchQueue.main.async {
                self.fetchRecentProductsFromDataBase(sku: sku) {
                    self.viewModel.getProductDetails(sku: sku, site: .secondMovement)
                    self.viewModel.initiate(id: 6, limit: 8, selectedSortBy: EthosConstants.NewArrivals.uppercased()) {
                        self.viewModel.getProductsFromCategory(site: .secondMovement)
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for index in tableViewProductDetails.indexPathsForVisibleRows ?? [] {
            if let cell = tableViewProductDetails.cellForRow(at: index) as? AdvertisementCell {
                cell.btnPausePlay.isSelected = false
                cell.playerLayer.player?.pause()
            }
            
            if let cell = tableViewProductDetails.cellForRow(at: index) as? FavreLeubaHeaderTableViewCell {
                cell.btnPlayPause.isSelected = false
                cell.playerLayer.player?.pause()
            }
            
            if let cell = tableViewProductDetails.cellForRow(at: index) as? SecondMovementVideoTableViewCell {
                cell.btnPlayPause.isSelected = false
                cell.playerLayer.player?.pause()
                cell.btnPlayPause.isHidden = false
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
                    if product.sku != sku, product.preowned == true {
                        let pro = Product()
                        pro.sku = product.sku
                        pro.name = product.name
                        pro.assets = [ProductAsset(id: 0, mediaType: "image", position: 0, disabled: false, types: [], file: product.thumbnailImage)]
                        pro.movement = [EthosConstants.brand : product.brand ?? ""]
                        pro.price = Int(product.price)
                        pro.currency = product.currency
                        
                        let imagedata = ProductImageData(
                            catalogImage: product.thumbnailImage,
                            gallery: [
                                ProductImage(
                                    image: product.thumbnailImage,
                                    order: 0
                                )
                            ] )
                        
                        pro.extensionAttributes = ExtensionAttributes(
                            categoryLinks: [
                                CategoryLink(
                                    position: 0,
                                    categoryID: String(
                                        product.categoryId
                                    )
                                )], ethProdCustomeData: EthProdCustomeData(sku: product.sku, brand: product.brand ,collection: product.collectionName, productName: product.name, images: imagedata, hidePrice: product.hidePrice, price: Int(product.customPrice)))
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
        self.callApi()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.tableViewProductDetails.refreshControl?.endRefreshing()
        }
    }
    
    @objc override func onTap() {
        self.view.endEditing(true)
        for cell in self.tableViewProductDetails.visibleCells {
            if cell is SecondMovementMainDesctionTableViewCell {
                (cell as? SecondMovementMainDesctionTableViewCell)?.tableViewDescription.isHidden = true
                (cell as? SecondMovementMainDesctionTableViewCell)?.imageTriangle.isHidden = true
            }
        }
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        self.tableViewProductDetails.registerCell(className: SpecificationPairTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: SingleCollectionTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: MovementTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: AdvertisementCell.self)
        self.tableViewProductDetails.registerCell(className: HeadingCell.self)
        self.tableViewProductDetails.registerCell(className: SecondMovementVideoTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: HtmlContainerForAboutCollectionTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: HtmlContainerForAboutCollectionPreOwnedTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: HorizontalCollectionTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: SpacingTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: FavreLeubaHeaderTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: CornerCutImageTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: ProductDetailTableViewCell.self)
        self.tableViewProductDetails.registerCell(className: SecondMovementMainDesctionTableViewCell.self)
        self.viewModel.delegate = self
        self.addRefreshControl()
        self.textViewWarrantyDescription.setAttributedTitleWithProperties(title: self.noWarrantyText, font: EthosFont.Brother1816Regular(size: 10),foregroundColor: UIColor.white, lineHeightMultiple: 1.25, kern: 0.5)
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnShareDidTapped(_ sender: UIButton) {
        guard let product = viewModel.product else {
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [ self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.url ?? "https://www.ethoswatches.com/"], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {
            type, complete, res, error in
            if complete {
                Mixpanel.mainInstance().trackWithLogs(
                    event: EthosConstants.ProductShared,
                    properties: [
                        EthosConstants.Email : Userpreference.email ?? "",
                        EthosConstants.UID : Userpreference.userID ?? "",
                        EthosConstants.Gender : Userpreference.gender ?? "",
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.Registered : (Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y,
                        EthosConstants.ProductName : product.name ?? "",
                        EthosConstants.SKU : product.sku ?? "",
                        EthosConstants.Price : product.price,
                        EthosConstants.ProductType : product.extensionAttributes?.ethProdCustomeData?.brand,
                        EthosConstants.SharedVia : type?.rawValue
                    ]
                )
            }
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func deleteExtraProducts(product : Product) {
        DataBaseModel().fetchRecentProducts { recentProducts in
            
            let products = recentProducts.filter { product in
                (product.preowned) == true
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
                DataBaseModel().saveRecentProduct(product: product, forPreOwn: true) {
                    self.deleteExtraProducts(product: product)
                    
                }
            } else {
                DataBaseModel().updateDateOfExistingProduct(product: product) {
                    self.deleteExtraProducts(product: product)
                }
            }
        }
    }
    
    func showHideWarrantyView(hide : Bool) {
        if !hide {
            for cell in tableViewProductDetails.visibleCells {
                if cell is SpecificationPairTableViewCell {
                    if let str = (cell as? SpecificationPairTableViewCell)?.attribute?.0?.string, str.lowercased().contains(EthosConstants.warrantyperiod), let indexPath = (cell as? SpecificationPairTableViewCell)?.indexPath {
                        let cellRect = self.tableViewProductDetails.convert(self.tableViewProductDetails.rectForRow(at: indexPath), to: self.viewTrasnsParent)
                        let extraSpacing = (cell as? SpecificationPairTableViewCell)?.textView1.frame.maxY
                        self.constraintTopBlackTriangle.constant = cellRect.minY + (extraSpacing ?? 0)
                        let pos1 = (cell as? SpecificationPairTableViewCell)?.textView1.position(from: (cell as? SpecificationPairTableViewCell)?.textView1?.endOfDocument ?? UITextPosition(), offset: 0) ?? UITextPosition()
                        let pos2 = (cell as? SpecificationPairTableViewCell)?.textView1.position(from: (cell as? SpecificationPairTableViewCell)?.textView1?.endOfDocument ?? UITextPosition(), offset: -1) ?? UITextPosition()
                        let range = (cell as? SpecificationPairTableViewCell)?.textView1.textRange(from: pos1, to: pos2) ?? UITextRange()
                        let result = (cell as? SpecificationPairTableViewCell)?.textView1.firstRect(for: range)
                        self.constraintCenterBlackTriangle.constant = (result?.midX ?? 0) - 10
                        self.view.layoutIfNeeded()
                    } else if let str = (cell as? SpecificationPairTableViewCell)?.attribute?.2?.string, str.lowercased().contains(EthosConstants.warrantyperiod) , let indexPath = (cell as? SpecificationPairTableViewCell)?.indexPath {
                        let cellRect = self.tableViewProductDetails.convert(self.tableViewProductDetails.rectForRow(at: indexPath), to: self.viewTrasnsParent)
                        let extraSpacing = (cell as? SpecificationPairTableViewCell)?.textView3.frame.maxY
                        self.constraintTopBlackTriangle.constant = cellRect.minY + (extraSpacing ?? 0)
                        let pos1 = (cell as? SpecificationPairTableViewCell)?.textView3.position(from: (cell as? SpecificationPairTableViewCell)?.textView3?.endOfDocument ?? UITextPosition(), offset: 0) ?? UITextPosition()
                        let pos2 = (cell as? SpecificationPairTableViewCell)?.textView3.position(from: (cell as? SpecificationPairTableViewCell)?.textView3?.endOfDocument ?? UITextPosition(), offset: -1) ?? UITextPosition()
                        let range = (cell as? SpecificationPairTableViewCell)?.textView3.textRange(from: pos1, to: pos2) ?? UITextRange()
                        let result = (cell as? SpecificationPairTableViewCell)?.textView3.firstRect(for: range)
                        let minX = (cell as? SpecificationPairTableViewCell)?.textView3.frame.minX ?? 0
                        self.constraintCenterBlackTriangle.constant = minX + (result?.midX ?? 0) - 40
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.viewTrasnsParent.isHidden = hide
            self.textViewWarrantyDescription.isHidden = hide
            self.imgBlackTriangle.isHidden = hide
            self.viewWarrantyDescription.isHidden = hide
        }
    }
    
    func setUI() {
        guard let product = self.viewModel.product else {
            return
        }
        addRecentProduct(product: product)
        self.arrSections.removeAll()
        if product.extensionAttributes?.ethProdCustomeData?.showVideo == true {
            var videoUrl : String?
            
            if let productVideo = product.extensionAttributes?.ethProdCustomeData?.productVideo,
               productVideo != "", productVideo != EthosConstants.novideo {
                videoUrl = productVideo
            } else if let video = product.video, video != "", video != EthosConstants.novideo {
                videoUrl = video
            } else if let collectionVideo = product.extensionAttributes?.ethProdCustomeData?.collectionVideo,  collectionVideo != "", collectionVideo != EthosConstants.novideo {
                videoUrl = collectionVideo
            } else if let seriesVideo = product.extensionAttributes?.ethProdCustomeData?.seriesVideo,  seriesVideo != "", seriesVideo != EthosConstants.novideo {
                videoUrl = seriesVideo
            }
            
            if let finalVideo = videoUrl?.replacingOccurrences(of: "\r\n", with: "")  {
                self.video = finalVideo
                self.arrSections.append(((EthosConstants.Video), false))
            }
        }
        
        if product.aboutCollection?.htmlToString != nil && product.aboutCollection?.htmlToString != "" {
            self.arrSections.append((EthosConstants.AboutTheProduct,false))
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
                a.displayName?.lowercased() ?? "a" < b.displayName?.lowercased() ?? "a"
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
                    
                    if attribute.displayName?.lowercased() == EthosConstants.warrantyperiod && attribute.value?.displayName == "Not Applicable"
                    {
                        let imageAttachment = NSTextAttachment()
                        imageAttachment.image = UIImage(named:EthosConstants.questionMark)
                        imageAttachment.bounds = CGRect(x: 0, y: -3, width: 12, height: 12)
                        let attachmentString = NSMutableAttributedString(attachment: imageAttachment)
                        
                        attachmentString.addAttributes([.foregroundColor : EthosColor.red, .link : EthosIdentifiers.warrantyURI, .font : EthosFont.Brother1816Regular(size: 12)], range: (attachmentString.string as NSString).range(of: attachmentString.string))
                        
                        titleStr?.append(NSAttributedString(string: "  "))
                        titleStr?.append(attachmentString)
                    }
                    
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
        
        DispatchQueue.main.async {
            self.tableViewProductDetails.reloadData()
        }
    }
    
    @IBAction func hideTransparentView(_ sender: UIButton) {
        self.showHideWarrantyView(hide: true)
    }
}

extension SecondMovementProductDetailsVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.loadingProduct {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section == 2 {
                return 3
            } else {
                return 1
            }
        } else {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section < arrSections.count + 2 {
                if arrSections[section - 2].1 == true {
                    return 0
                } else {
                    if arrSections[section - 2].0 == EthosConstants.FullSpecification {
                        if self.attributedStrArr.count%2 == 0 {
                            return self.attributedStrArr.count/2
                        } else {
                            return self.attributedStrArr.count/2 + 1
                        }
                    } else {
                        return 1
                    }
                }
            } else {
                return 1
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.loadingProduct {
            return 5
        } else {
            return 2 + self.arrSections.count + 2
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.loadingProduct {
            if section == 0 {
                return nil
            } else if section == 1 {
                return nil
            } else if section == 2 {
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
            } else if section < (arrSections.count + 2) {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    cell.setHeading(
                        title: arrSections[section - 2].0.uppercased(),
                        leading: 30,
                        trailling: 30,
                        showDisclosure: true,
                        isSelected: self.arrSections[section - 2].1,
                        disclosureImageDefault: UIImage(named: EthosConstants.upArrow),
                        disclosureImageSelected: UIImage(named: EthosConstants.downArrow),
                        disclosureHeight: 16,
                        disclosureWidth: 16,
                        showTopLine: true,
                        
                        action: {
                            self.arrSections[section - 2].1 = !self.arrSections[section - 2].1
                            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)), cell is SecondMovementVideoTableViewCell {
                                (cell as? SecondMovementVideoTableViewCell)?.playerLayer.player?.pause()
                                (cell as? SecondMovementVideoTableViewCell)?.btnPlayPause.isSelected = false
                                (cell as? SecondMovementVideoTableViewCell)?.btnPlayPause.isHidden = false
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
            if section == 2 {
                return 70
            } else {
                return 1
            }
        } else {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section >= arrSections.count + 2 {
                return 1
            } else {
                return 70
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SecondMovementMainDesctionTableViewCell.self), for: indexPath) as? SecondMovementMainDesctionTableViewCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else if indexPath.section == 2 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpecificationPairTableViewCell.self), for: indexPath) as? SpecificationPairTableViewCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else if indexPath.section == 3 {
                if self.loadingNewArrivals {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.JustIn.uppercased())
                        cell.key = .forSMNewArrivalProductDetails
                        cell.delegate = self
                        
                        cell.constraintHeightTopSeperator.constant = 8
                        cell.constraintTopProgressView.constant = 0
                        
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if self.viewModel.products.count > 0 {
                        
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            cell.hideSkeleton()
                            cell.forSecondMovement = true
                            cell.setTitle(title: EthosConstants.JustIn.uppercased())
                            cell.key = .forSMNewArrivalProductDetails
                            cell.delegate = self
                            cell.productViewModel.products = self.viewModel.products
                            cell.didGetProducts(site: nil, CategoryId: nil)
                            cell.constraintHeightTopSeperator.constant = 8
                            cell.constraintTopProgressView.constant = 0
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2,color: .clear)
                            return cell
                        }
                    }
                }
            } else {
                
                if self.recentProducts.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.RecentlyViewed.uppercased())
                        cell.productViewModel.products = self.recentProducts
                        cell.key = .forRecentProducts
                        cell.delegate = self
                        cell.didGetProducts(site: nil, CategoryId: nil)
                        cell.constraintHeightTopSeperator.constant = 8
                        cell.constraintTopProgressView.constant = 0
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2,color: .clear)
                        return cell
                    }
                }
            }
        } else {
            if indexPath.section == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductDetailTableViewCell.self), for: indexPath) as? ProductDetailTableViewCell {
                    cell.isForPreOwned = true
                    cell.contentView.hideSkeleton()
                    cell.collectionViewProductImage.hideSkeleton()
                    cell.index = indexPath
                    cell.superTableView = self.tableViewProductDetails
                    cell.superViewController = self
                    cell.delegate = self
                    if let product = self.viewModel.product {
                        cell.product = product
                    }
                    return cell
                }
            } else if indexPath.section == 1 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SecondMovementMainDesctionTableViewCell.self), for: indexPath) as? SecondMovementMainDesctionTableViewCell {
                    cell.contentView.hideSkeleton()
                    if let product = self.viewModel.product {
                        cell.product = product
                    }
                    return cell
                }
            } else if indexPath.section < (arrSections.count + 2) {
                // Specifications
                if arrSections[indexPath.section - 2].0 == EthosConstants.FullSpecification {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpecificationPairTableViewCell.self), for: indexPath) as? SpecificationPairTableViewCell {
                        cell.hideSkeleton()
                        cell.indexPath = indexPath
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
                        cell.textView1.delegate = self
                        cell.textView2.delegate = self
                        cell.textView3.delegate = self
                        cell.textView4.delegate = self
                        cell.layoutSubviews()
                        
                        return cell
                    }
                }
                
                // Video
                if arrSections[indexPath.section - 2].0 == EthosConstants.Video {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SecondMovementVideoTableViewCell.self), for: indexPath) as? SecondMovementVideoTableViewCell {
                        if let video = self.video, video != "" {
                            cell.brand = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.brand ?? ""
                            cell.videoUrl = video
                        }
                        cell.product = self.viewModel.product
                        return cell
                    }
                }
                
                // About collection
                if arrSections[indexPath.section - 2].0 == EthosConstants.AboutTheProduct {
//                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HtmlContainerForAboutCollectionTableViewCell.self), for: indexPath) as? HtmlContainerForAboutCollectionTableViewCell {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HtmlContainerForAboutCollectionPreOwnedTableViewCell.self), for: indexPath) as? HtmlContainerForAboutCollectionPreOwnedTableViewCell {
                        cell.delegate = self
                        cell.index = indexPath
                        cell.superTableView = self.tableViewProductDetails
                        if let html = self.viewModel.product?.aboutCollection {
                            
                            let imageCount = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.images?.gallery.count ?? 0
                            
                            if imageCount > 2, let image = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.images?.gallery[safe : 2]?.image  {
                                let htmlString = html
                                cell.data = (image, htmlString)
                            } else if imageCount > 1 , let image = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.images?.gallery[safe : 1]?.image {
                                let htmlString = html
                                cell.data = (image, htmlString)
                            } else if imageCount > 0 , let image = self.viewModel.product?.extensionAttributes?.ethProdCustomeData?.images?.gallery.first?.image {
                                let htmlString = html
                                cell.data = (image, htmlString)
                            } else {
                                cell.htmlString = html
                            }
                            
                        }
                        return cell
                    }
                }
                
            } else if indexPath.section == (arrSections.count + 2) {
                if self.loadingNewArrivals {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.JustIn.uppercased())
                        cell.key = .forSMNewArrivalProductDetails
                        cell.delegate = self
                        
                        cell.constraintHeightTopSeperator.constant = 8
                        cell.constraintTopProgressView.constant = 0
                        
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if self.viewModel.products.count > 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            cell.contentView.hideSkeleton()
                            cell.collectionView.hideSkeleton()
                            cell.forSecondMovement = true
                            cell.setTitle(title: EthosConstants.JustIn.uppercased())
                            cell.key = .forSMNewArrivalProductDetails
                            cell.delegate = self
                            cell.productViewModel.products = self.viewModel.products
                            cell.didGetProducts(site: nil, CategoryId: nil)
                            cell.constraintHeightTopSeperator.constant = 8
                            cell.constraintTopProgressView.constant = 0
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2,color: .clear)
                            return cell
                        }
                    }
                }
            } else {
                
                if self.recentProducts.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.RecentlyViewed.uppercased())
                        cell.productViewModel.products = self.recentProducts
                        cell.key = .forRecentProducts
                        cell.delegate = self
                        cell.didGetProducts(site: nil, CategoryId: nil)
                        cell.constraintHeightTopSeperator.constant = 8
                        cell.constraintTopProgressView.constant = 0
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2,color: .clear)
                        return cell
                    }
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is SecondMovementVideoTableViewCell {
            (cell as? SecondMovementVideoTableViewCell)?.playerLayer.player?.pause()
            (cell as? SecondMovementVideoTableViewCell)?.btnPlayPause.isSelected = false
            (cell as? SecondMovementVideoTableViewCell)?.btnPlayPause.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SecondMovementMainDesctionTableViewCell {
            cell.tableViewDescription.isHidden = true
            cell.imageTriangle.isHidden = true
        }
    }
}

extension SecondMovementProductDetailsVC : GetProductViewModelDelegate {
    func errorInGettingFilters() {
        
    }
    
    func didGetFilters() {
        
    }
    
    func didGetProducts(site : Site?, CategoryId : Int?) {
        self.loadingNewArrivals = false
    }
    
    func errorInGettingProducts(error: String) {
        self.loadingNewArrivals = false
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
        if self.forStoryRoute {
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.PreOwnedProductDiscovered,
                properties: [
                    EthosConstants.Email: Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ProductTitle : self.story?.title,
                    EthosConstants.ProductName : details.extensionAttributes?.ethProdCustomeData?.productName,
                    EthosConstants.SKU : details.sku,
                    EthosConstants.Price : details.extensionAttributes?.ethProdCustomeData?.price
                ]
            )
        }
    }
    
    func failedToGetProductDetails() {
        stopIndicator()
    }
}

extension SecondMovementProductDetailsVC : SuperViewDelegate {
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
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToProducts,
           let categoryId = info?[EthosKeys.categoryId] as? Int,
           let categoryName = info?[EthosKeys.categoryName] as? String {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool
                vc.isForPreOwned = forSecondMovement ?? false
                
                vc.productViewModel.categoryName = categoryName
                vc.productViewModel.categoryId = categoryId
                
                if forSecondMovement == true && categoryId == 6 {
                    vc.productViewModel.selectedSortBy = EthosConstants.NewArrivals.uppercased()
                }
                
                if let filters = info?[EthosKeys.filters] as? [FilterModel] {
                    vc.productViewModel.selectedFilters = filters
                }
                
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
        
        if let key = (info?[EthosKeys.key] as? EthosKeys), key == EthosKeys.checkOurSellingPrice,
           let product = info?[EthosKeys.Product] as? Product {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: CheckYourSellingPriceViewController.self)) as? CheckYourSellingPriceViewController {
                vc.product = product
                vc.isForPreOwned = true
                self.present(vc, animated: true)
            }
        }
        
        if let key = (info?[EthosKeys.key] as? EthosKeys), key == EthosKeys.showWarrantyPopup {
            
        }
    }
}

extension SecondMovementProductDetailsVC : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.scheme == EthosConstants.warranty {
            showHideWarrantyView(hide: false)
        }
        return true
    }
}


