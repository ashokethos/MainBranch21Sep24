//
//  DiscoverViewController.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import Mixpanel
import SkeletonView

class DiscoverViewController: UIViewController {
    
    @IBOutlet weak var tableViewDiscover: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var lblNumberOfNotifications: UILabel!
    
    let refreshControl = UIRefreshControl()
    var bannerViewModel = GetBannersViewModel()
    var trendingArticleViewModel = GetArticlesViewModel()
    var curatedListArticleViewModel = GetArticlesViewModel()
    var editorsPicksArticleViewModel = GetArticlesViewModel()
    var featuredVideoArticleViewModel = GetArticlesViewModel()
    var readListArticleViewModel = GetArticleCategoriesViewModel()
    var watchGlossaryViewModel = GetGlossaryViewModel()
    let viewArticleModel = GetArticlesViewModel()
    
    var revolutionDataArr = [GetRevolutionData]()
    
    var loadingBannners : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 0 {
                    self.tableViewDiscover?.reloadSections([0], with: .automatic)
                }
                
            }
        }
    }
    
    var loadingTrendingArticles : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 1 {
                    self.tableViewDiscover?.reloadSections([1], with: .automatic)
                }
            }
        }
    }
    
    
    var loadingRevolution : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 2 {
                    if self.viewArticleModel.articles.count > 0{
                        self.tableViewDiscover?.reloadSections([2], with: .none)
                    }
                }
            }
        }
    }
    
    var loadingEditorsPicks : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 3 {
                    self.tableViewDiscover?.reloadSections([3], with: .automatic)
                }
            }
        }
    }
    
    var  loadingFeaturedVideoArticles : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 4 {
                    self.tableViewDiscover?.reloadSections([4], with: .automatic)
                }
            }
        }
    }
    
    var loadingCuratedList : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 5 {
                    self.tableViewDiscover?.reloadSections([5], with: .automatic)
                }
            }
        }
    }
    
    var loadingReadListArticles : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 6 {
                    self.tableViewDiscover?.reloadSections([6], with: .automatic)
                }
            }
        }
    }
    
    var loadingWatchGlossary : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewDiscover?.numberOfSections ?? 0 > 8 {
                    self.tableViewDiscover?.reloadSections([7, 8,9], with: .automatic)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateNotificationCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for cell in tableViewDiscover?.visibleCells ?? [] {
            if cell is EthosStoryCell {
                (cell as? EthosStoryCell)?.pauseVideo()
            }
            
            
            if  cell is FeaturedVideoTableViewCell {
                (cell as? FeaturedVideoTableViewCell)?.pauseVideo()
            }
        }
        
    }
    
    func setup() {
        bannerViewModel.delegate = self
        trendingArticleViewModel.delegate = self
        curatedListArticleViewModel.delegate = self
        editorsPicksArticleViewModel.delegate = self
        featuredVideoArticleViewModel.delegate = self
        readListArticleViewModel.delegate = self
        watchGlossaryViewModel.delegate = self
        viewArticleModel.delegate = self
        
        self.addRefreshControl()
        self.addTapGestureToDissmissKeyBoard()
        self.tableViewDiscover.registerCell(className: EthosStoryCell.self)
        self.tableViewDiscover.registerCell(className: WatchGlossaryTableViewHeaderCell.self)
        self.tableViewDiscover.registerCell(className: GlossaryDescriptionCell.self)
        self.tableViewDiscover.registerCell(className: HorizontalCollectionTableViewCell.self)
        self.tableViewDiscover.registerCell(className: FeaturedVideoTableViewCell.self)
        self.tableViewDiscover.registerCell(className: WatchGlossaryTableViewCell.self)
        self.tableViewDiscover.registerCell(className: SpacingTableViewCell.self)
        self.tableViewDiscover.registerCell(className: SingleButtonTableViewCell.self)
        self.tableViewDiscover.registerCell(className: RevolutionTableViewHeaderCell.self)
        self.tableViewDiscover.registerCell(className: RevolutionReviewTableViewCell.self)
        
        self.lblNumberOfNotifications.setBorder(borderWidth: 0, borderColor: .clear, radius: 7.5)
        NotificationCenter.default.addObserver(forName:  NSNotification.Name("receivedNotification"), object: nil, queue: nil) { notification in
            self.updateNotificationCount()
        }
        startApiRequests()
    }
    
    func startApiRequests() {
        bannerViewModel.getBanners(key: .discover)
        trendingArticleViewModel.getArticles(category: ArticleCategory.trending.rawValue)
        curatedListArticleViewModel.getArticles(category: ArticleCategory.curatedList.rawValue)
        viewArticleModel.getArticles(category: ArticleCategory.revolution.rawValue, site: .ethos, forViewAll: false)
        editorsPicksArticleViewModel.getArticles(category: ArticleCategory.editorsPicks.rawValue)
        featuredVideoArticleViewModel.getArticles(featuredVideo: true)
        readListArticleViewModel.getArticleCategories(site: .ethos)
        watchGlossaryViewModel.getGlossaryData(site: .ethos)
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.tableViewDiscover.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        self.loadingBannners = true
        self.loadingRevolution = true
        self.loadingWatchGlossary = true
        self.loadingBannners = true
        self.loadingEditorsPicks = true
        self.loadingTrendingArticles = true
        self.loadingReadListArticles = true
        self.loadingFeaturedVideoArticles = true
        
        self.startApiRequests()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.tableViewDiscover.refreshControl?.endRefreshing()
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
            
            let properties : Dictionary<String, any MixpanelType> = [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.Screen : EthosConstants.Discover
            ]
            
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.NotificationsClicked , properties: properties)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func viewAllBtnAction(sender: UIButton){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
            //            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
            vc.isForPreOwn = false
            //            }
            
            Mixpanel.mainInstance().track(event: "Revolution Articles Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS
            ])
            
            vc.key = .revolution
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func instagramBtnAction(sender: UIButton){
        let appURL = URL(string: "https://www.instagram.com/revolution.watch/")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        }
    }
    
    @objc func websiteBtnAction(sender: UIButton){
        let appURL = URL(string: "https://revolutionwatch.com/")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
            application.open(appURL)
        }
    }
    
    
}

