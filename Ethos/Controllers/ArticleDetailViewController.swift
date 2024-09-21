//
//  ArticleDetailViewController.swift
//  Ethos
//
//  Created by mac on 11/08/23.
//

import UIKit
import SafariServices
import WebKit
import Mixpanel
import SkeletonView

class ArticleDetailViewController: UIViewController {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var scrollViewMain: UIScrollView!
    @IBOutlet weak var btnViewAllTrendingArticles: UIButton!
    @IBOutlet weak var btnViewAllFeaturedWatches: UIButton!
    @IBOutlet weak var txtBtnViewAllTrendingArticles: UIButton!
    @IBOutlet weak var txtBtnViewAllFeaturedWatches: UIButton!
    @IBOutlet weak var progressViewTrendingArticles: UIProgressView!
    @IBOutlet weak var collectionViewShopThisLook: UICollectionView!
    @IBOutlet weak var collectionViewTrendingArticles: UICollectionView!
    @IBOutlet weak var collectionViewFeaturedWatches: UICollectionView!
    @IBOutlet weak var webViewArticleDetail: WKWebView!
    @IBOutlet weak var constraintHeightShopThisLook: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightSpacingShopThisLook: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightWebView: NSLayoutConstraint!
    @IBOutlet weak var appTitleLogo: UIImageView!
    @IBOutlet weak var constraintSpacingShopThisLook: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightTrendingArticles: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingTrendingArticles: NSLayoutConstraint!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var progressViewFeaturedWatches: UIProgressView!
    @IBOutlet weak var lblFeaturedWatchesTitle: UILabel!
    @IBOutlet weak var imageViewArticle: UIImageView!
    @IBOutlet weak var redLineArticle: UIView!
    @IBOutlet weak var textViewTitle: UITextView!
    @IBOutlet weak var imageViewAuthor: UIImageView!
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var viewJustInProducts: UIView!
    @IBOutlet weak var viewArticleDescription: UIView!
    @IBOutlet weak var viewTrendingArticles: UIView!
    @IBOutlet weak var viewShopThisLook: UIView!
    
