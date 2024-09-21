//
//  DiscoverHeadingTableViewCell.swift
//  Ethos
//
//  Created by mac on 26/06/23.
//

import UIKit
import Mixpanel
import SkeletonView

class HorizontalCollectionTableViewCell: UITableViewCell  {
    
    @IBOutlet weak var btnViewAllDisclosureBtn: UIButton!
    @IBOutlet weak var txtBtnViewAll: UIButton!
    @IBOutlet weak var viewBtnViewAll: UIView!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var constraintHeightOfCollectionView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightBottomSeperator: NSLayoutConstraint!
    @IBOutlet weak var viewBottomSeperator: UIView!
    @IBOutlet weak var constraintHeightTopSeperator: NSLayoutConstraint!
    @IBOutlet weak var viewTopSeperator: UIView!
    @IBOutlet weak var constraintTopProgressView: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomProgressView: NSLayoutConstraint!
    
    var forSecondMovement : Bool = false
    var sku : String?
    var brand : String?
    
    var articleKey : ArticleCategory? {
        didSet {
            if let articleKey = articleKey {
                switch articleKey {
                    
                case .curatedList:
                    self.setTitle(title: EthosConstants.CuratedList.uppercased())
                    
                case .trending:
                    self.setTitle(title: EthosConstants.TrendingArticles.uppercased())
                    
                case .revolution:
                    self.setTitle(title: EthosConstants.RevolutionArticles.uppercased())
                    
                case .editorsPicks:
                    self.setTitle(title: EthosConstants.EditorsPicks.uppercased())
                    
                    
                case .featuredVideo:
                    break
                }
            }
            
        }
    }
    
    var key = HorizontalCollectionKey.forArticle {
        didSet {
            switch key {
            case .forReadList:
                self.viewBtnViewAll.isHidden = true
            case .forArticle: break
            case .forStore: break
            case .forPreOwnedPicks: break
            case .forstaffPicks:
                self.viewBtnViewAll.isHidden = true
                
            case .forSimilarWatches:
                self.viewBtnViewAll.isHidden = true
                self.collectionView.reloadData()
                self.updateProgressView()
            case .forBrandArticle:
                break
            case .forFeaturedWatches:
                self.productViewModel.initiate(id: forSecondMovement ? 22 : 115, limit: 8, selectedSortBy: EthosConstants.bestSeller){
                    self.productViewModel.getProductsFromCategory(site: self.forSecondMovement ? .secondMovement : .ethos)
                }
                
            case .forSecondMovementNewArrival: break

            case .forBetterTogether: self.viewBtnViewAll.isHidden = true
            case .forRecentProducts: self.viewBtnViewAll.isHidden = true
            case .forSMNewArrivalProductDetails: break
            case .forShopThisLook: self.viewBtnViewAll.isHidden = true
            }
            self.setUI()
        }
    }
    
