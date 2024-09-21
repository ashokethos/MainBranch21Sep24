//
//  NewCatalogViewController.swift
//  Ethos
//
//  Created by Mac on 08/04/24.
//

import UIKit
import SafariServices
import Mixpanel
import SkeletonView

class NewCatalogViewController: UIViewController {
    
    @IBOutlet weak var btnRedDotSortBy: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var lblNumberOfItems: UILabel!
    @IBOutlet weak var indicatorFooter: UIActivityIndicatorView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnRedDot: UIImageView!
    @IBOutlet weak var viewFilterAndSortBy: UIView!
    
    @IBOutlet weak var headerImage: UIImageView!
    
    var story : Banner?
    var forStoryRoute : Bool = false
    let refreshControl = UIRefreshControl()
    let bannerViewModel = GetBannersViewModel()
    var productViewModel = GetProductViewModel()
    var adViewModel = GetAdsViewModel()
    var isForPreOwned = false
    var screenType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for index in productTableView.indexPathsForVisibleRows ?? [] {
            if let adview = productTableView.footerView(forSection: index.section) {
                (adview as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
                (adview as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.productTableView.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        callApi()
    }
    
    
    func callApi() {
        bannerViewModel.delegate = self
        bannerViewModel.getBanners(key: .category)
        self.adViewModel.getAdvertisment(site: self.isForPreOwned ? Site.secondMovement : Site.ethos, location : "category") {
            
            self.productViewModel.getProductsFromCategory(site: self.isForPreOwned ? .secondMovement : .ethos)
        }
    }
    
    func setup() {
        
        self.productTableView.isSkeletonable = true
        self.productTableView.showAnimatedGradientSkeleton()
        self.btnRedDotSortBy.clipsToBounds = true
        self.btnRedDotSortBy.layer.cornerRadius = 2.5
        self.btnRedDot.clipsToBounds = true
        self.btnRedDot.layer.cornerRadius = 2.5
        self.lblTitle.isHidden = true
        self.addTapGestureToDissmissKeyBoard()
        productTableView.registerCell(className: ProductPairTableViewCell.self)
        
        productTableView.register(UINib(nibName: String(describing: AdvertisementHeaderFooterView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: AdvertisementHeaderFooterView.self))
        
        productTableView.register(UINib(nibName: String(describing: FavreLeubaCatalogHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: FavreLeubaCatalogHeaderView.self))
        
        productTableView.registerCell(className: SpacingTableViewCell.self)
        
        productViewModel.delegate = self
        self.btnFilter.isEnabled = false
        self.viewFilterAndSortBy.clipsToBounds = true
        self.viewFilterAndSortBy.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.lblTitle.text = self.productViewModel.categoryName?.uppercased()
            self.getFilters()
            self.addRefreshControl()
            self.callApi()
            self.productViewModel.defaultSortBy = self.productViewModel.selectedSortBy
            self.headerImage.image = self.isForPreOwned ? UIImage.imageWithName(name: EthosConstants.apptitle2) : UIImage.imageWithName(name: EthosConstants.apptitle)
            self.updateView()
        }
    }
    
    func getFilters() {
        self.productViewModel.getUpdatedFilters(site: isForPreOwned ? .secondMovement : .ethos, screenType: self.screenType)
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSortByDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBottomSheetTableViewControllerWithTitle.self)) as? EthosBottomSheetTableViewControllerWithTitle {
            vc.delegate = self
            vc.data = self.productViewModel.availableSortBy
            vc.key = .forSortBy
            vc.title = "SORT BY"
            if let selectedSortBy = self.productViewModel.selectedSortBy {
                vc.selectedItem = selectedSortBy
            }
            
            vc.superController = self
            
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwned
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func btnFiltersDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: FiltersViewController.self)) as? FiltersViewController {
            vc.isForPreOwned = self.isForPreOwned
            vc.screenType = self.screenType
            vc.viewModel.filters = productViewModel.filters
            vc.viewModel.filterProductCount = productViewModel.totalCount
            vc.viewModel.initiate(id: self.productViewModel.categoryId, categoryName: self.productViewModel.categoryName, selectedSortBy: self.productViewModel.selectedSortBy) {
                var selectedValues = [SelectedFilterData]()
                for filter in self.productViewModel.selectedFilters {
                    for value in filter.values ?? [] {
                        let item = SelectedFilterData(filterModelName: filter.attributeName ?? "", filterModelCode: filter.attributeCode ?? "", filterModelId: filter.attributeId ?? 0, filtervalue: value)
                        selectedValues.append(item)
                    }
                }
                vc.viewModel.selectedValues = selectedValues
                vc.delegate = self
                self.present(vc, animated: false)
            }
        }
    }
    
    func updateView() {
        if self.productViewModel.selectedSortBy == self.productViewModel.defaultSortBy {
            self.btnRedDotSortBy.isHidden = true
        } else {
            self.btnRedDotSortBy.isHidden = false
        }
        if self.productViewModel.selectedFilters.count == 0 {
            self.btnRedDot.isHidden = true
        } else {
            self.btnRedDot.isHidden = false
        }
    }
    
}

extension NewCatalogViewController : SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "ProductPairTableViewCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: ProductPairTableViewCell.self), for: indexPath) as? ProductPairTableViewCell {
            cell.contentView.showAnimatedGradientSkeleton()
            return cell
        }
        return UITableViewCell()
    }
    
}

