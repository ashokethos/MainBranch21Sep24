//
//  PreOwnedViewController.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import Photos
import PhotosUI
import SafariServices
import Mixpanel
import SkeletonView

class PreOwnedViewController: UIViewController {
    
    @IBOutlet weak var tableViewStory: UITableView!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var btnSell: UIButton!
    @IBOutlet weak var btnTrade: UIButton!
    @IBOutlet weak var btnBoutique: UIButton!
    @IBOutlet weak var btnJournal: UIButton!
    @IBOutlet weak var viewIndicatorBuy: UIView!
    @IBOutlet weak var viewIndicatorSell: UIView!
    @IBOutlet weak var viewIndicatorTrade: UIView!
    @IBOutlet weak var viewIndicatorBoutique: UIView!
    @IBOutlet weak var viewIndicatorJournal: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorFooter: UIActivityIndicatorView!
    @IBOutlet weak var lblNumberOfNotifications: UILabel!
    @IBOutlet weak var viewSMSplash: UIView!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var imageViewVideo: UIImageView!
    
    let articleViewModel = GetArticlesViewModel()
    var productViewModel = GetProductViewModel()
    var staffPicksProductViewModel = GetProductViewModel()
    var bannerViewModel = GetBannersViewModel()
    let adViewModel = GetAdsViewModel()
    var contactsModel = ContactUsViewModel()
    var articleCategoryViewModel = GetArticleCategoriesViewModel()
    
    var searchKeyWords = ""
    let layer = AVPlayerLayer()
    let refreshControl = UIRefreshControl()
    