    let articleViewModel = GetArticlesViewModel()
    let storeViewModel = GetStoreViewModel()
    var productViewModel = GetProductViewModel()
    let articleCategoriesViewModel = GetArticleCategoriesViewModel()
    var delegate : SuperViewDelegate?
    var constraintConstant: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDelegates()
        self.collectionView.isScrollEnabled = true
        self.btnViewAllDisclosureBtn.setImage(UIImage.imageWithName(name: EthosConstants.rightArrowEthos), for: .normal)
        self.txtBtnViewAll.setAttributedTitleWithProperties(title: EthosConstants.ViewAll.uppercased(), font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black ,kern: 0.5)
    }
    
    func setupDelegates() {
        self.collectionView.registerCell(className: HomeCollectionViewCell.self)
        self.collectionView.registerCell(className: ReadListCollectionViewCell.self)
        self.collectionView.registerCell(className: ProductCollectionViewCell.self)
        self.collectionView.registerCell(className: BrandImageCollectionViewCell.self)
        self.collectionView.registerCell(className: StoreCollectionViewCell.self)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.articleViewModel.delegate = self
        self.storeViewModel.delegate = self
        self.productViewModel.delegate = self
        self.articleCategoriesViewModel.delegate = self
    }
    
    let descendingText = "Z-A"
    let ascendingText = "A-Z"
    
    
    func setUI() {
        switch key {
        case .forReadList:
            constraintConstant = 380
        case .forArticle:
            constraintConstant = 450
        case .forStore:
            constraintConstant = 360
        case .forPreOwnedPicks:
            constraintConstant = 310
        case .forstaffPicks:
            constraintConstant = 310
        case .forSimilarWatches:
            constraintConstant = 310
        case .forBrandArticle:
            constraintConstant = 450
        case .forFeaturedWatches:
            constraintConstant = 310
        case .forSecondMovementNewArrival:
            constraintConstant = 310
        case .forBetterTogether:
            constraintConstant = 310
        case .forRecentProducts:
            if self.productViewModel.products.count == 0 {
                constraintConstant = 0
            } else {
                constraintConstant = 310
            }
        case .forSMNewArrivalProductDetails:
            constraintConstant = 310
        case .forShopThisLook:
            constraintConstant = 310
        }
        
        self.constraintHeightOfCollectionView.constant = constraintConstant
        self.updateProgressView()
    }
    
    override func prepareForReuse() {
        self.forSecondMovement = false
        self.collectionView.isPagingEnabled = false
        self.viewBtnViewAll.isHidden = false
        self.btnViewAllDisclosureBtn.setImage(UIImage.imageWithName(name: EthosConstants.rightArrowEthos), for: .normal)
        self.forSecondMovement = false
        self.txtBtnViewAll.setAttributedTitleWithProperties(title: EthosConstants.ViewAll.uppercased(), font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black ,kern: 0.5)
        self.collectionView.contentOffset = CGPoint.zero
        self.progressView.progress = 0
        self.articleKey = nil
        self.setTitle(title: "")
        self.articleViewModel.articles.removeAll()
        self.articleViewModel.advertisements.removeAll()
        self.productViewModel.products.removeAll()
        self.articleCategoriesViewModel.articleCategories.removeAll()
        self.collectionView.reloadData()
        self.contentView.backgroundColor = .white
        self.constraintHeightBottomSeperator.constant = 0
        self.constraintHeightTopSeperator.constant = 0
        self.progressView.isHidden = false
        self.constraintTopProgressView.constant = 24
        self.collectionView.isScrollEnabled = true
        self.productViewModel.limit = 20
        self.constraintBottomProgressView.constant = 40
        self.contentView.hideSkeleton()
        self.collectionView.hideSkeleton()
    }
    
    func updateProgressView() {
        DispatchQueue.main.async {
            let multiplier = (self.collectionView.contentOffset.x + self.collectionView.frame.width)/self.collectionView.contentSize.width
            if self.collectionView.numberOfItems(inSection: 0) < 3 {
                self.progressView.progressTintColor = EthosColor.appBGColor
                self.progressView.backgroundColor = EthosColor.appBGColor
            } else {
                self.progressView.progressTintColor = .black
                self.progressView.backgroundColor = EthosColor.appBGColor
            }
            self.progressView.progress = Float(multiplier)
            self.layoutIfNeeded()
        }
    }
    
    func setTitle(title : String) {
        labelHeading.setAttributedTitleWithProperties(
            title: title,
            font: EthosFont.Brother1816Medium(size: 12),
            kern: 1
        )
    }
    
    @IBAction func btnViewAllDidTapped(_ sender: UIButton) {
        switch key {
        case .forReadList:
            break
        case .forArticle:
            if let articleKey = self.articleKey {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleList, EthosKeys.value : self.key, EthosKeys.category : articleKey, EthosKeys.forSecondMovement : self.forSecondMovement])
            } else {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleList, EthosKeys.value : self.key, EthosKeys.forSecondMovement : self.forSecondMovement])
            }
        case .forStore:
            
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.visitOurBoutique, EthosKeys.forSecondMovement : self.forSecondMovement])
            
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.ShopThroughBoutiquesClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ]
            )
            
        case .forPreOwnedPicks:
            
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.PreOwnedPicksClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ]
            )
            
            self.delegate?.updateView(
                info: [
                    EthosKeys.key : EthosKeys.routeToProducts,
                    EthosKeys.categoryId : 3,
                    EthosKeys.forSecondMovement : true,
                    EthosKeys.categoryName : "All Watches"
                ]
            )
      
        case .forstaffPicks:
            
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.PreOwnedPicksClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ]
            )
            
            self.delegate?.updateView(
                info: [
                    EthosKeys.key : EthosKeys.routeToProducts,
                    EthosKeys.categoryId : 22,
                    EthosKeys.forSecondMovement : true,
                    EthosKeys.categoryName : EthosConstants.StaffPicks
                ]
            )
    
        case .forSimilarWatches:
            break
            
        case .forBrandArticle:
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleList , EthosKeys.categoryName : self.brand ?? "", EthosKeys.forSecondMovement : self.forSecondMovement ])
  
        case .forFeaturedWatches:
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : (forSecondMovement ? 22 : 115), EthosKeys.forSecondMovement : self.forSecondMovement, EthosKeys.categoryName : EthosConstants.FeaturedWathces])

            
        case .forSecondMovementNewArrival:
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : (forSecondMovement ? 6 : 144), EthosKeys.forSecondMovement : self.forSecondMovement, EthosKeys.categoryName : EthosConstants.NewArrivals])
            
       
            
        case .forBetterTogether:
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToSpecificProducts, EthosKeys.forBetterTogether : true, EthosKeys.forSecondMovement : self.forSecondMovement, EthosKeys.categoryName : EthosConstants.BetterTogether])
   
        case .forRecentProducts:
            break
        case .forSMNewArrivalProductDetails:
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToProducts, EthosKeys.categoryId : (forSecondMovement ? 6 : 144), EthosKeys.forSecondMovement : self.forSecondMovement, EthosKeys.categoryName : EthosConstants.NewArrivals])
      
        case .forShopThisLook:
            break
        }
        
    }
}