extension DiscoverViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            if viewArticleModel.articles.count > 5{
                return 6
            }else{
                if viewArticleModel.articles.count == 0{
                    return 1
                }else{
                    return 1 + viewArticleModel.articles.count
                }
            }
        }else if section == 8 {
            if self .loadingWatchGlossary {
                return 4
            } else {
                if watchGlossaryViewModel.glossary.count > 0{
                    if watchGlossaryViewModel.selectedIndex < watchGlossaryViewModel.glossary.count {
                        return self.watchGlossaryViewModel.glossary[watchGlossaryViewModel.selectedIndex].data.count
                    } else {
                        return 0
                    }
                }else{
                    return 0
                }
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0 :
            if self.loadingBannners {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoryCell.self), for: indexPath) as? EthosStoryCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionViewStories.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if self.bannerViewModel.banners.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoryCell.self), for: indexPath) as? EthosStoryCell {
                        
                        cell.contentView.hideSkeleton()
                        cell.collectionViewStories.hideSkeleton()
                        cell.isforPreOwned = false
                        cell.delegate = self
                        cell.superTableView = self.tableViewDiscover
                        cell.viewModel = self.bannerViewModel
                        cell.didGetBanners(banners: self.bannerViewModel.banners)
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
            
        case 1 :
            
            if loadingTrendingArticles {
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                    cell.key = .forArticle
                    cell.articleKey = .trending
                    cell.progressView.isHidden = true
                    cell.constraintTopProgressView.constant = 0
                    cell.constraintBottomProgressView.constant = 0
                    cell.progressView.isHidden = true
                    cell.collectionView.showAnimatedGradientSkeleton()
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
                
            } else {
                if self.trendingArticleViewModel.articles.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = false
                        
                        cell.key = .forArticle
                        cell.articleKey = .trending
                        cell.delegate = self
                        cell.articleViewModel.articles = self.trendingArticleViewModel.articles
                        cell.collectionView.reloadData()
                        cell.updateProgressView()
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintBottomProgressView.constant = 0
                        cell.progressView.isHidden = true
                        cell.constraintHeightBottomSeperator.constant = ((self.editorsPicksArticleViewModel.articles.count > 0) ? 8 : 0)
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
        case 2:
            if loadingRevolution{
//                if indexPath.section == 2{
                    if indexPath.row == 0 {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RevolutionTableViewHeaderCell.self)) as? RevolutionTableViewHeaderCell {
                            cell.showAnimatedGradientSkeleton()
                            cell.viewAllBtn.tag = indexPath.row
                            cell.viewAllBtn.addTarget(self, action: #selector(viewAllBtnAction), for: .touchUpInside)
                            cell.instagramBtn.tag = indexPath.row
                            cell.instagramBtn.addTarget(self, action: #selector(instagramBtnAction), for: .touchUpInside)
                            cell.websiteBtn.tag = indexPath.row
                            cell.websiteBtn.addTarget(self, action: #selector(websiteBtnAction), for: .touchUpInside)
                            cell.titleLbl.setAttributedTitleWithProperties(
                                title: "Revolution",
                                font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), foregroundColor: .white,
                                lineHeightMultiple: 1.25,
                                kern: 0.1
                            )
                            cell.websiteLbl.setAttributedTitleWithProperties(
                                title: "www.revolutionwatch.com",
                                font: EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14), foregroundColor: .white,
                                lineHeightMultiple: 1.25,
                                kern: 0.1
                            )
                            cell.descriptionLbl.setAttributedTitleWithProperties(
                                title: "Revolution is one of the world's leading watch magazines. In an exclusive partnership, we are presenting a selection of their stories on The Watch Guide by Ethos.",
                                font: EthosFont.Brother1816Regular(size: 13), foregroundColor: .white,
                                lineHeightMultiple: 0.5,
                                kern: 0.1
                            )
                            cell.instagramBtnLbl.setAttributedTitleWithProperties(
                                title: "Instagram",
                                font: EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14), foregroundColor: .white,
                                lineHeightMultiple: 1.25,
                                kern: 0.1
                            )
                            return cell
                        }
                    }else{
                        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RevolutionReviewTableViewCell.self)) as? RevolutionReviewTableViewCell {
                            if viewArticleModel.articles.count > 0{
                                if let url = URL(string: (viewArticleModel.articles[indexPath.row - 1].topFeaturedImage ?? "")) {
                                    cell.revolutionImg.kf.setImage(with: url)
                                }
                                cell.reviewLbl.setAttributedTitleWithProperties(
                                    title: viewArticleModel.articles[indexPath.row - 1].category?.uppercased() ?? "",
                                    font: EthosFont.Brother1816Regular(size: 10),
                                    foregroundColor: EthosColor.red,
                                    kern: 0.5
                                )
                                cell.reviewTitleLbl.numberOfLines = 3
                                cell.reviewTitleLbl.setAttributedTitleWithProperties(
                                    title: viewArticleModel.articles[indexPath.row - 1].title ?? "",
                                    font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18),
                                    lineHeightMultiple: 1.25,
                                    kern: 0.1
                                )
                                if let createdDate = viewArticleModel.articles[indexPath.row - 1].createdDate {
                                    let strCreatedDate = EthosDateAndTimeHelper().getStringFromTimeStamp(timeStamp:createdDate)
                                    cell.dateLbl.setAttributedTitleWithProperties(
                                        title: strCreatedDate,
                                        font: EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14),
                                        foregroundColor: EthosColor.darkGrey,
                                        lineHeightMultiple: 1.43,
                                        kern: 0.1
                                    )
                                }
                                
                                if indexPath.row == viewArticleModel.articles.count{
                                    cell.bottomLineView.isHidden = true
                                    cell.setSpacing(height: 9, color: UIColor.init(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0000))
                                }else{
                                    cell.bottomLineView.isHidden = false
                                    cell.setSpacing(height: 0, color: .clear)
                                }
                            }
                            
                            return cell
                        }
                    }