    var loadingArticles : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.selectedIndex == 4 {
                    self.tableViewStory?.reloadData()
                }
            }
        }
    }
    
    var loadingArticleCategories : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.selectedIndex == 1 {
                    
                    if self.tableViewStory?.numberOfSections ?? 0 > 18 {
                        self.tableViewStory?.reloadSections([18], with: .automatic)
                    }
                    
                    
                } else if self.selectedIndex == 2 {
                    if self.tableViewStory?.numberOfSections ?? 0 > 8 {
                        self.tableViewStory?.reloadSections([8], with: .automatic)
                    }
                }
            }
        }
    }
    
    
    var loadingNewArrivalProducts : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.selectedIndex == 0 {
                    if self.tableViewStory?.numberOfSections ?? 0 > 3 {
                        self.tableViewStory?.reloadSections([3], with: .automatic)
                    }
                } else if self.selectedIndex == 1 {
                    
                    if self.tableViewStory?.numberOfSections ?? 0 > 17 {
                        self.tableViewStory?.reloadSections([16, 17], with: .automatic)
                    }
                    
                    
                } else if self.selectedIndex == 2 {
                    if self.tableViewStory?.numberOfSections ?? 0 > 7 {
                        self.tableViewStory.reloadSections([6, 7], with: .automatic)
                    }
                }
            }
        }
    }
    
    var loadingBanners : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.selectedIndex == 0 {
                    if self.tableViewStory?.numberOfSections ?? 0 > 0 {
                        self.tableViewStory?.reloadSections([0], with: .automatic)
                    }
                }
            }
        }
    }
    
    var loadingContacts : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.selectedIndex == 3 {
                    if self.tableViewStory?.numberOfSections ?? 0 > 3 {
                        self.tableViewStory?.reloadSections([3], with: .automatic)
                    }
                }
            }
        }
    }
    
    var loadingStaffPicks : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.selectedIndex == 0 {
                    if self.tableViewStory?.numberOfSections ?? 0 > 6 {
                        self.tableViewStory?.reloadSections([6], with: .automatic)
                    }
                }
            }
        }
    }
    
    
    var selectedIndex = 0 {
        didSet {
            let arrButton = [self.btnBuy,self.btnSell,self.btnTrade,self.btnBoutique,self.btnJournal]
            let arrView = [self.viewIndicatorBuy,self.viewIndicatorSell,self.viewIndicatorTrade,self.viewIndicatorBoutique,self.viewIndicatorJournal]
            for btn in arrButton {
                btn?.alpha = selectedIndex == btn?.tag ? 1 : 0.5
            }
            
            for view in arrView {
                view?.backgroundColor = selectedIndex == view?.tag ? EthosColor.red : .clear
            }
            
            self.tableViewStory.reloadData()
        }
    }
    
    let ArrHowItWorksSell : [TitleDescriptionImageModel] = [
        TitleDescriptionImageModel(title: EthosConstants.TellUsAboutWatch, description: EthosConstants.TellUsAboutWatchDescription, image: ""),
        
        TitleDescriptionImageModel(title: EthosConstants.ApproveTheValuation, description: EthosConstants.ApproveTheValuationDescription, image: ""),
        
        TitleDescriptionImageModel(title: EthosConstants.QualityCheck, description: EthosConstants.QualityCheckDescription, image: ""),
        
        TitleDescriptionImageModel(title: EthosConstants.ReceivePayment, description: EthosConstants.ReceivePaymentDescription, image: "")
    ]
    
    let ArrHowItWorksTrade : [TitleDescriptionImageModel] = [
        TitleDescriptionImageModel(title: EthosConstants.ChooseYourWatch, description: EthosConstants.ChooseYourWatchDescription, image: ""),
        
        TitleDescriptionImageModel(title: EthosConstants.SpeakWithAnExpert, description: EthosConstants.SpeakWithAnExpertDescription, image: ""),
        
        TitleDescriptionImageModel(title: EthosConstants.SendUsYourWatch, description: EthosConstants.SendUsYourWatchDescription, image: ""),
        
        TitleDescriptionImageModel(title: EthosConstants.ShipsWithin48hour, description: EthosConstants.ShipsWithin48hourDescription, image: "")
    ]
    
    let ArrHWhyToSell : [TitleDescriptionImageModel] = [
        TitleDescriptionImageModel(title: EthosConstants.Privacy, description: EthosConstants.PrivacyDescription, image: EthosConstants.bulletPrivacy),
        
        TitleDescriptionImageModel(title: EthosConstants.EasyPayment, description: EthosConstants.EasyPaymentDescription, image: EthosConstants.bulletEasyPayment),
        
        TitleDescriptionImageModel(title: EthosConstants.ValueForYourWatch, description: EthosConstants.ValueForYourWatchDescription, image: EthosConstants.bulletValueForYourWatch),
        
        TitleDescriptionImageModel(title: EthosConstants.TransParency, description: EthosConstants.TransParencyDescription, image: EthosConstants.bulletTransparency)
    ]
    
    let ArrBoutiqueDescription : [TitleDescriptionImageModel] = [
        TitleDescriptionImageModel(title: EthosConstants.boutiqueTitle_I, description: EthosConstants.boutiqueDescription_I, image: EthosConstants.smbd1, btnTitle: EthosConstants.boutiqueButtonTitle_I),
        
        TitleDescriptionImageModel(title: EthosConstants.boutiqueTitle_II, description: EthosConstants.boutiqueDescription_II, image: EthosConstants.smbd2, btnTitle: EthosConstants.boutiqueButtonTitle_II),
        
        TitleDescriptionImageModel(title: EthosConstants.boutiqueTitle_III, description: EthosConstants.boutiqueDescription_III, image: EthosConstants.smbd3, btnTitle: EthosConstants.boutiqueButtonTitle_III),
        
        TitleDescriptionImageModel(title: EthosConstants.boutiqueTitle_IV, description: EthosConstants.boutiqueDescription_IV, image: EthosConstants.smbd4, btnTitle: "")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        callApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateNotificationCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        for index in tableViewStory?.indexPathsForVisibleRows ?? [] {
            if let view = tableViewStory?.footerView(forSection: index.section) as? AdvertisementHeaderFooterView {
                view.playerLayer.player?.pause()
                view.btnPausePlay?.isSelected = false
            }
            
            if let cell = tableViewStory?.cellForRow(at: index) as? VisitOurBoutiqueCell {
                cell.btnPlayPause?.isHidden = false
                cell.playerLayer.player?.pause()
                cell.btnPlayPause?.isSelected = false
            }
        }
        
        if let cell = self.tableViewStory?.cellForRow(at: IndexPath(row: 0, section: 0)) as? EthosStoryCell {
            cell.pauseVideo()
        }
        
        if let cell = self.tableViewStory?.cellForRow(at: IndexPath(row: 0, section: 0)) as? SingleVideoTableViewCell {
            cell.btnPlayPause.isHidden = false
            cell.playerLayer.player?.pause()
        }
        
        
    }
    
    
    func callApi() {
        
        self.adViewModel.getAdvertisment(site: .secondMovement, location: "latest") {
            self.articleViewModel.getArticles(site : .secondMovement)
        }
        
        self.bannerViewModel.getBanners(key: .preOwn, site: .secondMovement)
        
        switch Userpreference.smJustINSort ?? "" {
        case "New Arrival" :  self.productViewModel.initiate(id: 6, limit: 10, selectedSortBy: EthosConstants.NewArrivals.uppercased()) {
            self.productViewModel.getProductsFromCategory(site: .secondMovement)
        }
        case "Best Selling" :  self.productViewModel.initiate(id: 6, limit: 10, selectedSortBy: EthosConstants.bestSeller.uppercased()) {
            self.productViewModel.getProductsFromCategory(site: .secondMovement)
        }
        case "Price High to Low" :  self.productViewModel.initiate(id: 6, limit: 10, selectedSortBy: EthosConstants.priceHighToLow.uppercased()) {
            self.productViewModel.getProductsFromCategory(site: .secondMovement)
        }
        case "Price Low to High":  self.productViewModel.initiate(id: 6, limit: 10, selectedSortBy: EthosConstants.priceLowToHigh.uppercased()) {
            self.productViewModel.getProductsFromCategory(site: .secondMovement)
        }
        default:
            break
        }
       
        
        
        self.staffPicksProductViewModel.initiate(id: 22, limit: 100, selectedSortBy: EthosConstants.bestSeller){
            self.staffPicksProductViewModel.getProductsFromCategory(site: .secondMovement)
        }
        
        self.contactsModel.getContacts(site: .secondMovement) { contacts in
            
        }
        
        self.articleCategoryViewModel.getArticleCategories(site: .secondMovement)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showPreownedStartingPopup()
    }
    
    func showPreownedStartingPopup() {
        self.btnSkip.setAttributedTitleWithProperties(title: "SKIP", font: EthosFont.Brother1816Medium(size: 10), alignment: .center, foregroundColor: .white, kern: 5)
        
        if Userpreference.preownedSplashWatched != true {
            Userpreference.preownedSplashWatched = true
            self.tabBarController?.tabBar.isHidden = true
            self.startPlayer()
        }
    }
    
    func startPlayer() {
        self.viewSMSplash.isHidden = false
        if let url = Bundle.main.url(forResource: "SplashPreOwned", withExtension:"mp4") {
            let player = AVPlayer(url: url)
            layer.player = player
            layer.videoGravity = .resizeAspectFill
            layer.frame = self.imageViewVideo.frame
            self.imageViewVideo.layer.addSublayer(layer)
            layer.player?.play()
            Mixpanel.mainInstance().trackWithLogs(event: "Pre Owned Trailer Watched", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
            addObseverToPlayer()
        }
    }
    
    func addObseverToPlayer() {
        self.layer.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale:CMTimeScale(NSEC_PER_SEC)), queue:DispatchQueue.main) { time in
            let duration = CMTimeGetSeconds( self.layer.player?.currentItem?.duration ?? CMTime())
            let progress = Float((CMTimeGetSeconds(time) / duration))
            if progress == 1 {
                self.stopSplash()
            }
        }
    }
    
    func stopSplash() {
        self.layer.player?.pause()
        self.layer.removeFromSuperlayer()
        self.viewSMSplash.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setup() {
        addRefreshControl()
        tableViewStory.registerCell(className: HomeTableViewCell.self)
        tableViewStory.registerCell(className: SectionHeaderCell.self)
        tableViewStory.registerCell(className: EthosStoryCell.self)
        tableViewStory.registerCell(className: SingleVideoTableViewCell.self)
        tableViewStory.registerCell(className: VerticalCollectionTableViewCell.self)
        tableViewStory.registerCell(className: SellOrTradeTableViewCell.self)
        tableViewStory.registerCell(className: HorizontalCollectionTableViewCell.self)
        tableViewStory.registerCell(className: VisitOurBoutiqueCell.self)
        tableViewStory.registerCell(className: RepairAndServiceCell.self)
        tableViewStory.registerCell(className: RepairAndServiceNew.self)
        tableViewStory.registerCell(className: EthosBulletTableViewCell.self)
        tableViewStory.registerCell(className: EthosBulletTableViewCellForNumber.self)
        tableViewStory.registerCell(className: HeadingCell.self)
        tableViewStory.registerCell(className: AboutCollectionTableViewCell.self)
        tableViewStory.registerCell(className: GetAQuoteTableViewCell.self)
        tableViewStory.registerCell(className: SpacingTableViewCell.self)
        tableViewStory.registerCell(className: GetAQuoteTradeTableViewCell.self)
        tableViewStory.registerCell(className: WhereToLocateUsTableViewCell.self)
        tableViewStory.registerCell(className: ImageTitleDescriptionTableViewCell.self)
        tableViewStory.registerCell(className: SingleButtonWithDisclosureTableViewCell.self)
        tableViewStory.registerCell(className: SecondMovementBoutiqueHeaderTableViewCell.self)
        tableViewStory.registerCell(className: SecondMovementBoutiqueImagesCell.self)
        tableViewStory.registerCell(className: BrandsTableViewCell.self)
        tableViewStory.register(UINib(nibName: String(describing: AdvertisementHeaderFooterView.self), bundle: nil), forHeaderFooterViewReuseIdentifier:  String(describing: AdvertisementHeaderFooterView.self))
        
        articleViewModel.delegate = self
        productViewModel.delegate = self
        staffPicksProductViewModel.delegate = self
        bannerViewModel.delegate = self
        contactsModel.delegate = self
        articleCategoryViewModel.delegate = self
        btnBuy.tag = 0
        btnSell.tag = 1
        btnTrade.tag = 2
        btnBoutique.tag = 3
        btnJournal.tag = 4
        
        viewIndicatorBuy.tag = 0
        viewIndicatorSell.tag = 1
        viewIndicatorTrade.tag = 2
        viewIndicatorBoutique.tag = 3
        viewIndicatorJournal.tag = 4
        selectedIndex = 0
        addTapGestureToDissmissKeyBoard()
        lblNumberOfNotifications.setBorder(borderWidth: 0, borderColor: .clear, radius: 7.5)
        NotificationCenter.default.addObserver(forName:  NSNotification.Name("receivedNotification"), object: nil, queue: nil) { notification in
            self.updateNotificationCount()
        }
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.tableViewStory.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        self.loadingBanners = true
        self.loadingContacts = true
        self.loadingArticles = true
        self.loadingStaffPicks = true
        self.loadingArticleCategories = true
        self.loadingNewArrivalProducts = true
        
        self.callApi()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.tableViewStory.refreshControl?.endRefreshing()
        }
        
    }
    
    @IBAction func btnSkipDidTapped(_ sender: UIButton) {
        self.stopSplash()
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.delegate = self
            vc.isForPreOwned = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func updateNotificationCount() {
        DataBaseModel().fetchNotifications { notifications in
            
            let unreadMessages = notifications.filter { notification in
                notification.isRead == false
            }
            
            self.lblNumberOfNotifications.isHidden = (unreadMessages.count == 0)
            self.lblNumberOfNotifications.text = String(unreadMessages.count)
        }
    }
    
    @IBAction func btnNotificationDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NotificationsViewController.self)) as? NotificationsViewController {
            vc.isForPreOwned = true
            
            let properties : Dictionary<String, any MixpanelType> = [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                "Screen" : "Pre-Owned"
            ]
            
            Mixpanel.mainInstance().trackWithLogs(event: "Notifications Clicked" , properties: properties)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    @IBAction func btnTabDidTapped(_ sender: UIButton) {
        if tableViewStory.refreshControl?.isRefreshing != true {
            UIView.animate(withDuration: 0.5 , animations : {
                self.tableViewStory.contentOffset = .zero
            }) {_ in
                
                if let cell = self.tableViewStory.cellForRow(at: IndexPath(row: 0, section: 0)) as? SingleVideoTableViewCell {
                    cell.playerLayer.player?.pause()
                    cell.btnPlayPause.isHidden = false
                }
                
                for indexPath in self.tableViewStory.indexPathsForVisibleRows ?? [] {
                    if let cell = self.tableViewStory.cellForRow(at: indexPath) as? VisitOurBoutiqueCell {
                        cell.playerLayer.player?.pause()
                        cell.btnPlayPause.isHidden = false
                    }
                }
                
                Mixpanel.mainInstance().trackWithLogs(event: "Pre Owned Nav Bar Selected", properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    "Tab" : sender.titleLabel?.text?.capitalized
                ])
                self.selectedIndex = sender.tag
            }
        }
    }
}

