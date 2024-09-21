//
//  ShopViewController.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import Mixpanel
import SkeletonView

class ShopViewController: UIViewController {
    
    @IBOutlet weak var tableViewShopping: EthosContentSizedTableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var lblNumberOfNotifications: UILabel!
    
    var productViewModel = GetProductViewModel()
    
    var preOwnedpicksProductViewModel = GetProductViewModel()
    
    var categoryViewModel = GetCategoryViewModel()
    
    let bannerViewModel = GetBannersViewModel()
    
    var storeViewModel = GetStoreViewModel()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        callApi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewShopping.setContentOffset(.zero, animated: true)
        updateNotificationCount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let cell = self.tableViewShopping?.cellForRow(at: IndexPath(row: 0, section: 0)) as? EthosStoryCell {
            cell.pauseVideo()
        }
    }
    
    var loadingBanners : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewShopping?.numberOfSections ?? 0 > 0 {
                    self.tableViewShopping?.reloadSections([0], with: .automatic)
                }
            }
        }
    }
    
    var loadingCategories : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewShopping?.numberOfSections ?? 0 > 4 {
                    self.tableViewShopping?.reloadSections([4], with: .automatic)
                }
            }
        }
    }
    
    var loadingNewArrivals : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewShopping?.numberOfSections ?? 0 > 9 {
                    self.tableViewShopping?.reloadSections([9], with: .automatic)
                }
            }
        }
    }
    
    var loadingPreOwnedPicks : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewShopping?.numberOfSections ?? 0 > 13 {
                    self.tableViewShopping?.reloadSections([13], with: .automatic)
                }
            }
        }
    }
    
    var loadingBoutiques : Bool = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewShopping?.numberOfSections ?? 0 > 7 {
                    self.tableViewShopping?.reloadSections([7], with: .automatic)
                }
            }
        }
    }
    
    
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.tableViewShopping.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        self.loadingBanners = true
        self.loadingBoutiques = true
        self.loadingCategories = true
        self.loadingNewArrivals = true
        self.loadingPreOwnedPicks = true
        callApi()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.tableViewShopping.refreshControl?.endRefreshing()
        }
    }
    
    func callApi() {
        bannerViewModel.getBanners(key: .shop)
        categoryViewModel.getCategories(site: Site.ethos)
        storeViewModel.getNewBoutiques(site: .ethos)
        
        
        switch Userpreference.ethosJustINSort ?? "" {
        case "New Arrival" :
            self.productViewModel.initiate(id: 144, limit: 10, selectedSortBy: EthosConstants.NewArrivals.uppercased()) {
                self.productViewModel.getProductsFromCategory(site: .ethos)
            }
        case "Best Selling" : 
            self.productViewModel.initiate(id: 144, limit: 10, selectedSortBy: EthosConstants.bestSeller.uppercased()) {
            self.productViewModel.getProductsFromCategory(site: .ethos)
        }
        case "Price High to Low" : 
            self.productViewModel.initiate(id: 144, limit: 10, selectedSortBy: EthosConstants.priceHighToLow.uppercased()) {
            self.productViewModel.getProductsFromCategory(site: .ethos)
        }
        case "Price Low to High":
            self.productViewModel.initiate(id: 144, limit: 10, selectedSortBy: EthosConstants.priceLowToHigh.uppercased()) {
                self.productViewModel.getProductsFromCategory(site: .ethos)
            }
        default:
            break
        }
        
        
        
        
        self.preOwnedpicksProductViewModel.initiate(id: 22, limit: 8, selectedSortBy: EthosConstants.bestSeller){
            self.preOwnedpicksProductViewModel.getProductsFromCategory(site: .secondMovement)
        }
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        self.addRefreshControl()
        self.tableViewShopping.registerCell(className: EthosStoryCell.self)
        self.tableViewShopping.registerCell(className: BrandsTableViewCell.self)
        self.tableViewShopping.registerCell(className: HeadingCell.self)
        self.tableViewShopping.registerCell(className: ShoppingCategoryTableViewCell.self)
        self.tableViewShopping.registerCell(className: VerticalCollectionTableViewCell.self)
        self.tableViewShopping.registerCell(className: HorizontalCollectionTableViewCell.self)
        self.tableViewShopping.registerCell(className: SpecialCategoryCell_I.self)
        self.tableViewShopping.registerCell(className: SpecialCategoryCell_II.self)
        self.tableViewShopping.registerCell(className: RepairAndServiceNew.self)
        self.tableViewShopping.registerCell(className: SpacingTableViewCell.self)
        self.tableViewShopping.registerCell(className: SectionHeaderCell.self)
        self.categoryViewModel.delegate = self
        self.productViewModel.delegate = self
        self.preOwnedpicksProductViewModel.delegate = self
        self.bannerViewModel.delegate = self
        self.storeViewModel.delegate = self
        self.lblNumberOfNotifications.setBorder(borderWidth: 0, borderColor: .clear, radius: 7.5)
        NotificationCenter.default.addObserver(forName:  NSNotification.Name("receivedNotification"), object: nil, queue: nil) { notification in
            self.updateNotificationCount()
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
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
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
                "Screen" : "Shop"
            ]
            
            Mixpanel.mainInstance().trackWithLogs(event: "Notifications Clicked" , properties: properties)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @objc func routeToStoreViewController() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosStoreViewController.self)) as? EthosStoreViewController {
            vc.isForPreOwn = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension ShopViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 18
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            if Userpreference.shouldShowCategories == true {
                if self.loadingCategories {
                    return 5
                } else {
                    return categoryViewModel.categories.count
                }
            } else {
                return 0
            }
            
        } else if section == 3 {
            if Userpreference.shouldShowCategories == true  {
                return 1
            } else {
                return 0
            }
        } else if section == 5 {
            if Userpreference.shouldShowCategories == true {
                return 1
            } else {
                return 0
            }
        } else if section == 6 {
            if Userpreference.shouldShowCategories == true {
                return 1
            } else {
                return 0
            }
        } else if section == 11 || section == 12 {
            if Userpreference.shouldShowLifeStyle == true {
                return 1
            } else {
                return 0
            }
        } else if section == 14 || section == 15 {
            if Userpreference.shouldShowFeaturesSection == true {
                return 1
            } else {
                return 0
            }
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0 :
            if loadingBanners {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoryCell.self)) as? EthosStoryCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionViewStories.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoryCell.self)) as? EthosStoryCell {
                    cell.contentView.hideSkeleton()
                    cell.collectionViewStories.hideSkeleton()
                    cell.isforPreOwned = false
                    cell.delegate = self
                    cell.viewModel = self.bannerViewModel
                    cell.didGetBanners(banners: self.bannerViewModel.banners)
                    cell.superTableView = self.tableViewShopping
                    return cell
                }
            }
           
            
        case 1 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BrandsTableViewCell.self)) as? BrandsTableViewCell {
                cell.forSecondMovement = false
                cell.setTitle(title: EthosConstants.ShopByBrands.uppercased())
                cell.delegate = self
                cell.initiateData()
                return cell
            }
            
        case 2 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
            cell.setSpacing(height: 10)
            return cell
        }
            
        case 3 :
            
            if Userpreference.shouldShowCategories == true {
                if loadingCategories {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SectionHeaderCell.self)) as? SectionHeaderCell {
                        cell.setTitle(title: EthosConstants.ShopByCategory.uppercased())
                        return cell
                    }
                } else if categoryViewModel.categories.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SectionHeaderCell.self)) as? SectionHeaderCell {
                        cell.setTitle(title: EthosConstants.ShopByCategory.uppercased())
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                        cell.setSpacing(height: 2,color: .clear)
                        return cell
                    }
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2,color: .clear)
                    return cell
                }
            }
           
            
        case 4 :
            if Userpreference.shouldShowCategories == true {
                if self.loadingCategories {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShoppingCategoryTableViewCell.self)) as? ShoppingCategoryTableViewCell {
                        cell.showAnimatedGradientSkeleton()
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ShoppingCategoryTableViewCell.self)) as? ShoppingCategoryTableViewCell {
                        cell.hideSkeleton()
                        cell.category = categoryViewModel.categories[safe : indexPath.row]
                        return cell
                    }
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2,color: .clear)
                    return cell
                }
            }
            
        case 5 : 
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                if Userpreference.shouldShowCategories == true {
                    if self.loadingCategories {
                        cell.setSpacing(height: 24, color: .white)
                    } else {
                        if categoryViewModel.categories.count > 0 {
                            cell.setSpacing(height: 24, color: .white)
                        } else {
                            cell.setSpacing(height: 2, color: .clear)
                        }
                    }
                   
                } else {
                    cell.setSpacing(height: 2, color: .clear)
                }
           
            return cell
        }
            
        case 6 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
            if Userpreference.shouldShowCategories == true {
                if self.loadingCategories {
                    cell.setSpacing(height: 10)
                } else {
                    if categoryViewModel.categories.count > 0 {
                        cell.setSpacing(height: 10)
                    } else {
                        cell.setSpacing(height: 2, color: .clear)
                    }
                }
            } else {
                cell.setSpacing(height: 2, color: .clear)
            }
            return cell
        }
            
        case 7 :
            if Userpreference.shouldShowShopThroughOurBoutique == true {
                if self.loadingBoutiques {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self)) as? HorizontalCollectionTableViewCell {
                        cell.forSecondMovement = false
                        cell.progressView.isHidden = true
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintBottomProgressView.constant = 0
                        cell.setTitle(title: EthosConstants.ShopThroughOurBoutique.uppercased())
                        cell.key = .forStore
                        cell.contentView.showAnimatedGradientSkeleton()
                        cell.collectionView.showAnimatedGradientSkeleton()
                       
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self)) as? HorizontalCollectionTableViewCell {
                        cell.contentView.hideSkeleton()
                        cell.collectionView.hideSkeleton(reloadDataAfter: true)
                        cell.forSecondMovement = false
                        cell.progressView.isHidden = true
                        cell.constraintTopProgressView.constant = 0
                        cell.setTitle(title: EthosConstants.ShopThroughOurBoutique.uppercased())
                        cell.key = .forStore
                        cell.storeViewModel.newStores = self.storeViewModel.newStores
                        cell.didGetNewStores(stores: self.storeViewModel.newStores)
                        cell.delegate = self
                        cell.constraintTopProgressView.constant = 0
                        cell.constraintBottomProgressView.constant = 0
                        return cell
                    }
                    
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2, color: .clear)
                    return cell
                }
            }


            
        case 8 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
            if Userpreference.shouldShowShopThroughOurBoutique == true {
                cell.setSpacing(height: 10)
            } else {
                cell.setSpacing(height: 2, color: .clear)
            }
            
            return cell
        }
            
        case 9 :
            if self.loadingNewArrivals {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VerticalCollectionTableViewCell.self)) as? VerticalCollectionTableViewCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionView.showAnimatedGradientSkeleton()
                    cell.delegate = self
                    cell.didGetProducts(site : nil, CategoryId : nil)
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: VerticalCollectionTableViewCell.self)) as? VerticalCollectionTableViewCell {
                    cell.contentView.hideSkeleton()
                    cell.collectionView.hideSkeleton()
                    cell.delegate = self
                    cell.productViewModel.products = self.productViewModel.products
                    cell.isForPreOwned = false
                    cell.didGetProducts(site : nil, CategoryId : nil)
                    return cell
                }
            }
           
            
        case 10 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
            cell.setSpacing(height: 10)
            return cell
        }
            
        case 11 :
            if Userpreference.shouldShowLifeStyle == true {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpecialCategoryCell_I.self)) as? SpecialCategoryCell_I {
                    cell.delegate = self
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2, color: .clear)
                    return cell
                }
            }
           
            
        case 12 : 
           
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                if Userpreference.shouldShowLifeStyle == true {
                    cell.setSpacing(height: 10)
                } else {
                    cell.setSpacing(height: 2)
                }
                return cell
            }
            
        case 13 :
            if loadingPreOwnedPicks {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self)) as? HorizontalCollectionTableViewCell {
                    cell.forSecondMovement = true
                    cell.setTitle(title: EthosConstants.PreOwnedPicks.uppercased())
                    cell.key = .forPreOwnedPicks
                    cell.contentView.showAnimatedSkeleton()
                    cell.collectionView.showAnimatedSkeleton()
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self)) as? HorizontalCollectionTableViewCell {
                    cell.contentView.hideSkeleton()
                    cell.collectionView.hideSkeleton()
                    cell.forSecondMovement = true
                    cell.setTitle(title: EthosConstants.PreOwnedPicks.uppercased())
                    cell.key = .forPreOwnedPicks
                    cell.delegate = self
                    cell.productViewModel.products = self.preOwnedpicksProductViewModel.products
                    cell.didGetProducts(site: nil, CategoryId: nil)
                    return cell
                }
            }
            
            
        case 14 : 
            
            if Userpreference.shouldShowFeaturesSection == true {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 10)
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2, color: .clear)
                    return cell
                }
            }
            
        case 15 :
            if Userpreference.shouldShowFeaturesSection == true {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpecialCategoryCell_II.self)) as? SpecialCategoryCell_II {
                    cell.delegate = self
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
                    cell.setSpacing(height: 2, color: .clear)
                    return cell
                }
            }
           
            
        case 16 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self), for: indexPath) as? SpacingTableViewCell {
            cell.setSpacing(height: 10)
            return cell
        }
            
        case 17 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceNew.self)) as? RepairAndServiceNew {
                cell.key = .forShopping
                cell.delegate = self
                return cell
            }
            
        default:
            return UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.view.frame.width*47/43
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                vc.isForPreOwned = false
                vc.productViewModel.categoryId = categoryViewModel.categories[safe : indexPath.row]?.id
                vc.productViewModel.categoryName = categoryViewModel.categories[safe : indexPath.row]?.name
                vc.screenType = "view_all"
                Mixpanel.mainInstance().trackWithLogs(event: "Shop By Category Clicked", properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Category : categoryViewModel.categories[safe : indexPath.row]?.name ?? ""
                ])
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is EthosStoryCell {
            (cell as? EthosStoryCell)?.pauseVideo()
        }
    }
}