extension HorizontalCollectionTableViewCell : GetStoresViewModelDelegate {
    func didGetNewStores(stores: [Store]) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateProgressView()
        }
    }
    
    func didFailedToGetStores() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateProgressView()
        }
    }
    
    func didFailedToGetNewStores() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateProgressView()
        }
    }
    
    func didGetStores(stores: [StoreCity], forLatest: Bool) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateProgressView()
        }
    }
}

extension HorizontalCollectionTableViewCell : GetArticleCategoriesViewModelDelegate {
    func didGetArticleCategories(articleCategories: [ArticlesCategory]) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateProgressView()
        }
    }
}

extension HorizontalCollectionTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch key {
        case .forReadList:
            return articleCategoriesViewModel.articleCategories.count
        case .forArticle:
            return articleViewModel.articles.count >= 5 ? 5 : articleViewModel.articles.count
        case .forStore:
            return storeViewModel.newStores.count
        case .forPreOwnedPicks:
            return productViewModel.products.count
        case .forstaffPicks:
            return productViewModel.products.count
        case .forSimilarWatches:
            return productViewModel.similarProducts.count
        case .forBrandArticle:
            return articleViewModel.articles.count >= 5 ? 5 : articleViewModel.articles.count
        case .forFeaturedWatches:
            return productViewModel.products.count >= 8 ? 8 : productViewModel.products.count
        case .forSecondMovementNewArrival:
            return productViewModel.products.count >= 8 ? 8 : productViewModel.products.count
        case .forBetterTogether:
            return productViewModel.betterTogetherProducts.count
        case .forRecentProducts:
            return productViewModel.products.count >= 4 ? 4 : productViewModel.products.count
        case .forSMNewArrivalProductDetails:
            return productViewModel.products.count >= 8 ? 8 : productViewModel.products.count
        case .forShopThisLook:
            return productViewModel.products.count >= 8 ? 8 : productViewModel.products.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch key {
        case .forReadList:
            return 1
        case .forArticle:
            return 1
        case .forStore:
            return 1
        case .forPreOwnedPicks:
            return 1
        case .forstaffPicks:
            return 1
        case .forSimilarWatches:
            return 1
        case .forBrandArticle:
            return 1
        case .forFeaturedWatches:
            return 1
        case .forSecondMovementNewArrival:
            return 1
        case .forBetterTogether:
            return 1
        case .forRecentProducts:
            return 1
        case .forSMNewArrivalProductDetails:
            return 1
        case .forShopThisLook:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch key {
            
        case .forReadList:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ReadListCollectionViewCell.self), for: indexPath) as? ReadListCollectionViewCell {
                cell.articleCategory = articleCategoriesViewModel.articleCategories[indexPath.item]
                return cell
            }
            