    let userActivityModel = UserActivityViewModel()
    var story : Banner?
    var articleId : Int?
    let refreshControl = UIRefreshControl()
    let articleDetailViewModel = GetArticleDetailsViewModel()
    let productViewModel = GetProductViewModel()
    let articleViewModel = GetArticlesViewModel()
    var isForPreOwned = false
    var lastSavedHeight : Double = 0.0
    var readStartTime : Date?
    var forStoryRoute : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.readStartTime != nil {
            readStartTime = Date()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let timeinterval = self.readStartTime?.timeIntervalSinceNow {
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.ArticleViewed,
                properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ArticleID : self.articleId,
                    EthosConstants.ArticleCategory : self.articleDetailViewModel.articleDetails?.customCategory?.name,
                    EthosConstants.ArticleTitle : self.articleDetailViewModel.articleDetails?.title,
                    EthosConstants.TimeSpent : Double(timeinterval.magnitude)
                ]
            )
        }
    }
    
    var loadingArticle : Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.reloadViewWhenArticleLoaded()
            }
        }
    }
    
    var loadingTrendingArticles : Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.reloadViewTrendingArticleLoaded()
            }
        }
    }
    
    var loadingNewArrivals : Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.reloadViewNewArrivalsLoaded()
            }
        }
    }
    
    
    func callApi() {
        if let id  = self.articleId {
            self.loadingArticle = true
            self.loadingNewArrivals = true
            self.loadingTrendingArticles = true
            
            self.articleDetailViewModel.getArticleDetails(id: id , site: self.isForPreOwned ? .secondMovement  : .ethos)
            self.articleViewModel.getArticles(category: ArticleCategory.trending.rawValue, site: self.isForPreOwned ? .secondMovement : .ethos)
            self.productViewModel.initiate(id: self.isForPreOwned ? 6 : 115, limit: 8, selectedSortBy: self.isForPreOwned ? EthosConstants.NewArrivals.uppercased() : EthosConstants.bestSeller) {
                self.productViewModel.getProductsFromCategory(site: self.isForPreOwned ? .secondMovement : .ethos)
            }
        }
    }
    
    func addRefreshControl() {
        self.refreshControl.tintColor = UIColor.black
        self.refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        self.refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.scrollViewMain.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        self.callApi()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.scrollViewMain.refreshControl?.endRefreshing()
        }
    }
    
    func setupTextView(textView : UITextView) {
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.isEditable = false
        textView.delaysContentTouches = false
        textView.isScrollEnabled = false
        textView.linkTextAttributes = [ NSAttributedString.Key.foregroundColor: EthosColor.red]
        textView.contentInsetAdjustmentBehavior = .never
        textView.textContainerInset = UIEdgeInsets.zero
        textView.layoutMargins = .zero
        textView.textContainer.lineFragmentPadding = 0;
        
    }
    
    func setup() {
        self.setupTextView(textView: self.textViewTitle)
        self.webViewArticleDetail.scrollView.addObserver(self, forKeyPath: EthosConstants.contentSize, options: .new, context: nil)
        self.collectionViewFeaturedWatches.registerCell(className: ProductCollectionViewCell.self)
        self.collectionViewTrendingArticles.registerCell(className: HomeCollectionViewCell.self)
        self.collectionViewShopThisLook.registerCell(className: ProductCollectionViewCell.self)
        self.webViewArticleDetail.navigationDelegate = self
        self.webViewArticleDetail.scrollView.isScrollEnabled = false
        self.articleDetailViewModel.delegate = self
        self.productViewModel.delegate = self
        self.articleViewModel.delegate = self
        self.btnBookmark.isEnabled = false
        self.btnShare.isEnabled = false
        self.addRefreshControl()
        
        
        self.txtBtnViewAllFeaturedWatches.setAttributedTitleWithProperties(title: EthosConstants.ViewAll.uppercased(), font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black, kern: 0.5)
        
        self.txtBtnViewAllTrendingArticles.setAttributedTitleWithProperties(title: EthosConstants.ViewAll.uppercased(), font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black, kern: 0.5)
        
        self.imageViewAuthor.setBorder(borderWidth: 0, borderColor: .clear, radius: 20)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            
            self.appTitleLogo.image = UIImage.imageWithName(name: self.isForPreOwned ? EthosConstants.apptitle2 : EthosConstants.apptitle)
            self.lblFeaturedWatchesTitle.setAttributedTitleWithProperties(title: self.isForPreOwned ? EthosConstants.JustIn.uppercased() : EthosConstants.FeaturedWathces.uppercased(), font: EthosFont.Brother1816Medium(size: 12), kern: 0.5)
            self.callApi()
            
        }
    }
    
    @IBAction func btnViewAllTrendingArticlesDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
            vc.isForPreOwn = self.isForPreOwned
            vc.key = .trending
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.TrendingArticlesClicked, properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnViewAllFeaturedWatchesDidTapped(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
            vc.isForPreOwned = self.isForPreOwned
            vc.productViewModel.categoryName = EthosConstants.NewArrivalsThisMonth.uppercased()
            vc.productViewModel.categoryId = isForPreOwned ? 6 : 115
            vc.productViewModel.selectedSortBy = self.isForPreOwned ? EthosConstants.NewArrivals.uppercased() : EthosConstants.bestSeller
            
            if !self.isForPreOwned {
                Mixpanel.mainInstance().trackWithLogs(
                    event: EthosConstants.FeaturedWathcesClicked,
                    properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS
                    ])
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwned
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func updateProgressView() {
        DispatchQueue.main.async {
            let multiplier = (self.collectionViewTrendingArticles.contentOffset.x + self.collectionViewTrendingArticles.frame.width)/self.collectionViewTrendingArticles.contentSize.width
            self.progressViewTrendingArticles.progress = Float(multiplier)
        }
    }
    
    func updateProgressViewFeaturedWatches() {
        DispatchQueue.main.async {
            let multiplier = (self.collectionViewFeaturedWatches.contentOffset.x + self.collectionViewFeaturedWatches.frame.width)/self.collectionViewFeaturedWatches.contentSize.width
            self.progressViewFeaturedWatches.progress = Float(multiplier)
        }
    }
    
    @IBAction func btnShareDidTapped(_ sender: UIButton) {
        if let sharelink = self.articleDetailViewModel.articleDetails?.link, sharelink != "" {
            let activityViewController = UIActivityViewController(activityItems: [sharelink], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = {
                type, complete, res, error in
                if complete {
                    Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ArticleShared, properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.Registered : Userpreference.token == nil || Userpreference.token == "" ? EthosConstants.N : EthosConstants.Y,
                        EthosConstants.SharedVia : type?.rawValue,
                        EthosConstants.ArticleID : self.articleDetailViewModel.articleDetails?.id
                    ]
                    )
                }
            }
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSaveArticleDidTapped(_ sender: UIButton) {
        VibrationHelper.vibrate()
        if let article = articleDetailViewModel.articleDetails {
            if self.btnBookmark.isSelected {
                DataBaseModel().checkArticleExists(article: article) { found in
                    if found {
                        DataBaseModel().unsaveArticle(article: article) {
                            self.btnBookmark.isSelected = false
                        }
                    } else {
                        self.btnBookmark.isSelected = false
                    }
                }
            } else {
                
                DataBaseModel().checkArticleExists(article: article) { found in
                    if !found {
                        DataBaseModel().saveArticle(article: article, forPreOwn: self.isForPreOwned) {
                            self.btnBookmark.isSelected = true
                        }
                    } else {
                        self.btnBookmark.isSelected = true
                    }
                }
            }
        }
    }
    
    func reloadViewTrendingArticleLoaded() {
        if self.loadingTrendingArticles {
            self.viewTrendingArticles.showAnimatedGradientSkeleton()
            DispatchQueue.main.async {
                self.constraintHeightTrendingArticles.constant = 600
                self.constraintSpacingTrendingArticles.constant = 8
                self.view.layoutIfNeeded()
            }
            
        } else {
            self.viewTrendingArticles.hideSkeleton()
            DispatchQueue.main.async {
                self.constraintHeightTrendingArticles.constant = ((self.articleViewModel.articles.count ) == 0) ? 0 : 600
                self.constraintSpacingTrendingArticles.constant = ((self.articleViewModel.articles.count ) == 0) ? 0 : 8
                self.view.layoutIfNeeded()
            }
        }
        
        self.collectionViewTrendingArticles.reloadData()
        self.updateProgressView()
    }
    
    func reloadViewWhenArticleLoaded() {
        if self.loadingArticle {
            self.viewShopThisLook.showAnimatedGradientSkeleton()
            self.collectionViewShopThisLook.showAnimatedGradientSkeleton()
            self.viewArticleDescription.showAnimatedGradientSkeleton()
            
            self.constraintHeightShopThisLook.constant = 410
        } else {
            self.viewArticleDescription.hideSkeleton(transition: .none)
            self.viewShopThisLook.hideSkeleton(transition: .none)
            self.collectionViewShopThisLook.hideSkeleton(transition: .none)
            
            DispatchQueue.main.async {
                self.collectionViewShopThisLook.reloadData()
                self.constraintHeightShopThisLook.constant = ((self.articleDetailViewModel.articleDetails?.articleProducts?.count ?? 0) == 0) ? 0 : 410
                self.constraintSpacingShopThisLook.constant = ((self.articleDetailViewModel.articleDetails?.articleProducts?.count ?? 0) == 0) ? 0 : 8
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func reloadViewNewArrivalsLoaded() {
        if self.loadingNewArrivals {
            self.collectionViewFeaturedWatches.showAnimatedGradientSkeleton()
        } else {
            self.collectionViewFeaturedWatches.hideSkeleton()
        }
        
        self.collectionViewFeaturedWatches.reloadData()
        self.updateProgressViewFeaturedWatches()
        self.view.layoutIfNeeded()
    }
    
    func reloadViewWhenChangeInWebViewHeight() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        removeCookies()
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler:{
            DispatchQueue.main.async {
//                self.constraintHeightWebView.constant = 0
//                self.view.layoutIfNeeded()
//                
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.constraintHeightWebView.constant = self.webViewArticleDetail.scrollView.contentSize.height
                    
                    self.view.layoutIfNeeded()
//                }
            }
        }
        )
    }
    
    func removeCookies(){
        let cookieJar = HTTPCookieStorage.shared
        
        for cookie in cookieJar.cookies ?? [] {
            cookieJar.deleteCookie(cookie)
        }
    }
}

extension ArticleDetailViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.collectionViewTrendingArticles {
            updateProgressView()
        }
        
        if scrollView == self.collectionViewFeaturedWatches {
            updateProgressViewFeaturedWatches()
        }
    }
}