extension ShopViewController : GetCategoryViewModelDelegate {
    func didFailedToGetCategories() {
        self.storeViewModel.getNewBoutiques(site: .ethos)
    }
    
    func didGetCategories() {
        self.loadingCategories = false
    }
}

extension ShopViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys{
            if key == EthosKeys.route {
                if let id = info?[EthosKeys.value] as? String,
                   let vc = self.storyboard?.instantiateViewController(withIdentifier: id) {
                    
                    if vc is RepairAndServiceViewController {
                        (vc as? RepairAndServiceViewController)?.isForPreOwned = false
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if key == .requestACallBack {
                if  let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: RequestACallBackFormViewController.self)) as? RequestACallBackFormViewController {
                    vc.isforPreOwned = false
                    vc.selectedTabIndex = self.tabBarController?.selectedIndex
                    vc.screenLocation = "Shop"
                    Mixpanel.mainInstance().trackWithLogs(event: "Repair Call Back Clicked", properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        "Screen Location" : "Shop"
                    ])
                    
                    self.present(vc, animated: true)
                }
            }
            
            if key == .scheduleAPickup {
                if  let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ScheduleAPickupViewController.self)) as? ScheduleAPickupViewController {
                    vc.isforPreOwned = false
                    vc.selectedTabIndex = self.tabBarController?.selectedIndex
                    self.present(vc, animated: true)
                }
            }
            
            if key == .visitOurBoutique {
                self.routeToStoreViewController()
            }
            
            if key == EthosKeys.routeToArticleDetail,
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
            
            if key == EthosKeys.reloadTableView {
                self.tableViewShopping.reloadData()
            }
            
            if key == EthosKeys.reloadHeightOfTableView {
                self.tableViewShopping.beginUpdates()
                self.tableViewShopping.endUpdates()
            }
            
            if key == .routeToProducts, let categoryName = info?[EthosKeys.categoryName] as? String, categoryName == "Rolex" {
                    UserActivityViewModel().getDataFromActivityUrl(url: "https://www.ethoswatches.com/rolex/?utm_source=Mobile_App&utm_medium=Mobile_App&utm_campaign=Mobile_App")} else if key == EthosKeys.routeToProducts,
               let categoryId = info?[EthosKeys.categoryId] as? Int {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                    let categoryName = info?[EthosKeys.categoryName] as? String
                    if categoryName == "All Watches"{
                        vc.screenType = "view_all"
                    }else{
                        vc.screenType = ""
                    }
                    vc.productViewModel.categoryName = categoryName
                    vc.productViewModel.categoryId = categoryId
                    
                    if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                        vc.isForPreOwned = forSecondMovement
                        if categoryId == 6 && forSecondMovement == true {
                            switch Userpreference.smJustINSort ?? "" {
                            case "New Arrival" : vc.productViewModel.selectedSortBy = EthosConstants.NewArrivals.uppercased()
                            case "Best Selling" : vc.productViewModel.selectedSortBy = EthosConstants.bestSeller.uppercased()
                            case "Price High to Low" : vc.productViewModel.selectedSortBy = EthosConstants.priceHighToLow.uppercased()
                            case "Price Low to High": vc.productViewModel.selectedSortBy = EthosConstants.priceLowToHigh.uppercased()
                            default:
                                break
                            }
                        } else if categoryId == 144 && forSecondMovement == false {
                            switch Userpreference.ethosJustINSort ?? "" {
                            case "New Arrival" : vc.productViewModel.selectedSortBy = EthosConstants.NewArrivals.uppercased()
                            case "Best Selling" : vc.productViewModel.selectedSortBy = EthosConstants.bestSeller.uppercased()
                            case "Price High to Low" : vc.productViewModel.selectedSortBy = EthosConstants.priceHighToLow.uppercased()
                            case "Price Low to High": vc.productViewModel.selectedSortBy = EthosConstants.priceLowToHigh.uppercased()
                            default:
                                break
                            }
                        }
                    } else {
                        if categoryId == 144 {
                            switch Userpreference.ethosJustINSort ?? "" {
                            case "New Arrival" : vc.productViewModel.selectedSortBy = EthosConstants.NewArrivals.uppercased()
                            case "Best Selling" : vc.productViewModel.selectedSortBy = EthosConstants.bestSeller.uppercased()
                            case "Price High to Low" : vc.productViewModel.selectedSortBy = EthosConstants.priceHighToLow.uppercased()
                            case "Price Low to High": vc.productViewModel.selectedSortBy = EthosConstants.priceLowToHigh.uppercased()
                            default:
                                break
                            }
                        }
                    }
                    
                    if let forStoryRoute = info?[EthosKeys.forStoryRoute] as? Bool {
                        vc.forStoryRoute = forStoryRoute
                        if let story = info?[EthosKeys.forStoryRoute] as? Banner {
                            vc.story = story
                            if let story = info?[EthosKeys.story] as? Banner {
                                vc.story = story
                            }
                        }
                    }
                    
                    if let filters = info?[EthosKeys.filters] as? [FilterModel] {
                        vc.productViewModel.selectedFilters = filters
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if key == EthosKeys.routeToStore {
                if let store = info?[EthosKeys.value] as? Store {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBoutiqueDescriptionViewController.self)) as? EthosBoutiqueDescriptionViewController {
                        vc.store = store
                        vc.forSpecialBoutique = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
            if key == EthosKeys.routeToProductDetails,
               let product = info?[EthosKeys.value] as? Product {
                
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
               let sku = info?[EthosKeys.value] as? String {
                let forSecondMovement = (info?[EthosKeys.forSecondMovement] as? Bool) ?? false
                if forSecondMovement {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                        vc.sku = sku
                        
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
                        vc.sku = sku
                        
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
        }
    }
}

extension ShopViewController : GetBannersViewModelDelegate {
    func didGetBanners(banners: [Banner]) {
        self.loadingBanners = false
    }
}

extension ShopViewController : GetProductViewModelDelegate {
    
    func didGetProducts(site : Site?, CategoryId : Int?) {
        if site == .secondMovement && CategoryId == 22 {
            self.loadingPreOwnedPicks = false
        }
        
        if site == .ethos && CategoryId == 144 {
            self.loadingNewArrivals = false
        }
    }
    
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
       
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
    
    func errorInGettingProducts(error: String) {
        
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

extension ShopViewController : GetStoresViewModelDelegate {
    func didGetNewStores(stores: [Store]) {
        loadingBoutiques = false
    }
    
    func didFailedToGetNewStores() {
       loadingBoutiques = false
    }
    
    func didGetStores(stores: [StoreCity], forLatest: Bool) {
        
    }
    
    func didFailedToGetStores() {
       
    }
    
}