extension NewCatalogViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ProductPairTableViewCell.self), for: indexPath) as? ProductPairTableViewCell {
            
            cell.superViewController = self
            cell.isForPreOwned = self.isForPreOwned
            let indx = (indexPath.section*2)
            
            if indx < productViewModel.products.count {
                cell.product1 = productViewModel.products[ safe : indx]
            }
            
            if indx + 1 < productViewModel.products.count {
                cell.product2 = productViewModel.products[ safe : indx + 1]
            }
            
            DispatchQueue.main.async {
                cell.contentView.hideSkeleton()
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && self.productViewModel.categoryId == 80 && self.isForPreOwned == false {
            return UITableView.automaticDimension
        } else if section == 0 {
            return 32
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 && self.productViewModel.categoryId == 80 && self.isForPreOwned == false, let favreLeubaCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: FavreLeubaCatalogHeaderView.self)) as? FavreLeubaCatalogHeaderView {
        if section == 0 && self.isForPreOwned == false, let favreLeubaCell = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: FavreLeubaCatalogHeaderView.self)) as? FavreLeubaCatalogHeaderView {
            if let bannerData = bannerViewModel.banners.first(where: {$0.value == "\(productViewModel.categoryId ?? 0)"}) {
                favreLeubaCell.imageViewMain.isHidden = false
                favreLeubaCell.lblTitle.isHidden = false
                favreLeubaCell.lblDescription.isHidden = false
                favreLeubaCell.btnAction.isHidden = false
                if productViewModel.products.count > 0 {
                    favreLeubaCell.brandName = productViewModel.products[0].extensionAttributes?.ethProdCustomeData?.brand
                }
                favreLeubaCell.bannerData = bannerData
            }else{
                favreLeubaCell.imageViewMain.isHidden = true
                favreLeubaCell.lblTitle.isHidden = true
                favreLeubaCell.lblDescription.isHidden = true
                favreLeubaCell.btnAction.isHidden = true
            }
            favreLeubaCell.setUI(isExpanded: self.productViewModel.isExpanded)
            favreLeubaCell.btnAction.addTarget(self, action: #selector(btnReadMoreTapped), for: .touchUpInside)
            return favreLeubaCell
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.adViewModel.ads.contains(where: { ad in
            ((ad.position ?? 1) - 1) == section
        })  {
            let adToShow = self.adViewModel.ads.first { ad in
                ((ad.position ?? 1) - 1) == section
            }
            if adToShow != nil {
                return UITableView.automaticDimension
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.adViewModel.ads.contains(where: { ad in
            ((ad.position ?? 1) - 1) == section
        })  {
            let adToShow = self.adViewModel.ads.first { ad in
                ((ad.position ?? 1) - 1) == section
            }
            if let ad = adToShow {
                
                let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AdvertisementHeaderFooterView.self)) as! AdvertisementHeaderFooterView
                
                footerView.delegate = self
                footerView.superTableView = self.productTableView
                footerView.superViewController = self
                footerView.advertisment = ad
                return footerView
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ((productViewModel.products.count%2) == 0) ? (productViewModel.products.count/2) : ((productViewModel.products.count/2) + 1)
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if view is AdvertisementHeaderFooterView {
            (view as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
            (view as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == productViewModel.products.count/2 - 1 {
            productViewModel.getNewProducts(site: isForPreOwned ? .secondMovement : .ethos)
        }
    }
    
    @objc func btnReadMoreTapped() {
        self.productViewModel.isExpanded = !self.productViewModel.isExpanded
        self.productTableView.reloadData()
    }
}




extension NewCatalogViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            if scrollView == self.productTableView {
                for index in productTableView.indexPathsForVisibleRows ?? [] {
                    if let footerView = productTableView?.footerView(forSection: index.section), UIApplication.topViewController() == self {
                        
                        let rectOfCell = self.productTableView.rectForFooter(inSection: index.section)
                        
                        
                        let rectOfCellInSuperview = self.productTableView.convert(rectOfCell , to: self.productTableView.superview)
                        if rectOfCellInSuperview.origin.y < footerView.frame.height - 100, rectOfCellInSuperview.origin.y > 80  {
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
        if scrollView == self.productTableView {
            for index in productTableView.indexPathsForVisibleRows ?? [] {
                if let footerView = productTableView?.footerView(forSection: index.section), UIApplication.topViewController() == self  {
                    let rectOfCell = self.productTableView.rectForFooter(inSection: index.section)
                    let rectOfCellInSuperview = self.productTableView.convert(rectOfCell , to: self.productTableView.superview)
                    if rectOfCellInSuperview.origin.y < footerView.frame.height - 100, rectOfCellInSuperview.origin.y > 80  {
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

extension NewCatalogViewController : GetBannersViewModelDelegate{
    func didGetBanners(banners : [Banner]){
        DispatchQueue.main.async {
            self.productTableView.reloadData()
        }
    }
}

extension NewCatalogViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys,
           key == .reloadCollectionView,
           let value = info?[EthosKeys.value] as? String,
           let bottomSheetKey : BottomSheetKey = info?[EthosKeys.type] as? BottomSheetKey {
            switch bottomSheetKey {
            case .forSortBy:
                self.productViewModel.selectedSortBy = value
            case .forSelectBrand:
                break
            case .forSelectConcern:
                break
            case .forPhoneNumber:
                break
            }
            updateView()
            self.productViewModel.products.removeAll()
            self.productTableView.reloadData()
            callApi()
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys, key == .openWebPage, let urlstr = info?[EthosKeys.url] as? String {
            UserActivityViewModel().getDataFromActivityUrl(url: urlstr)
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys, key == .applyFilters, let filters = info? [EthosKeys.filters] as? [FilterModel] , let selectedFilters = info? [EthosKeys.selectedFilters] as? [FilterModel]{
            self.productViewModel.selectedFilters = selectedFilters
            self.productViewModel.filters = filters
            updateView()
            self.productViewModel.products.removeAll()
            self.productTableView.reloadData()
            callApi()
            
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.catalogFilterUsed, properties: [
                EthosConstants.Email: Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.Category : self.productViewModel.categoryName,
                EthosConstants.Brand : self.productViewModel.categoryName,
                EthosConstants.RestOfTheFilters : self.productViewModel.getRequestBodyFromData()[EthosConstants.filters]
            ])
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys, key == .resetFilters {
            self.productViewModel.selectedFilters = []
            self.productViewModel.products.removeAll()
            self.btnFilter.isEnabled = false
            UserDefaults.standard.removeObject(forKey: "filtersData")
            self.getFilters()
            updateView()
            self.productTableView.reloadData()
            callApi()
        }
    }
}

extension NewCatalogViewController : GetProductViewModelDelegate {
    
    func errorInGettingFilters() {
        
    }
    
    func didGetFilters() {
        DispatchQueue.main.async {
            if self.productViewModel.filters.count > 0 {
                self.btnFilter.isEnabled = true
            }
        }
        
    }
    
    func didGetProductDetails(details: Product) {
        
    }
    
    func failedToGetProductDetails() {
        
    }
    
    func errorInGettingProducts(error: String) {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.productTableView.showAnimatedGradientSkeleton()
        }
        
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.productTableView.refreshControl?.endRefreshing()
        }
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
    
    func didGetProducts(site : Site?, CategoryId : Int?) {
        DispatchQueue.main.async {
            if self.productViewModel.totalCount == 1 {
                self.lblNumberOfItems.text = "\(self.productViewModel.totalCount) product".uppercased()
            } else {
                if self.productViewModel.totalCount == 0{
                    self.viewFilterAndSortBy.isHidden = true
                } else {
                    self.viewFilterAndSortBy.isHidden = false
                }
                self.lblNumberOfItems.text = "\(self.productViewModel.totalCount) products".uppercased()
            }
            
            self.productTableView.hideSkeleton()
            
            DispatchQueue.main.async {
                self.productTableView.reloadData()
            }
        }
    }
}