extension ArticleDetailViewController : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        switch skeletonView {
        case collectionViewTrendingArticles : String(describing: HomeCollectionViewCell.self)
        case collectionViewFeaturedWatches : String(describing: ProductCollectionViewCell.self)
        case collectionViewShopThisLook : String(describing: ProductCollectionViewCell.self)
        default : String(describing: ProductCollectionViewCell.self)
            
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        switch skeletonView {
        case collectionViewTrendingArticles :
            if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath) as? HomeCollectionViewCell {
                cell.contentView.showAnimatedGradientSkeleton()
                return cell
            }
            
        case collectionViewFeaturedWatches :
            if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showAnimatedGradientSkeleton()
                return cell
            }
            
            
        case collectionViewShopThisLook :
            if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.showAnimatedGradientSkeleton()
                return cell
            }
            
        default : return UICollectionViewCell()
            
        }
        
        return UICollectionViewCell()
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
}


extension ArticleDetailViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case collectionViewTrendingArticles : return articleViewModel.articles.count >= 5 ? 5 : articleViewModel.articles.count
        case collectionViewFeaturedWatches :  return productViewModel.products.count
        case collectionViewShopThisLook : return articleDetailViewModel.products.count
        default : return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case collectionViewTrendingArticles :
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: HomeCollectionViewCell.self), for: indexPath) as? HomeCollectionViewCell {
                cell.contentView.hideSkeleton()
                cell.article = self.articleViewModel.articles[indexPath.item]
                return cell
            }
            
        case collectionViewFeaturedWatches :
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.hideSkeleton()
                cell.isForPreOwned = self.isForPreOwned
                cell.product = self.productViewModel.products[indexPath.item]
                return cell
            }
            
            
        case collectionViewShopThisLook :
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                cell.contentView.hideSkeleton()
                cell.isForPreOwned = self.isForPreOwned
                cell.product  = self.articleDetailViewModel.products[indexPath.item]
                return cell
            }
            
        default : return UICollectionViewCell()
            
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case collectionViewTrendingArticles : return CGSize(width: 300, height: 450)
        case collectionViewFeaturedWatches :  return collectionViewFeaturedWatches.cellSize(noOfCellsInRow: 2.5, Height: 310)
        case collectionViewShopThisLook :  return collectionViewFeaturedWatches.cellSize(noOfCellsInRow: 2.5, Height: 310)
        default : return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case collectionViewTrendingArticles :
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                vc.isForPreOwned = self.isForPreOwned
                vc.articleId = self.articleViewModel.articles[indexPath.item].id
                
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
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case collectionViewFeaturedWatches :
            if self.isForPreOwned {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = self.productViewModel.products[indexPath.item].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
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
                    vc.sku = self.productViewModel.products[indexPath.item].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        case collectionViewShopThisLook :
            if self.isForPreOwned {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = self.articleDetailViewModel.products[indexPath.item].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
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
                            EthosConstants.ProductSubCategory :  EthosConstants.Shopthislook.uppercased()
                        ]
                    )
                    vc.sku = self.articleDetailViewModel.products[indexPath.item].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        default:
            break
        }
    }
}