        case .forArticle:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath) as? HomeCollectionViewCell {
                cell.article = articleViewModel.articles[indexPath.item]
                return cell
            }
            
        case .forStore:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: StoreCollectionViewCell.self), for: indexPath) as? StoreCollectionViewCell {
                cell.store = storeViewModel.newStores[indexPath.item]
                return cell
            }
            
        case .forPreOwnedPicks:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = self.forSecondMovement
                cell.product = productViewModel.products[indexPath.item]
                return cell
            }
            
        case .forstaffPicks:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = true
                cell.product = productViewModel.products[indexPath.item]
                return cell
            }
            
        case .forSimilarWatches:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = self.forSecondMovement
                cell.productLite = productViewModel.similarProducts[indexPath.item]
                return cell
            }
            
        case .forBrandArticle:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath) as? HomeCollectionViewCell {
                cell.article = articleViewModel.articles[indexPath.item]
                return cell
            }
            
        case .forFeaturedWatches:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = self.forSecondMovement
                cell.product = productViewModel.products[indexPath.item]
                return cell
            }
            
        case .forSecondMovementNewArrival:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = self.forSecondMovement
                cell.product = productViewModel.products[indexPath.item]
                return cell
            }
        case .forBetterTogether:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = self.forSecondMovement
                cell.productLite = productViewModel.betterTogetherProducts[indexPath.item]
                return cell
            }
        case .forRecentProducts:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = self.forSecondMovement
                cell.product = productViewModel.products[indexPath.item]
                return cell
            }
        case .forSMNewArrivalProductDetails:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = true
                cell.product = productViewModel.products[indexPath.item]
                return cell
            }
        case .forShopThisLook:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.isForPreOwned = self.forSecondMovement
                cell.product = productViewModel.products[indexPath.item]
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch key {
        case .forReadList:
            return CGSize(width: 310, height: constraintConstant)
            
        case .forArticle:
            return CGSize(width: 310, height: constraintConstant)
            
        case .forStore:
            return CGSize(width: 250, height: constraintConstant)
            
        case .forPreOwnedPicks:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: constraintConstant)
            
        case .forstaffPicks:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: constraintConstant)
            
        case .forSimilarWatches:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: constraintConstant)
        case .forBrandArticle:
            return CGSize(width: 300, height: constraintConstant)
        case .forFeaturedWatches:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: 310)
        case .forSecondMovementNewArrival:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: constraintConstant)
        case .forBetterTogether:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: 310)
        case .forRecentProducts:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: 310)
        case .forSMNewArrivalProductDetails:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: 310)
        case .forShopThisLook:
            return collectionView.cellSize(noOfCellsInRow: 2.5, Height: 310)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch key {
            
        case .forReadList :
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ReadListCollectionViewCell {
                if let category = cell.articleCategory {
                    self.delegate?.updateView(
                        info: [
                            EthosKeys.key : EthosKeys.routeToArticleList,
                            EthosKeys.value : self.key,
                            EthosKeys.category : category,
                            EthosKeys.forSecondMovement : self.forSecondMovement
                        ]
                    )
                }
            }
            
        case .forArticle :
            if let id = articleViewModel.articles[indexPath.item].id {
                
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ArticleClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ArticleID : self.articleViewModel.articles[indexPath.item].id,
                    EthosConstants.ArticleTitle : self.articleViewModel.articles[indexPath.item].title,
                    EthosConstants.ArticleCategory : self.articleViewModel.articles[indexPath.item].category
                ])
                self.delegate?.updateView (
                    info: [
                        EthosKeys.key : EthosKeys.routeToArticleDetail,
                        EthosKeys.value : id
                    ]
                )
            }
            
        case .forstaffPicks :
            
            Mixpanel.mainInstance().trackWithLogs(
                event: "Pre Owned Picks Product Clicked",
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.SKU : productViewModel.products[indexPath.item].sku,
                EthosConstants.ProductName : productViewModel.products[indexPath.item].name,
                EthosConstants.Price : productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.price
            ]
            )
            
            self.delegate?.updateView (
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.products[indexPath.item],
                    EthosKeys.forSecondMovement : self.forSecondMovement
                ]
            )
            
        case .forPreOwnedPicks :
            
            Mixpanel.mainInstance().trackWithLogs(
                event: "Pre Owned Picks Product Clicked",
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ProductSKU : productViewModel.products[indexPath.item].sku,
                EthosConstants.ProductName : productViewModel.products[indexPath.item].name
            ]
            )
            
            self.delegate?.updateView (
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.products[indexPath.item],
                    EthosKeys.forSecondMovement : self.forSecondMovement
                ]
            )
            
        case .forFeaturedWatches :
            
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.ProductClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ProductSKU : productViewModel.products[indexPath.item].sku,
                EthosConstants.ProductType : productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.brand,
                EthosConstants.ProductName : productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.productName,
                EthosConstants.SKU : productViewModel.products[indexPath.item].sku,
                EthosConstants.Price : productViewModel.products[indexPath.item].price,
                EthosConstants.ShopType : EthosConstants.Ethos,
                EthosConstants.ProductSubCategory :  EthosConstants.FeaturedWathces
            ]
            )
            
            self.delegate?.updateView (
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.products[indexPath.item],
                    EthosKeys.forSecondMovement : self.forSecondMovement
                ]
            )
        
        case .forSecondMovementNewArrival : 
         
            self.delegate?.updateView (
            info: [
                EthosKeys.key : EthosKeys.routeToProductDetails,
                EthosKeys.value : productViewModel.products[indexPath.item],
                EthosKeys.forSecondMovement : self.forSecondMovement
            ]
        )
            
        case .forSimilarWatches :
            
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.ProductClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ProductSKU : productViewModel.similarProducts[indexPath.item].sku,
                EthosConstants.ProductType : productViewModel.similarProducts[indexPath.item].brand,
                EthosConstants.ProductName : (productViewModel.similarProducts[indexPath.item].brand ?? "") + " " + (productViewModel.similarProducts[indexPath.item].collection ?? ""),
                EthosConstants.SKU : productViewModel.similarProducts[indexPath.item].sku,
                EthosConstants.Price : productViewModel.similarProducts[indexPath.item].price,
                EthosConstants.ShopType : EthosConstants.Ethos,
                EthosConstants.ProductSubCategory :  "Similar Products"
            ]
            )
            
            self.delegate?.updateView(
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.similarProducts[indexPath.item],
                    EthosKeys.forSecondMovement : self.forSecondMovement
                ])
            
        case .forStore:
             let store = self.storeViewModel.newStores[indexPath.item]
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToStore, EthosKeys.value : store])
            
        case .forBrandArticle:
            if let id = articleViewModel.articles[indexPath.item].id {
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ArticleClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ArticleID : self.articleViewModel.articles[indexPath.item].id,
                    EthosConstants.ArticleTitle : self.articleViewModel.articles[indexPath.item].title,
                    EthosConstants.ArticleCategory : self.articleViewModel.articles[indexPath.item].category
                ]
                )
                
                self.delegate?.updateView (
                    info: [
                        EthosKeys.key : EthosKeys.routeToArticleDetail,
                        EthosKeys.value : id,
                        EthosKeys.forSecondMovement : self.forSecondMovement
                    ]
                )
            }
        case .forBetterTogether:
      
            let productName : String = (productViewModel.betterTogetherProducts[indexPath.item].brand ?? "") + " " + (productViewModel.betterTogetherProducts[indexPath.item].collection ?? "")
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.ProductClicked,
                properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ProductSKU : productViewModel.betterTogetherProducts[indexPath.item].sku,
                EthosConstants.ProductType : productViewModel.betterTogetherProducts[indexPath.item].brand,
                EthosConstants.ProductName : productName,
                EthosConstants.SKU : productViewModel.betterTogetherProducts[indexPath.item].sku,
                EthosConstants.Price : productViewModel.betterTogetherProducts[indexPath.item].price,
                EthosConstants.ShopType : EthosConstants.Ethos,
                EthosConstants.ProductSubCategory :  EthosConstants.BetterTogether
            ]
            )
            
            self.delegate?.updateView (
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.betterTogetherProducts[indexPath.item],
                    EthosKeys.forSecondMovement : self.forSecondMovement
                ]
            )
        case .forRecentProducts:
            
            if !self.forSecondMovement {
                Mixpanel.mainInstance().trackWithLogs(
                    event: EthosConstants.ProductClicked,
                    properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ProductSKU : productViewModel.products[indexPath.item].sku,
                    EthosConstants.ProductType : productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.brand,
                    EthosConstants.ProductName : productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.productName,
                    EthosConstants.SKU : productViewModel.products[indexPath.item].sku,
                    EthosConstants.Price : productViewModel.products[indexPath.item].price,
                    EthosConstants.ShopType : EthosConstants.Ethos,
                    EthosConstants.ProductSubCategory :  EthosConstants.RecentProducts
                ]
                )
            }
            
            self.delegate?.updateView (
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.products[indexPath.item],
                    EthosKeys.forSecondMovement : productViewModel.products[indexPath.item].forPreOwned
                ]
            )
        case .forSMNewArrivalProductDetails:
            
            self.delegate?.updateView (
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.products[indexPath.item],
                    EthosKeys.forSecondMovement : true
                ]
            )
        case .forShopThisLook:
            self.delegate?.updateView (
                info: [
                    EthosKeys.key : EthosKeys.routeToProductDetails,
                    EthosKeys.value : productViewModel.products[indexPath.item],
                    EthosKeys.forSecondMovement : true
                ]
            )
        }
    }
}