//                }
            }
        case 3 :
            
            if loadingEditorsPicks {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                    cell.key = .forArticle
                    cell.articleKey = .editorsPicks
                    cell.constraintTopProgressView.constant = 0
                    cell.constraintTopProgressView.constant = 0
                    cell.constraintBottomProgressView.constant = 0
                    cell.progressView.isHidden = true
                    cell.collectionView.showAnimatedGradientSkeleton()
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            }  else {
                if self.editorsPicksArticleViewModel.articles.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = false
                      
                        cell.key = .forArticle
                        cell.articleKey = .editorsPicks
                        cell.delegate = self
                        cell.articleViewModel.articles = self.editorsPicksArticleViewModel.articles
                        cell.collectionView.reloadData()
                        cell.updateProgressView()
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintBottomProgressView.constant = 0
                        cell.progressView.isHidden = true
                        cell.constraintHeightBottomSeperator.constant = (self.featuredVideoArticleViewModel.articles.count > 0) ? 0 : 8
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
            
        case 4 :
            if loadingFeaturedVideoArticles {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeaturedVideoTableViewCell.self), for: indexPath) as? FeaturedVideoTableViewCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionViewFeaturedVideos.showAnimatedGradientSkeleton()
                    cell.lblHeading.setAttributedTitleWithProperties(
                        title: EthosConstants.FeaturedVideoArticle.uppercased(),
                        font: EthosFont.Brother1816Medium(size: 12),
                        foregroundColor: .white,
                        kern: 1
                    )
                    
                    DispatchQueue.main.async {
                        cell.pageControl.numberOfPages = cell.viewModel.articles.count
                        cell.collectionViewFeaturedVideos.reloadData()
                    }
                    
                    return cell
                }
            } else {
                if featuredVideoArticleViewModel.articles.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeaturedVideoTableViewCell.self), for: indexPath) as? FeaturedVideoTableViewCell {
                        cell.lblHeading.setAttributedTitleWithProperties(
                            title: EthosConstants.FeaturedVideoArticle.uppercased(),
                            font: EthosFont.Brother1816Medium(size: 12),
                            foregroundColor: .white,
                            kern: 1
                        )
                        
                        cell.delegate = self
                        cell.viewModel.articles = self.featuredVideoArticleViewModel.articles
                        
                        DispatchQueue.main.async {
                            cell.pageControl.numberOfPages = cell.viewModel.articles.count
                            cell.collectionViewFeaturedVideos.reloadData()
                        }
                        
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
        case 5 :
            if loadingCuratedList {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                    cell.key = .forArticle
                    cell.articleKey = .curatedList
                    cell.constraintTopProgressView.constant = 0
                    cell.constraintBottomProgressView.constant = 0
                    cell.constraintTopProgressView.constant = 0
                    cell.progressView.isHidden = true
                    cell.constraintHeightBottomSeperator.constant = 8
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if curatedListArticleViewModel.articles.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionView.hideSkeleton()
                        cell.forSecondMovement = false
                        
                        cell.key = .forArticle
                        cell.articleKey = .curatedList
                        cell.delegate = self
                        cell.articleViewModel.articles = self.curatedListArticleViewModel.articles
                        cell.collectionView.reloadData()
                        cell.updateProgressView()
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintBottomProgressView.constant = 0
                        cell.constraintTopProgressView.constant = 0
                        cell.progressView.isHidden = true
                        cell.constraintHeightBottomSeperator.constant = 8
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
        case 6 :
            
            if loadingReadListArticles {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                    cell.key = .forReadList
                    cell.setTitle(title: EthosConstants.ReadingLists.uppercased())
                    cell.constraintTopProgressView.constant = 0
                    cell.constraintBottomProgressView.constant = 40
                    cell.constraintHeightBottomSeperator.constant = 8
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionView.showAnimatedGradientSkeleton()
                    cell.progressView.isHidden = true
                    return cell
                }
            } else {
                if self.readListArticleViewModel.articleCategories.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self), for: indexPath) as? HorizontalCollectionTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionView.hideSkeleton()
                        cell.forSecondMovement = false
                        cell.setTitle(title: EthosConstants.ReadingLists.uppercased())
                        cell.delegate = self
                        cell.key = .forReadList
                        cell.progressView.isHidden = true
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintBottomProgressView.constant = 40
                        cell.constraintHeightBottomSeperator.constant = 8
                        cell.articleCategoriesViewModel.articleCategories = self.readListArticleViewModel.articleCategories
                        cell.didGetArticleCategories(articleCategories: self.readListArticleViewModel.articleCategories)
                        
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
        case 7 :
            if loadingWatchGlossary {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WatchGlossaryTableViewHeaderCell.self), for: indexPath) as? WatchGlossaryTableViewHeaderCell {
                    cell.collectionViewLetters.dataSource = self
                    cell.collectionViewLetters.delegate = self
                    cell.collectionViewLetters.reloadData()
                    cell.collectionViewLetters.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if self.watchGlossaryViewModel.selectedIndex < self.watchGlossaryViewModel.glossary.count {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WatchGlossaryTableViewHeaderCell.self), for: indexPath) as? WatchGlossaryTableViewHeaderCell {
                        cell.collectionViewLetters.dataSource = self
                        cell.collectionViewLetters.delegate = self
                        cell.collectionViewLetters.reloadData()
                        if self.watchGlossaryViewModel.glossary.count > 0{
                            cell.lblSelectedLetter.setAttributedTitleWithProperties(title: self.watchGlossaryViewModel.glossary[watchGlossaryViewModel.selectedIndex].header.uppercased(), font: EthosFont.Brother1816Medium(size: 12))
                        }
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
        case 8 :
            if loadingWatchGlossary {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GlossaryDescriptionCell.self)) as? GlossaryDescriptionCell {
                    cell.lblTitle.skeletonTextNumberOfLines = 1
                    cell.lblDescription.skeletonTextNumberOfLines = 2
                    cell.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
                    cell.lblDescription.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
                    cell.lblDescription.skeletonLineSpacing = 10
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if self.watchGlossaryViewModel.selectedIndex < self.watchGlossaryViewModel.glossary.count {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GlossaryDescriptionCell.self)) as? GlossaryDescriptionCell {
                        if watchGlossaryViewModel.glossary.count > 0{
                            cell.element = watchGlossaryViewModel.glossary[watchGlossaryViewModel.selectedIndex].data[safe : indexPath.row]
                        }
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
            
        case 9 :
            if loadingWatchGlossary {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SingleButtonTableViewCell.self)) as? SingleButtonTableViewCell {
                    cell.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if self.watchGlossaryViewModel.selectedIndex < self.watchGlossaryViewModel.glossary.count {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SingleButtonTableViewCell.self)) as? SingleButtonTableViewCell {
                        cell.action = {
                            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosTableViewController.self)) as? EthosTableViewController {
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                            
                            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.watchGlossaryClicked, properties: [
                                EthosConstants.Email : Userpreference.email,
                                EthosConstants.UID : Userpreference.userID,
                                EthosConstants.Gender : Userpreference.gender,
                                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                                EthosConstants.Platform : EthosConstants.IOS
                            ])
                            
                        }
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2, color: .clear)
                        return cell
                    }
                }
            }
            
            
        default: return UITableViewCell()
            
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2{
            if indexPath.row != 0{
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                    vc.isForPreOwned = false
                    vc.articleId = viewArticleModel.articles[indexPath.row - 1].id
                    Mixpanel.mainInstance().track(event: EthosConstants.ArticleClicked, properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.ArticleID : viewArticleModel.articles[indexPath.row - 1].id,
                        EthosConstants.ArticleTitle : viewArticleModel.articles[indexPath.row - 1].title,
                        EthosConstants.ArticleCategory : viewArticleModel.articles[indexPath.row - 1].category
                    ])
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if indexPath.section == 8 {
            if self.watchGlossaryViewModel.glossary.count > self.watchGlossaryViewModel.selectedIndex {
                self.watchGlossaryViewModel.glossary[self.watchGlossaryViewModel.selectedIndex].data[indexPath.row].isExpanded = !self.watchGlossaryViewModel.glossary[self.watchGlossaryViewModel.selectedIndex].data[indexPath.row].isExpanded
                self.tableViewDiscover.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.view.frame.width*47/43
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is EthosStoryCell {
            (cell as? EthosStoryCell)?.pauseVideo()
        }
        
        if cell is FeaturedVideoTableViewCell {
            (cell as? FeaturedVideoTableViewCell)?.pauseVideo()
        }
    }
}

extension DiscoverViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.reloadHeightOfTableView {
            self.tableViewDiscover.beginUpdates()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.tableViewDiscover.endUpdates()
            }
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToArticleList,
           let value = info?[EthosKeys.value] as? HorizontalCollectionKey {
            switch value {
            case .forReadList :
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                    vc.key = .readListCategory
                    if let category = info?[EthosKeys.category] as? ArticlesCategory {
                        if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                            vc.isForPreOwn = forSecondMovement
                        }
                        vc.articleCategory = category
                        
                        Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ReadingListsViewed, properties: [
                            EthosConstants.Email : Userpreference.email,
                            EthosConstants.UID : Userpreference.userID,
                            EthosConstants.Gender : Userpreference.gender,
                            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                            EthosConstants.Platform : EthosConstants.IOS,
                            EthosConstants.ListType : category.name
                        ])
                        
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case .forArticle:
                if let categoryKey = info?[EthosKeys.category] as? ArticleCategory {
                    switch categoryKey {
                    case .curatedList:
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                                vc.isForPreOwn = forSecondMovement
                            }
                            
                            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.CuratedListClicked, properties: [
                                EthosConstants.Email : Userpreference.email,
                                EthosConstants.UID : Userpreference.userID,
                                EthosConstants.Gender : Userpreference.gender,
                                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                                EthosConstants.Platform : EthosConstants.IOS
                            ])
                            
                            vc.key = .curatedList
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    case .trending:
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                                vc.isForPreOwn = forSecondMovement
                            }
                            
                            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.TrendingArticlesClicked, properties: [
                                EthosConstants.Email : Userpreference.email,
                                EthosConstants.UID : Userpreference.userID,
                                EthosConstants.Gender : Userpreference.gender,
                                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                                EthosConstants.Platform : EthosConstants.IOS
                            ])
                            
                            vc.key = .trending
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    case .revolution:
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                                vc.isForPreOwn = forSecondMovement
                            }
                            
                            Mixpanel.mainInstance().track(event: "Revolution Articles Clicked", properties: [
                                EthosConstants.Email : Userpreference.email,
                                EthosConstants.UID : Userpreference.userID,
                                EthosConstants.Gender : Userpreference.gender,
                                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                                EthosConstants.Platform : EthosConstants.IOS
                            ])
                            
                            vc.key = .revolution
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                        
                    case .editorsPicks:
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                                vc.isForPreOwn = forSecondMovement
                            }
                            
                            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.EditorsPickClicked, properties: [
                                EthosConstants.Email : Userpreference.email,
                                EthosConstants.UID : Userpreference.userID,
                                EthosConstants.Gender : Userpreference.gender,
                                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                                EthosConstants.Platform : EthosConstants.IOS
                            ])
                            vc.key = .editorsPicks
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    case .featuredVideo:
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleListTableViewController.self)) as? ArticleListTableViewController {
                            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                                vc.isForPreOwn = forSecondMovement
                            }
                            
                            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.FeatureVideoArticlesClicked, properties: [
                                EthosConstants.Email : Userpreference.email,
                                EthosConstants.UID : Userpreference.userID,
                                EthosConstants.Gender : Userpreference.gender,
                                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                                EthosConstants.Platform : EthosConstants.IOS
                            ])
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
        
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToArticleDetail,
           let  articleId = info?[EthosKeys.value] as? Int,
           let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
            vc.articleId = articleId
            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                vc.isForPreOwned = forSecondMovement
            }
            
            if let forStoryRoute = info?[EthosKeys.forStoryRoute] as? Bool {
                vc.forStoryRoute = forStoryRoute
                if let story = info?[EthosKeys.story] as? Banner {
                    vc.story = story
                }
            }
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToProducts,
           let categoryId = info?[EthosKeys.categoryId] as? Int,
           let categoryName = info?[EthosKeys.categoryName] as? String {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                vc.productViewModel.categoryName = categoryName
                vc.productViewModel.categoryId = categoryId
                
                if let filters = info?[EthosKeys.filters] as? [FilterModel] {
                    vc.productViewModel.selectedFilters = filters
                }
                
                if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                    vc.isForPreOwned = forSecondMovement
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
        
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.route,
           let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosTableViewController.self)) as? EthosTableViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension DiscoverViewController : GetBannersViewModelDelegate {
    func didGetBanners(banners: [Banner]) {
        self.loadingBannners = false
    }
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
}