extension ArticleDetailViewController : GetArticleDetailsViewModelDelegate {
    
    func setUIWhenArticleLoaded(article : ArticleDetails) {
        
        self.loadingArticle = false
        
        self.btnBookmark.isEnabled = true
        self.btnShare.isEnabled = true
        
        DataBaseModel().checkArticleExists(article: article) { exist in
            if exist {
                self.btnBookmark.isSelected = true
            } else {
                self.btnBookmark.isSelected = false
            }
        }
        
        if let urlStr = article.link {
            if self.isForPreOwned {
                let urlComp = urlStr + "?eapp=1&ver=2&device=ios"
                if let url =  URL(string:  urlComp) {
                    self.webViewArticleDetail.load( URLRequest(url: url))
                }
            } else {
                let urlComp = urlStr + "?eapp=1&ver=2&device=ios"
                if let url =  URL(string:  urlComp) {
                    self.webViewArticleDetail.load( URLRequest(url: url))
                }
            }
            
        }
        
        let category = article.customCategory?.name
        let title = article.title
        let author = article.author ?? ""
        
        if  let image = article.topFeaturedImage, let url = URL(string: image) {
            self.imageViewArticle.kf.setImage(with: url)
        }
        
        if  let image = article.authorImage, let url = URL(string: image) {
            self.imageViewAuthor.kf.setImage(with: url)
        }
        
        let attr = NSMutableAttributedString()
        
        
        if let category = category?.trimmingCharacters(in: .whitespacesAndNewlines) , category != "" {
            let style = NSMutableParagraphStyle()
            style.alignment = .left
            style.lineSpacing = 1.13
            let attributedCategory = NSMutableAttributedString(string: category + "  •  ", attributes: [NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 20), NSAttributedString.Key.foregroundColor : EthosColor.red, NSAttributedString.Key.paragraphStyle : style])
            attr.append(attributedCategory)
        }
        