extension PreOwnedViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedIndex {
        case 0 :  return 1
        case 1:  return section == 4 ? ArrHowItWorksSell.count :  section == 11 ? ArrHWhyToSell.count : 1
        case 2 :
            if section == 0 {
                return 4
            }
            
            return section == 1 ? ArrHowItWorksTrade.count : 1
            
        case 3 :
            switch section {
            case 0 : return 1
            case 1 : return 1
            case 2 : return ArrBoutiqueDescription.count
            case 3 : return 1
            default : return 0
            }
            
        case 4 : return 1
            
        default : return 0
            
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch selectedIndex {
        case 0 :  return 8
        case 1:  return 20
        case 2 :  return 9
        case 3 : return 4
        case 4 : return self.loadingArticles ? 10 : articleViewModel.articles.count
        default :  return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch selectedIndex {
        case 0 :
            
            switch indexPath.section {
            case 0 :
                if self.loadingBanners {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoryCell.self), for: indexPath) as? EthosStoryCell {
                        cell.isforPreOwned = true
                        cell.delegate = self
                        cell.superTableView = self.tableViewStory
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionViewStories.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoryCell.self), for: indexPath) as? EthosStoryCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionViewStories.hideSkeleton()
                        cell.isforPreOwned = true
                        cell.delegate = self
                        cell.viewModel.banners = self.bannerViewModel.banners
                        cell.didGetBanners(banners: self.bannerViewModel.banners)
                        cell.superTableView = self.tableViewStory
                        return cell
                    }
                }
                
                
            case 1 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BrandsTableViewCell.self), for: indexPath) as? BrandsTableViewCell {
                    cell.setTitle(title: EthosConstants.brandsWorthyOfACollector.uppercased())
                    cell.forSecondMovement = true
                    cell.delegate = self
                    cell.initiateData()
                    return cell
                }
                
            case 2 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                cell.setSpacing(height: 10)
                return cell
            }
                
            case 3 :
                
                if self.loadingNewArrivalProducts {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VerticalCollectionTableViewCell.self), for: indexPath) as? VerticalCollectionTableViewCell {
                        cell.delegate = self
                        cell.isForPreOwned = true
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedSkeleton()
                        cell.didGetProducts(site: nil, CategoryId: nil)
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VerticalCollectionTableViewCell.self), for: indexPath) as? VerticalCollectionTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionView.hideSkeleton()
                        cell.delegate = self
                        cell.isForPreOwned = true
                        cell.productViewModel.products = self.productViewModel.products
                        cell.didGetProducts(site: nil, CategoryId: nil)
                        return cell
                    }
                }
                
                
                
            case 4 :
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SellOrTradeTableViewCell.self), for: indexPath) as? SellOrTradeTableViewCell {
                    cell.delegate = self
                    return cell
                }
                
                
                
            case 5 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VisitOurBoutiqueCell.self), for: indexPath) as? VisitOurBoutiqueCell {
                    cell.delegate = self
                    cell.superController = self
                    cell.superTableView = self.tableViewStory
                    cell.lblHeading.setAttributedTitleWithProperties(title: "A premium lounge where you can experience the finest pre-owned luxury watches", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), alignment: .center, lineHeightMultiple: 1.25 , kern: 0.1)
                    cell.btnBottom.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
                    cell.videoUrl =  "https://player.vimeo.com/video/888645703"
                    
                    return cell
                }
                
            case 6 :
                
                if self.loadingStaffPicks {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.PreOwnedPicks.uppercased())
                        cell.key = .forstaffPicks
                        cell.delegate = self
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        return cell
                        
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionView.hideSkeleton()
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.PreOwnedPicks.uppercased())
                        cell.key = .forstaffPicks
                        cell.productViewModel.products = self.staffPicksProductViewModel.products
                        cell.didGetProducts(site: nil, CategoryId: nil)
                        cell.delegate = self
                        return cell
                        
                    }
                }
                
                
            case 7 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceNew.self), for: indexPath) as? RepairAndServiceNew {
                    cell.key = .forPreowned
                    cell.delegate = self
                    return cell
                }
                
            default:
                break
            }
            
            
            
        case 1:
            switch indexPath.section {
            case 0 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SingleVideoTableViewCell.self), for: indexPath) as? SingleVideoTableViewCell {
                    if let url = Bundle.main.url(forResource: "preownedSellTab", withExtension: "mp4") {
                        cell.url = url
                    }
                    return cell
                }
                
            case 1 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceCell.self), for: indexPath) as? RepairAndServiceCell {
                    cell.key = .forsecondMovementSell
                    return cell
                }
                
            case 2 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 30,color: .white)
                    return cell
                }
                
                
            case 3 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                    cell.setHeading(title: EthosConstants.HowItWorks,backgroundColor: EthosColor.white ,showBulletLine: true)
                    return cell
                }
                
            case 4 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosBulletTableViewCellForNumber.self), for: indexPath) as? EthosBulletTableViewCellForNumber {
                    cell.index = indexPath.row + 1
                    cell.data = ArrHowItWorksSell[safe : indexPath.row]
                    return cell
                }
                
            case 5 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SingleButtonWithDisclosureTableViewCell.self), for: indexPath) as? SingleButtonWithDisclosureTableViewCell {
                    cell.action = {
                        self.tableViewStory.scrollToRow(at: IndexPath(row: 0, section: 14), at: .top, animated: true)
                    }
                    
                    return cell
                }
                
            case 6 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 20,color: .white)
                    return cell
                }
                
            case 7 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing()
                    return cell
                }
                
            case 8 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2,color: .white)
                    return cell
                }
                
            case 9 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SectionHeaderCell.self), for: indexPath) as? SectionHeaderCell {
                    cell.setTitle(title: EthosConstants.WhyToSellOnSecondMovement.uppercased())
                    return cell
                }
                
                
            case 10 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutCollectionTableViewCell.self), for: indexPath) as? AboutCollectionTableViewCell {
                    cell.key = .forSecondMovementSell
                    cell.data = TitleDescriptionImageModel(title: "", description: EthosConstants.WhyToSellOnSecondMovementDescription, image: EthosConstants.sellOrTradeWithShadow)
                    
                    return cell
                }
                
            case 11 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosBulletTableViewCell.self), for: indexPath) as? EthosBulletTableViewCell {
                    cell.data = ArrHWhyToSell[safe : indexPath.row]
                    return cell
                }
                
            case 12 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 30,color: .white)
                    return cell
                }
                
            case 13 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing()
                    return cell
                }
                
            case 14 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GetAQuoteTableViewCell.self), for: indexPath) as? GetAQuoteTableViewCell {
                    cell.delegate = self
                    cell.brandViewModel.getBrandsForFormData(site: .secondMovement)
                    return cell
                }
                
            case 15 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing()
                    return cell
                }
                
            case 16 :
                if self.loadingNewArrivalProducts {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.key = .forSecondMovementNewArrival
                        cell.delegate = self
                        cell.setTitle(title: EthosConstants.JustIn.uppercased())
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if self.productViewModel.products.count > 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            cell.contentView.hideSkeleton()
                            cell.collectionView.hideSkeleton()
                            cell.forSecondMovement = true
                            cell.key = .forSecondMovementNewArrival
                            cell.delegate = self
                            cell.setTitle(title: EthosConstants.JustIn.uppercased())
                            cell.productViewModel.products = self.productViewModel.products
                            cell.didGetProducts(site: nil, CategoryId: nil)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2, color: .clear)
                            return cell
                        }
                    }
                }
                
                
                
            case 17 :
                if self.productViewModel.products.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing()
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
                
                
                
            case 18 :
                if self.loadingArticleCategories {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.FromtheJournal.uppercased())
                        cell.key = .forReadList
                        cell.progressView.isHidden = true
                        cell.constraintBottomProgressView.constant = 0
                        cell.delegate = self
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionView.hideSkeleton()
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.FromtheJournal.uppercased())
                        cell.key = .forReadList
                        cell.progressView.isHidden = true
                        cell.constraintBottomProgressView.constant = 0
                        cell.delegate = self
                        cell.articleCategoriesViewModel.articleCategories = self.articleCategoryViewModel.articleCategories
                        cell.didGetArticleCategories(articleCategories: self.articleCategoryViewModel.articleCategories)
                        return cell
                    }
                }
                
            case 19 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(color: .clear)
                    return cell
                }
                
            default:
                break
            }
            
        case 2 :
            
            switch indexPath.section {
            case 0 :
                switch indexPath.row {
                case 0 :
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceCell.self), for: indexPath) as? RepairAndServiceCell {
                        cell.key = .forsecondMovementTrade
                        return cell
                    }
                    
                case 1 :
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 30,color: EthosColor.appBGColor)
                        return cell
                    }
                    
                    
                case 2 :
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                        cell.setHeading(title: EthosConstants.HowItWorks,backgroundColor: EthosColor.appBGColor, showBulletLine: true)
                        return cell
                    }
                    
                case 3 :
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 30,color: EthosColor.appBGColor)
                        return cell
                    }
                default : break
                    
                }
                
                
            case 1 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosBulletTableViewCellForNumber.self), for: indexPath) as? EthosBulletTableViewCellForNumber {
                    cell.index = indexPath.row + 1
                    cell.data = ArrHowItWorksTrade[safe : indexPath.row]
                    cell.contentView.backgroundColor = EthosColor.appBGColor
                    return cell
                }
                
                
            case 2 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 30, color: EthosColor.appBGColor)
                    return cell
                }
                
            case 3 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 30, color: .white)
                    return cell
                }
                
                
            case 4 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GetAQuoteTradeTableViewCell.self), for: indexPath) as? GetAQuoteTradeTableViewCell {
                    cell.delegate = self
                    cell.brandViewModel.getBrandsForFormData(site: .secondMovement)
                    return cell
                }
                
            case 5 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing()
                    return cell
                }
                
            case 6 :
                
                if self.loadingNewArrivalProducts {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.delegate = self
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.JustIn.uppercased())
                        cell.key = .forSecondMovementNewArrival
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if self.productViewModel.products.count > 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                            cell.contentView.hideSkeleton()
                            cell.collectionView.hideSkeleton()
                            cell.delegate = self
                            cell.forSecondMovement = true
                            cell.setTitle(title: EthosConstants.JustIn.uppercased())
                            cell.key = .forSecondMovementNewArrival
                            cell.productViewModel.products = self.productViewModel.products
                            cell.didGetProducts(site: nil, CategoryId: nil)
                            return cell
                        }
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2, color: .clear)
                            return cell
                        }
                    }
                }
                
                
                
                
            case 7 :
                
                if self.productViewModel.products.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing()
                        return cell
                    }} else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                            cell.setSpacing(height: 2, color: .clear)
                            return cell
                        }
                    }
                
                
            case 8 :
                
                if self.loadingArticleCategories {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.FromtheJournal.uppercased())
                        cell.key = .forReadList
                        cell.progressView.isHidden = true
                        cell.constraintBottomProgressView.constant = 0
                        cell.delegate = self
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionView.hideSkeleton()
                        cell.forSecondMovement = true
                        cell.setTitle(title: EthosConstants.FromtheJournal.uppercased())
                        cell.key = .forReadList
                        cell.progressView.isHidden = true
                        cell.constraintBottomProgressView.constant = 0
                        cell.delegate = self
                        cell.articleCategoriesViewModel.articleCategories = self.articleCategoryViewModel.articleCategories
                        cell.didGetArticleCategories(articleCategories: self.articleCategoryViewModel.articleCategories)
                        return cell
                    }
                }
                
                
                
                
            default:
                break
            }
            
        case 3 :
            
            
            switch indexPath.section {
            case 0 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SecondMovementBoutiqueHeaderTableViewCell.self)) as? SecondMovementBoutiqueHeaderTableViewCell {
                    cell.setUI()
                    return cell
                }
                
            case 1 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SecondMovementBoutiqueImagesCell.self)) as? SecondMovementBoutiqueImagesCell {
                    return cell
                }
                
            case 2 :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageTitleDescriptionTableViewCell.self)) as? ImageTitleDescriptionTableViewCell {
                    cell.data = ArrBoutiqueDescription[safe : indexPath.row]
                    cell.delegate = self
                    return cell
                }
                
            case 3 :
                if self.loadingContacts {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WhereToLocateUsTableViewCell.self)) as? WhereToLocateUsTableViewCell {
                        cell.delegate = self
                        cell.contentView.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WhereToLocateUsTableViewCell.self)) as? WhereToLocateUsTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.delegate = self
                        cell.contacts = self.contactsModel.contacts
                        return cell
                    }
                }
              
                
            default : break
                
            }
            
            
        case 4 :
            if self.loadingArticles {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as? HomeTableViewCell {
                    cell.isForPreOwn = true
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as? HomeTableViewCell {
                    cell.hideSkeleton()
                    cell.isForPreOwn = true
                    cell.article = articleViewModel.articles[safe : indexPath.section]
                    return cell
                }
            }
            
            
        default : break
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is SingleVideoTableViewCell {
            (cell as? SingleVideoTableViewCell)?.playerLayer.player?.pause()
            (cell as? SingleVideoTableViewCell)?.btnPlayPause.isHidden = false
        }
        
        if cell is VisitOurBoutiqueCell {
            (cell as? VisitOurBoutiqueCell)?.playerLayer.player?.pause()
            (cell as? VisitOurBoutiqueCell)?.btnPlayPause.isSelected = false
            (cell as? VisitOurBoutiqueCell)?.btnPlayPause.isHidden = false
        }
        
        if cell is EthosStoryCell {
            (cell as? EthosStoryCell)?.pauseVideo()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if view is AdvertisementHeaderFooterView {
            (view as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
            (view as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if selectedIndex == 4 {
            if self.adViewModel.ads.contains(where: { ad in
                ((ad.position ?? 1) - 1) == section
            }) {
                return UITableView.automaticDimension
            } else {
                return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if selectedIndex == 4 {
            if self.adViewModel.ads.contains(where: { ad in
                ((ad.position ?? 1) - 1) == section
            }) {
                let adToShow = self.adViewModel.ads.first { ad in
                    ((ad.position ?? 1) - 1) == section
                }
                
                if let ad = adToShow {
                    if let view = tableViewStory.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AdvertisementHeaderFooterView.self)) as? AdvertisementHeaderFooterView {
                        view.superTableView = self.tableViewStory
                        view.superViewController = self
                        view.advertisment = ad
                        view.delegate = self
                        return view
                    }
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if selectedIndex == 2 && section == 1 {
            let view = UIView()
            view.backgroundColor = EthosColor.appBGColor
            return view
        }
        
        if selectedIndex == 2 && section == 2 {
            let view = UIView()
            view.backgroundColor = EthosColor.appBGColor
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch selectedIndex {
        case 0 :
            if indexPath.section == 0 {
                return self.view.frame.width*47/43
            }
        case 1:
            if indexPath.section == 0 {
                return self.view.frame.width*762/430
            }
            
        default : return UITableView.automaticDimension
            
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == 4 {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                vc.isForPreOwned = true
                vc.articleId = articleViewModel.articles[safe : indexPath.section]?.id
                Mixpanel.mainInstance().trackWithLogs (
                    event: EthosConstants.ArticleClicked,
                    properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.ArticleID : self.articleViewModel.articles[safe : indexPath.section]?.id,
                        EthosConstants.ArticleTitle : self.articleViewModel.articles[safe : indexPath.section]?.title,
                        EthosConstants.ArticleCategory : self.articleViewModel.articles[safe : indexPath.section]?.category
                    ]
                )
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedIndex == 4 {
            if indexPath == IndexPath(row: 0, section: articleViewModel.articles.count - 1) {
                articleViewModel.getNewArticles(site: .secondMovement)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            if scrollView == self.tableViewStory {
                for index in tableViewStory.indexPathsForVisibleRows ?? [] {
                    if let footerView = tableViewStory?.footerView(forSection: index.section), UIApplication.topViewController() == self {
                        let rectOfCell = self.tableViewStory.rectForFooter(inSection: index.section)
                        let rectOfCellInSuperview = self.tableViewStory.convert(rectOfCell, to: self.tableViewStory.superview)
                        if rectOfCellInSuperview.origin.y < footerView.contentView.frame.height - 100, rectOfCellInSuperview.origin.y > 80  {
                            (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.play()
                            (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = true
                        } else {
                            (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
                            (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.tableViewStory {
            for index in tableViewStory.indexPathsForVisibleRows ?? [] {
                if let footerView = tableViewStory?.footerView(forSection: index.section), UIApplication.topViewController() == self {
                    let rectOfCell = self.tableViewStory.rectForFooter(inSection: index.section)
                    let rectOfCellInSuperview = self.tableViewStory.convert(rectOfCell, to: self.tableViewStory.superview)
                    if rectOfCellInSuperview.origin.y < footerView.contentView.frame.height - 100, rectOfCellInSuperview.origin.y > 50  {
                        (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.play()
                        (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = true
                    } else {
                        (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
                        (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
                    }
                }
            }
        }
    }
}

extension PreOwnedViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys {
            if key == EthosKeys.routeToArticleDetail,
               let  articleId = info?[EthosKeys.value] as? Int,
               let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                vc.articleId = articleId
                vc.isForPreOwned = true
                if let forStoryRoute = info?[EthosKeys.forStoryRoute] as? Bool {
                    vc.forStoryRoute = forStoryRoute
                    if let story = info?[EthosKeys.story] as? Banner {
                        vc.story = story
                    }
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if key == EthosKeys.route {
                if let id = info?[EthosKeys.value] as? String,
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: id) {
                    if vc is RepairAndServiceViewController {
                        (vc as? RepairAndServiceViewController)?.isForPreOwned = true
                    }
                    if vc is EthosStoreViewController {
                        (vc as? EthosStoreViewController)?.isForPreOwn = true
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if key == .requestACallBack {
                if  let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: RequestACallBackFormViewController.self)) as? RequestACallBackFormViewController {
                    vc.isforPreOwned = true
                    vc.selectedTabIndex = self.tabBarController?.selectedIndex
                    vc.screenLocation = "Pre-Owned"
                    Mixpanel.mainInstance().trackWithLogs(event: "Repair Call Back Clicked", properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        "Screen Location" : "Pre-Owned"
                    ])
                    
                    self.present(vc, animated: true)
                }
            }
            
            if key == .scheduleAPickup {
                if  let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ScheduleAPickupViewController.self)) as? ScheduleAPickupViewController {
                    vc.isforPreOwned = true
                    vc.selectedTabIndex = self.tabBarController?.selectedIndex
                    self.present(vc, animated: true)
                }
            }
            
            if key == EthosKeys.uploadImageForTradeQuote,
               let remainedCount = info?[EthosKeys.remainedCount] as? Int {
                var configuration = PHPickerConfiguration(photoLibrary: .shared())
                configuration.selectionLimit = 3 - remainedCount
                configuration.filter = .images
                configuration.selection = .ordered
                let phPicker = PHPickerViewController.init(configuration: configuration)
                phPicker.delegate = self
                phPicker.modalPresentationStyle = .fullScreen
                self.present(phPicker, animated: true)
            }
            
            if key == .showAlert, let title = info?[EthosKeys.alerTitle] as? String, let message = info?[EthosKeys.alertMessage] as? String {
                self.showAlertWithSingleTitle(title: title, message: message)
            }
            
            if key == EthosKeys.uploadImageForSellQuote,
               let remainedCount = info?[EthosKeys.remainedCount] as? Int {
                var configuration = PHPickerConfiguration(photoLibrary: .shared())
                configuration.selectionLimit = 3 - remainedCount
                configuration.filter = .images
                configuration.selection = .ordered
                let phPicker = PHPickerViewController.init(configuration: configuration)
                phPicker.delegate = self
                phPicker.modalPresentationStyle = .fullScreen
                self.present(phPicker, animated: true)
            }
            
            if key == EthosKeys.openWebPage {
                if let strUrl = info?[EthosKeys.url] as? String {
                    UserActivityViewModel().getDataFromActivityUrl(url: strUrl)
                }
            }
            
            if key == EthosKeys.updateView {
                if info?[EthosKeys.value] as? PreOwnTabsKey == .sell {
                    self.btnTabDidTapped(self.btnSell)
                }
                if info?[EthosKeys.value] as? PreOwnTabsKey == .trade {
                    self.btnTabDidTapped(self.btnTrade)
                }
            }
            
            if key == EthosKeys.routeToProductDetails,
               let product = info?[EthosKeys.value] as? Product {
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
            }
            
            if key == EthosKeys.routeToProductDetails,
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
            
            if key == EthosKeys.routeToProductDetails,
               let productId = info?[EthosKeys.value] as? String {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = productId
                    if let forStoryRoute = info?[EthosKeys.forStoryRoute] as? Bool {
                        vc.forStoryRoute = forStoryRoute
                        if let story = info?[EthosKeys.story] as? Banner {
                            vc.story = story
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if key == EthosKeys.routeToProducts,
               let categoryId = info?[EthosKeys.categoryId] as? Int,
               let categoryName = info?[EthosKeys.categoryName] as? String {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                    vc.productViewModel.categoryName = categoryName
                    vc.isForPreOwned = true
                    vc.productViewModel.categoryId = categoryId
                    
                    if categoryId == 6 {
                        switch Userpreference.smJustINSort ?? "" {
                        case "New Arrival" :  vc.productViewModel.selectedSortBy = EthosConstants.NewArrivals.uppercased()
                        case "Best Selling" :  vc.productViewModel.selectedSortBy = EthosConstants.bestSeller.uppercased()
                        case "Price High to Low" :  vc.productViewModel.selectedSortBy = EthosConstants.priceHighToLow.uppercased()
                        case "Price Low to High": vc.productViewModel.selectedSortBy = EthosConstants.priceLowToHigh.uppercased()
                        default:
                            break
                        }
                        
                    }
                    
                    if let filters = info?[EthosKeys.filters] as? [FilterModel] {
                        vc.productViewModel.selectedFilters = filters
                    }
                    
                    if let forStoryRoute = info?[EthosKeys.forStoryRoute] as? Bool {
                        vc.forStoryRoute = forStoryRoute
                        if let story = info?[EthosKeys.story] as? Banner {
                            vc.story = story
                        }
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if key == EthosKeys.reloadHeightOfTableView {
                self.tableViewStory.beginUpdates()
                self.tableViewStory.endUpdates()
            }
            
            if key == EthosKeys.reloadTableView {
                self.tableViewStory.reloadData()
            }
            
            if key == EthosKeys.visitArticles {
                UIView.animate(withDuration: 0.5 , animations : {
                    self.tableViewStory.contentOffset = .zero
                }) {_ in
                    self.selectedIndex = 4
                    self.tableViewStory.reloadData()
                }
            }
            
            if key == EthosKeys.visitProducts {
                UIView.animate(withDuration: 0.5 , animations : {
                    self.tableViewStory.contentOffset = .zero
                }) {_ in
                    self.selectedIndex = 0
                    self.tableViewStory.reloadData()
                }
            }
            
            if key == .search,
               let str =  info?[EthosKeys.value] as? String {
                self.searchKeyWords = str
                self.view.endEditing(true)
                DispatchQueue.main.async {
                    self.tableViewStory.reloadData()
                }
            }
            
            if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToArticleList,
               let value = info?[EthosKeys.value] as? HorizontalCollectionKey {
                
                switch value {
                case .forReadList :
                    
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                        vc.isForPreOwn = true
                        vc.key = .readListCategory
                        if let category = info?[EthosKeys.category] as? ArticlesCategory {
                            vc.articleCategory = category
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                case .forArticle:
                    if let categoryKey = info?[EthosKeys.category] as? ArticleCategory {
                        switch categoryKey {
                        case .curatedList:
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                                vc.isForPreOwn = true
                                vc.key = .curatedList
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        case .trending:
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                                vc.isForPreOwn = true
                                vc.key = .trending
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                        case .revolution:
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                                vc.isForPreOwn = true
                                vc.key = .revolution
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                        case .editorsPicks:
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                                vc.isForPreOwn = true
                                vc.key = .editorsPicks
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                        case .featuredVideo:
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                                vc.isForPreOwn = true
                                vc.key = .featuredVideos
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                case .forStore:
                    break
                case .forPreOwnedPicks:
                    break
                case .forstaffPicks:
                    break
                case .forSimilarWatches:
                    break
                case .forBrandArticle:
                    break
                case .forFeaturedWatches:
                    break
                case .forSecondMovementNewArrival:
                    break
                case .forBetterTogether:
                    break
                case .forRecentProducts:
                    break
                case .forSMNewArrivalProductDetails:
                    break
                case .forShopThisLook:
                    break
                }
            }
            
            if key == .visitOurBoutique {
                UIView.animate(withDuration: 0.5 , animations : {
                    self.tableViewStory.contentOffset = .zero
                }) {_ in
                    self.selectedIndex = 3
                    self.tableViewStory.reloadData()
                }
            }
        }
    }
}

extension PreOwnedViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            let imageItems = results
                .map { $0.itemProvider }
                .filter { $0.canLoadObject(ofClass: UIImage.self) }
            
            let dispatchGroup = DispatchGroup()
            var images = [UIImage]()
            for imageItem in imageItems {
                dispatchGroup.enter()
                imageItem.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        images.append(image)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                if self.selectedIndex == 2 ,
                   let cell = self.tableViewStory.cellForRow(at: IndexPath(row: 0, section: 4)) as? GetAQuoteTradeTableViewCell {
                    cell.arrImages.append(contentsOf: images)
                }
                
                if self.selectedIndex == 1 ,
                   let cell = self.tableViewStory.cellForRow(at: IndexPath(row: 0, section: 14)) as? GetAQuoteTableViewCell {
                    cell.arrImages.append(contentsOf: images)
                }
            }
        }
    }
}

extension PreOwnedViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        self.loadingArticles = false
    }
    
    func errorInGettingArticles(error: String) {
        self.loadingArticles = false
    }
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
    
    func startFooterIndicator() {
        DispatchQueue.main.async {
            self.indicatorFooter.startAnimating()
        }
    }
    
    func stopFooterIndicator() {
        DispatchQueue.main.async {
            self.indicatorFooter.stopAnimating()
        }
    }
}

extension PreOwnedViewController : GetProductViewModelDelegate {
    func didGetProducts(site : Site?, CategoryId : Int?) {
        if CategoryId == 6 && site == .secondMovement {
            self.loadingNewArrivalProducts = false
        } else if CategoryId == 22 && site == .secondMovement {
            self.loadingStaffPicks = false
        }
    }
    
    func errorInGettingProducts(error: String) {
        self.loadingNewArrivalProducts = false
        self.loadingStaffPicks = false
    }
    
    func didGetProductDetails(details: Product) {}
    
    func failedToGetProductDetails() {}
    
    func didGetFilters() {}
    
    func errorInGettingFilters() {}
}

extension PreOwnedViewController : GetBannersViewModelDelegate {
    func didGetBanners(banners: [Banner]) {
        self.loadingBanners = false
    }
}

extension PreOwnedViewController : ContactUsViewModelDelegate {
    
    func didGetContacts(json: [String : Any], site: Site) {
        self.loadingContacts = false
    }
    
    func requestSuccess(message: String) {
        
    }
    
    func requestFailure(error: String) {
        
    }
}

extension PreOwnedViewController : GetArticleCategoriesViewModelDelegate {
    func didGetArticleCategories(articleCategories: [ArticlesCategory]) {
        self.loadingArticleCategories = false
    }
}