extension DiscoverViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        switch category {
        case ArticleCategory.trending.rawValue :
            self.loadingTrendingArticles = false
        case ArticleCategory.revolution.rawValue :
            self.loadingRevolution = true
        case ArticleCategory.editorsPicks.rawValue :
            self.loadingEditorsPicks = false
        case ArticleCategory.curatedList.rawValue :
            self.loadingCuratedList = false
        default:
            if featuredVideo == true {
                self.loadingFeaturedVideoArticles = false
            }
        }
    }
    
    func errorInGettingArticles(error: String) {
        
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
    
    
}

extension DiscoverViewController : GetArticleCategoriesViewModelDelegate {
    func didGetArticleCategories(articleCategories: [ArticlesCategory]) {
        self.loadingReadListArticles = false
    }
}


extension DiscoverViewController : GetGlossaryViewModelDelegate {
    func didGetGlossary() {
        self.loadingWatchGlossary = false
    }
}

extension DiscoverViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if watchGlossaryViewModel.glossary.count > 0{
            return watchGlossaryViewModel.glossary.count
        }else{
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DiscoveryTabsCell.self), for: indexPath) as? DiscoveryTabsCell {
            cell.hideSkeleton()
            if watchGlossaryViewModel.selectedIndex == indexPath.item {
                cell.viewIndicator.backgroundColor = .black
                cell.lblTitle.font = EthosFont.Brother1816Bold(size: 10)
            } else {
                cell.viewIndicator.backgroundColor = .clear
                cell.lblTitle.font = EthosFont.Brother1816Regular(size: 10)
            }
            
            if watchGlossaryViewModel.glossary.count > 0{
                cell.lblTitle.text = watchGlossaryViewModel.glossary[indexPath.item].header.uppercased()
            }
            cell.constraintHeightIndicator.constant = 1
            cell.lblTitle.textColor = .black
            cell.lblTitle.backgroundColor = .clear
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        watchGlossaryViewModel.selectedIndex = indexPath.item
        self.tableViewDiscover.reloadData()
    }
}

extension DiscoverViewController : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return String(describing: DiscoveryTabsCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: DiscoveryTabsCell.self), for: indexPath) as? DiscoveryTabsCell {
            cell.viewIndicator.backgroundColor = .clear
            cell.lblTitle.skeletonTextNumberOfLines = 1
            cell.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
            
            cell.lblTitle.font = EthosFont.Brother1816Regular(size: 10)
            cell.lblTitle.text = "A"
            cell.constraintHeightIndicator.constant = 1
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            cell.contentView.showAnimatedGradientSkeleton()
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    
}