        if let title = title?.trimmingCharacters(in: .whitespacesAndNewlines), title != ""  {
            let style = NSMutableParagraphStyle()
            style.alignment = .left
            style.lineSpacing = 1.13
            
            let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 18), NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.paragraphStyle : style])
            attr.append(attributedTitle)
        }
        
        if let articleDescription = article.subtitle?.htmlToString , !articleDescription.isEmpty {
            let style = NSMutableParagraphStyle()
            style.alignment = .left
            style.lineSpacing = 1.13
            let twoline = NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font : EthosFont.Brother1816RegularItalic(size: 8), NSAttributedString.Key.foregroundColor : EthosColor.descGrey])
            
            let attributedDescription = NSAttributedString(string: "\( articleDescription)", attributes: [NSAttributedString.Key.font : EthosFont.Brother1816RegularItalic(size: 16), NSAttributedString.Key.foregroundColor : EthosColor.descGrey, NSAttributedString.Key.paragraphStyle : style])
            
            attr.append(twoline)
            attr.append(attributedDescription)
            
        }
        
        self.textViewTitle.attributedText = attr
        
        let attributedAuthor = NSMutableAttributedString(string: author, attributes: [NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14), NSAttributedString.Key.foregroundColor : EthosColor.darkGrey])
        
        let joiner = NSMutableAttributedString(string: "   •   ", attributes: [NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14), NSAttributedString.Key.foregroundColor : EthosColor.red])
        
        let date = NSMutableAttributedString(string: EthosDateAndTimeHelper().getStringFromDate(str: self.articleDetailViewModel.articleDetails?.pubdate ?? ""), attributes: [NSAttributedString.Key.font : EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14), NSAttributedString.Key.foregroundColor : EthosColor.darkGrey])
        
        attributedAuthor.append(joiner)
        attributedAuthor.append(date)
        
        self.lblAuthorName.attributedText = attributedAuthor
        self.readStartTime = Date()
        
    }
    
    func didGetArticledetails(articleDetails: ArticleDetails) {
        
        self.setUIWhenArticleLoaded(article: articleDetails)
        
        
        if self.forStoryRoute {
            Mixpanel.mainInstance().trackWithLogs(
                event: EthosConstants.KnowMoreClicked,
                properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.ArticleID : articleDetails.id,
                    EthosConstants.ArticleTitle : articleDetails.title,
                    EthosConstants.ArticleCategory : articleDetails.customCategory?.name
                ]
            )
        }
    }
    
    func errorInGettinArticles() {
        self.loadingArticle = false
    }
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
    
    
}

extension ArticleDetailViewController : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
    }
}

extension ArticleDetailViewController : GetProductViewModelDelegate {
    func didGetProducts(site : Site?, CategoryId : Int?) {
        self.loadingNewArrivals = false
    }
    
    func errorInGettingProducts(error: String) {
        
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
    
    func didGetProductDetails(details: Product) {
        
    }
    
    func failedToGetProductDetails() {
        
    }
    
    func didGetFilters() {
        
    }
    
    func errorInGettingFilters() {
        
    }
    
    
}

extension ArticleDetailViewController : WKNavigationDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == EthosConstants.contentSize {
            if let scroll = object as? UIScrollView {
                if scroll.contentSize.height != lastSavedHeight {
                    self.lastSavedHeight = scroll.contentSize.height
                    self.reloadViewWhenChangeInWebViewHeight()
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.reloadViewWhenChangeInWebViewHeight()
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url {
                if url.absoluteString.contains("app-data?data="){
                    let incomingURL = URL(string: url.absoluteString)
                    if let lastPartUrl = incomingURL?.absoluteString.components(separatedBy: "=") {
                        let lastPart = lastPartUrl.last!
                        print(lastPart)
                        if let decodedString = lastPart.removingPercentEncoding {
                            let decodeURlData = decodedString.data(using: .utf8)
                            do {
                                if let productData = try JSONSerialization.jsonObject(with: decodeURlData!, options: []) as? [String: Any] {
                                    
                                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: CheckYourSellingPriceViewController.self)) as? CheckYourSellingPriceViewController {
                                        let jsonDict = Product(json: productData)
                                        vc.product = jsonDict
                                        vc.isForPreOwned = self.isForPreOwned
                                        self.present(vc, animated: true)
                                    }
                                }
                            } catch {
                                print("Error parsing JSON: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    userActivityModel.getDataFromActivityUrl(url: url.absoluteString)
                }
                decisionHandler(.cancel)
                return
            } else {
                decisionHandler(.allow)
                return
            }
        } else {
            print(navigationAction.description)
            decisionHandler(.allow)
            return
        }
    }
}

extension ArticleDetailViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        self.loadingTrendingArticles = false
    }
    
    func errorInGettingArticles(error: String) {
        self.loadingTrendingArticles = false
    }
}