extension HorizontalCollectionTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            let multiplier = (scrollView.contentOffset.x + scrollView.frame.width)/scrollView.contentSize.width
            self.progressView.progress = Float(multiplier)
        }
    }
}

extension HorizontalCollectionTableViewCell : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        collectionView.reloadData()
        updateProgressView()
    }
    
    func errorInGettingArticles(error: String) {
        printContent(error)
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.collectionView.showAnimatedGradientSkeleton()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.collectionView.hideSkeleton()
        }
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
}

extension HorizontalCollectionTableViewCell : GetProductViewModelDelegate {
    
    func errorInGettingFilters() {
        
    }
    
    
    func didGetFilters() {
        
    }
    
    func didGetProductDetails(details: Product) {
        
    }
    
    func failedToGetProductDetails() {
        
    }
    
    func errorInGettingProducts(error: String) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateProgressView()
        }
    }
    
    func didGetProducts(site : Site?, CategoryId : Int?) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateProgressView()
        }
    }
}

extension HorizontalCollectionTableViewCell : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        switch key {
        case .forReadList:
            return String(describing: ReadListCollectionViewCell.self)
        case .forFeaturedWatches:
            return String(describing: FeaturedVideoCollectionViewCell.self)
        case .forArticle:
            return String(describing: HomeCollectionViewCell.self)
        case .forStore:
            return String(describing: StoreCollectionViewCell.self)
        case .forPreOwnedPicks:
            return String(describing: ProductCollectionViewCell.self)
        case .forstaffPicks:
            return String(describing: ProductCollectionViewCell.self)
        case .forSimilarWatches:
            return String(describing: ProductCollectionViewCell.self)
        case .forBrandArticle:
            return String(describing: HomeCollectionViewCell.self)
        case .forSecondMovementNewArrival:
            return String(describing: ProductCollectionViewCell.self)
        case .forBetterTogether:
            return String(describing: ProductCollectionViewCell.self)
        case .forRecentProducts:
            return String(describing: ProductCollectionViewCell.self)
        case .forSMNewArrivalProductDetails:
            return String(describing: ProductCollectionViewCell.self)
        case .forShopThisLook:
            return String(describing: ProductCollectionViewCell.self)
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        
        switch key {
            
        case .forReadList:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ReadListCollectionViewCell.self), for: indexPath) as? ReadListCollectionViewCell {
                cell.contentView.showAnimatedGradientSkeleton()
                return cell
            }
            
        case .forArticle:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath) as? HomeCollectionViewCell {
                cell.contentView.showAnimatedGradientSkeleton()
                return cell
            }
            
        case .forStore:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: StoreCollectionViewCell.self), for: indexPath) as? StoreCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
            
        case .forPreOwnedPicks:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
            
        case .forstaffPicks:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
            
        case .forSimilarWatches:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
            
        case .forBrandArticle:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath) as? HomeCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
            
        case .forFeaturedWatches:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
            
        case .forSecondMovementNewArrival:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
        case .forBetterTogether:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
        case .forRecentProducts:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
        case .forSMNewArrivalProductDetails:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
        case .forShopThisLook:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showGradientSkeleton()
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
}
