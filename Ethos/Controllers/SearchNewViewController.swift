//
//  SearchNewViewController.swift
//  Ethos
//
//  Created by Ashok kumar on 19/11/24.
//

import UIKit
import Mixpanel

class SearchNewViewController: UIViewController {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var viewTextField: UIView!
    @IBOutlet weak var saerchTxtField: EthosTextField!
    @IBOutlet weak var recentSearchDropDownView: UIView!
    @IBOutlet weak var headerBackView: UIView!
    @IBOutlet weak var popularBackView: UIView!
    @IBOutlet weak var popularTitleLbl: UILabel!
    @IBOutlet weak var productBackView: UIView!
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var articleBackView: UIView!
    @IBOutlet weak var articleImg: UIImageView!
    @IBOutlet weak var articleTitleLbl: UILabel!
    @IBOutlet weak var footerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchDataCollection: UICollectionView!
    @IBOutlet weak var btnRedDotSortBy: UIImageView!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnRedDot: UIImageView!
    @IBOutlet weak var viewFilterAndSortBy: UIView!
    
    var ArrSearchedItemsHeader = [TitleDescriptionImageModel(title: EthosConstants.searchProductTitle, description: "", image: EthosConstants.searchWatchesIcon, btnTitle: ""), TitleDescriptionImageModel(title: EthosConstants.searchStoryTitle, description: "", image: EthosConstants.searchStoryIcon, btnTitle: "")]
    
    var searchSuggestionViewModel = GetSearchSuggestionViewModel()
    let articleViewModel = GetArticlesViewModel()
    var productViewModel = GetProductViewModel()
    var recentSearchDataArr = [GetSearchSuggestionModel]()
    var preOwnedRecentSearchDataArr = [GetSearchSuggestionModel]()
    var popularSearchDataArr = [GetSearchSuggestionModel]()
    var recentSearchSelectedData = [GetSearchSuggestionModel]()
    var delegate : SuperViewDelegate?
    let dropDown = DropDown()
    var isForPreOwned = false
    var apiType: String?
    var isSearching = false
    var selectedIndexForSearch = 0
    var selectBtnStatus = false
    var categoryId = 0
    var finalSearchString = ""
    var emptyMsg = ""
    var isKeyboardVisible: Bool = false
    var apiCallStatus = false
    var searchBtnPressStatus = false
    var screenType = ""
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setUpUI()
        setTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.selectedIndexForSearch == 0{
            if self.productViewModel.products.count == 0{
                self.viewFilterAndSortBy.isHidden = true
            }else if self.productViewModel.products.count == 1 && self.productViewModel.selectedFilters.count == 0{
                self.viewFilterAndSortBy.isHidden = true
            }else{
                self.viewFilterAndSortBy.isHidden = false
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        isKeyboardVisible = true
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                print("Keyboard will show with frame: \(keyboardFrame)")
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
    }
    
    func isKeyboardCurrentlyVisible() -> Bool {
        return isKeyboardVisible
    }
    
    func setUpUI(){
        productBackView.isHidden = true
        articleBackView.isHidden = true
        popularBackView.isHidden = false
        cancelBtn.setAttributedTitleWithProperties(title: EthosConstants.Cancel, font: EthosFont.Brother1816Regular(size: 12),foregroundColor: .black,kern: 0.5)
        isSearching = false
        btnFilter.isEnabled = false
        btnRedDotSortBy.clipsToBounds = true
        btnRedDotSortBy.layer.cornerRadius = 2.5
        btnRedDot.clipsToBounds = true
        btnRedDot.layer.cornerRadius = 2.5
        viewFilterAndSortBy.isHidden = true
        viewFilterAndSortBy.clipsToBounds = true
        viewFilterAndSortBy.layer.cornerRadius = 20
        searchDataCollection.isSkeletonable = true
        searchDataCollection.registerCell(className: RecentSearchCollectionViewCell.self)
        searchDataCollection.registerCell(className: ProductCollectionViewCell.self)
        searchDataCollection.registerCell(className: SearchArticleCollectionViewCell.self)
        searchDataCollection.dataSource = self
        searchDataCollection.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        searchDataCollection.refreshControl = refreshControl
        
        //Get RecentSearchData
        if isForPreOwned{
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                apiType = ""
                preOwnedRecentSearchDataArr = data
                searchDataCollection.reloadData()
            }else{
                apiType = "popularSearch"
                callApiForSearchSuggestion(str: "", apiType: apiType)
            }
        }else{
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.recentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                apiType = ""
                recentSearchDataArr = data
                searchDataCollection.reloadData()
            }else{
                apiType = "popularSearch"
                callApiForSearchSuggestion(str: "", apiType: apiType)
            }
        }
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
//            saerchTxtField.text = ""
//            apiType = ""
            dropDownSelectData(index: index, item: item)
        }
    }
    
    @objc func refreshData() {
        callApiForSearch()
        }
    
    func dropDownSelectData(index: Int, item: String?){
        if isForPreOwned{
            if preOwnedRecentSearchDataArr.first(where: { $0.title?.contains(item ?? "") ?? false }) != nil {
                let indexs = preOwnedRecentSearchDataArr.firstIndex(where: { ( $0.title ?? "" == item ) } )
                preOwnedRecentSearchDataArr.remove(at: indexs ?? 0)
                preOwnedRecentSearchDataArr.insert(recentSearchSelectedData[index], at: 0)
            } else {
                preOwnedRecentSearchDataArr.insert(recentSearchSelectedData[index], at: 0)
            }
            
            if let encoded = try? JSONEncoder().encode(preOwnedRecentSearchDataArr) {
                UserDefaults.standard.set(encoded, forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue)
            }
            
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                preOwnedRecentSearchDataArr = data
                searchDataCollection.reloadData()
            }
        }else{
            if recentSearchDataArr.first(where: { $0.title?.contains(item ?? "") ?? false }) != nil {
                let indexs = recentSearchDataArr.firstIndex(where: { ( $0.title ?? "" == item ) } )
                recentSearchDataArr.remove(at: indexs ?? 0)
                recentSearchDataArr.insert(recentSearchSelectedData[index], at: 0)
            } else {
                recentSearchDataArr.insert(recentSearchSelectedData[index], at: 0)
            }
            
            if let encoded = try? JSONEncoder().encode(recentSearchDataArr) {
                UserDefaults.standard.set(encoded, forKey: UserPerferenceKey.recentSearchData.rawValue)
            }
            
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.recentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                recentSearchDataArr = data
                searchDataCollection.reloadData()
            }
        }
        
        if recentSearchSelectedData[index].type == "category" || recentSearchSelectedData[index].type == "filter_query"{
            view.endEditing(true)
//            productViewModel.selectedFilters = []
//            productViewModel.upperPriceLimit = nil
//            productViewModel.lowerPriceLimit = nil
//            productViewModel.products.removeAll()
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                vc.isForPreOwned = isForPreOwned
                if recentSearchSelectedData[index].type == "filter_query"{
                    vc.productViewModel.categoryName = item
                    vc.productViewModel.categoryId = Int(recentSearchSelectedData[index].filters?.categoryId?[0] ?? "")
                    
                    let attrValueId = Int(recentSearchSelectedData[index].filters?.value?[0].attrValueId ?? "") ?? nil
                    let attributeId: Int? = attrValueId
                    
                    let attributeCode = recentSearchSelectedData[index].filters?.attrCode
                    let attributeName = recentSearchSelectedData[index].filters?.attrName
                    if attributeName?.uppercased() == EthosConstants.collection.uppercased() || attributeName?.uppercased() == EthosConstants.series.uppercased(){
                        vc.screenType = "search"
                    }else{
                        vc.screenType = ""
                    }
                    
                    var filterValues: [FilterValue] = []
                    for model in (recentSearchSelectedData[index].filters?.value ?? []) {
                        if let attrValueIdStr = model.attrValueId,
                           let attrValueIdInt = Int(attrValueIdStr) {
                            let filterValue = FilterValue(attributeValueId: attrValueIdInt, attributeValueName: model.attrValueName)
                            filterValues.append(filterValue)
                        }
                    }
                    
                    let filterModel = FilterModel(attributeId: attributeId, attributeCode: attributeCode, attributeName: attributeName, values: filterValues)
                    if let filters = [filterModel] as? [FilterModel] {
                        vc.productViewModel.selectedFilters = filters
                    }
                }else if recentSearchSelectedData[index].type == "category"{
                    vc.productViewModel.categoryName = recentSearchSelectedData[index].title
                    vc.productViewModel.categoryId = Int(recentSearchSelectedData[index].id ?? "")
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            view.endEditing(true)
            if self.isForPreOwned {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = recentSearchSelectedData[index].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                    vc.sku = recentSearchSelectedData[index].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
    }
    
    func setTextField() {
        saerchTxtField.delegate = self
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonClicked))]
        saerchTxtField.inputAccessoryView = toolbar
        viewTextField.setBorder(borderWidth: 1, borderColor: EthosColor.lightGrey, radius: viewTextField.frame.height/2)
        
        saerchTxtField.initWithUIParameters(placeHolderText: EthosConstants.SearchNewPlaceHolder, placeholderColor: UIColor(white: 0, alpha: 0.3),  underLineColor: .clear, errUnderLineColor: .clear, textInset: 0)
        
        saerchTxtField.adjustsFontSizeToFitWidth = true
    }
    
    @objc func doneButtonClicked(_ sender: Any) {
        saerchTxtField.resignFirstResponder()
        selectBtnStatus = false
        dropDown.hide()
        view.endEditing(true)
        let trimmedText = saerchTxtField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if trimmedText.isEmpty {
            viewFilterAndSortBy.isHidden = true
            emptySearchField()
        } else if isSearching == false {
            searchBtnPressStatus = true
            emptyMsg = ""
            isSearching = true
            resetAllProductData()
            callApiForSearch(tabChangeStatus: true)
        } else {
            searchBtnPressStatus = true
            emptyMsg = ""
            resetAllProductData()
            callApiForSearch(tabChangeStatus: true)
        }
    }
    
    func resetAllProductData(resetStatus: Bool = false){
        productViewModel.products.removeAll()
        articleViewModel.articles.removeAll()
        productViewModel.currentPage = 0
        viewFilterAndSortBy.isHidden = true
        searchDataCollection.setContentOffset(.zero, animated: false)
        if resetStatus == false{
            resetFilter()
        }
    }
    
    func slecetedUnselectProductHeader(productStatus: Bool?, tabChangeStatus: Bool? = false){
        productBackView.isHidden = false
        articleBackView.isHidden = false
        popularBackView.isHidden = true
        view.endEditing(true)
        if productStatus == true {
            productImg.image = UIImage.imageWithName(name: ArrSearchedItemsHeader[0].image).withTintColor(EthosColor.blackColor, renderingMode: .alwaysOriginal)
            productTitleLbl.setAttributedTitleWithProperties(title: ArrSearchedItemsHeader[0].title, font: EthosFont.Brother1816Regular(size: 10), foregroundColor: EthosColor.blackColor, showUnderline: true)
            articleImg.image = UIImage.imageWithName(name: ArrSearchedItemsHeader[1].image).withTintColor(EthosColor.darkGrey, renderingMode: .alwaysOriginal)
            articleTitleLbl.setAttributedTitleWithProperties(title: ArrSearchedItemsHeader[1].title, font: EthosFont.Brother1816Regular(size: 10), foregroundColor: EthosColor.darkGrey, showUnderline: false)
        }else{
            articleImg.image = UIImage.imageWithName(name: ArrSearchedItemsHeader[1].image).withTintColor(EthosColor.blackColor, renderingMode: .alwaysOriginal)
            articleTitleLbl.setAttributedTitleWithProperties(title: ArrSearchedItemsHeader[1].title, font: EthosFont.Brother1816Regular(size: 10), foregroundColor: EthosColor.blackColor, showUnderline: true)
            productImg.image = UIImage.imageWithName(name: ArrSearchedItemsHeader[0].image).withTintColor(EthosColor.darkGrey, renderingMode: .alwaysOriginal)
            productTitleLbl.setAttributedTitleWithProperties(title: ArrSearchedItemsHeader[0].title, font: EthosFont.Brother1816Regular(size: 10), foregroundColor: EthosColor.darkGrey, showUnderline: false)
        }
        
        if tabChangeStatus ?? false {
            searchDataCollection.reloadData()
        }
    }
    
    @IBAction func btnSortByDidTapped(_ sender: UIButton) {
        searchBtnPressStatus = false
//        viewFilterAndSortBy.isHidden = true
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBottomSheetTableViewControllerWithTitle.self)) as? EthosBottomSheetTableViewControllerWithTitle {
            vc.delegate = self
            if productViewModel.categoryId == 93 && isForPreOwned == false{
                vc.data = self.productViewModel.availableSortByForEOS
            }else if productViewModel.categoryId == 4 && isForPreOwned == true{
                vc.data = self.productViewModel.availableSortByForEOS
            }else{
                vc.data = self.productViewModel.availableSortBy
            }
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
    
    @IBAction func btnFiltersDidTapped(_ sender: UIButton) {
        searchBtnPressStatus = false
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
                vc.viewModel.minPriceLimit = self.productViewModel.minPriceLimit
                vc.viewModel.maxPriceLimit = self.productViewModel.maxPriceLimit
                
                vc.viewModel.lowerPriceLimit = self.productViewModel.lowerPriceLimit
                vc.viewModel.upperPriceLimit = self.productViewModel.upperPriceLimit
                vc.viewModel.selectedFilters = self.productViewModel.selectedFilters
                vc.viewModel.selectedValues = selectedValues
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: false)
            }
//            self.viewFilterAndSortBy.isHidden = true
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        if isSearching == true {
            emptySearchField()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func emptySearchField(){
        saerchTxtField.text = ""
        saerchTxtField.endEditing(true)
        isSearching = false
        productBackView.isHidden = true
        articleBackView.isHidden = true
        popularBackView.isHidden = false
        headerBackView.backgroundColor = .white
        viewFilterAndSortBy.isHidden = true
        productViewModel.products.removeAll()
        articleViewModel.articles.removeAll()
        //Get RecentSearchData
        if isForPreOwned{
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                apiType = ""
                preOwnedRecentSearchDataArr = data
                searchDataCollection.reloadData()
            }else{
                apiType = "popularSearch"
                callApiForSearchSuggestion(str: "", apiType: apiType)
            }
        }else{
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.recentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                apiType = ""
                recentSearchDataArr = data
                searchDataCollection.reloadData()
            }else{
                apiType = "popularSearch"
                callApiForSearchSuggestion(str: "", apiType: apiType)
            }
        }
    }
    
    func getFilters() {
        self.productViewModel.delegate = self
        self.productViewModel.getFilters(site: isForPreOwned ? .secondMovement : .ethos, screenType: self.screenType, loader: true)
    }
    
    func callApiForSearchSuggestion(str: String?, apiType: String?) {
        self.searchSuggestionViewModel.delegate = self
        self.searchSuggestionViewModel.getSearchSuggestion(searchString: str ?? "", apiType: apiType ?? "", site: self.isForPreOwned ? .secondMovement : .ethos)
        if self.saerchTxtField.text ?? "" != "" {
            Mixpanel.mainInstance().trackWithLogs(event: "Search Used" , properties: ["Search term":self.saerchTxtField.text ?? ""])
        }
    }
    
    func callApiForSearch(tabChangeStatus: Bool? = false) {
        popularSearchDataArr.removeAll()
        preOwnedRecentSearchDataArr.removeAll()
        recentSearchDataArr.removeAll()
//        searchDataCollection.reloadData()
        headerBackView.backgroundColor = UIColor.init(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0000)
        apiCallStatus = true
        if isSearching {
            if self.selectedIndexForSearch == 1 {
                viewFilterAndSortBy.isHidden = true
                slecetedUnselectProductHeader(productStatus: false, tabChangeStatus: tabChangeStatus)
                articleViewModel.delegate = self
                articleViewModel.getArticles(site: self.isForPreOwned ? .secondMovement : .ethos, searchString : finalSearchString)
            } else {
                slecetedUnselectProductHeader(productStatus: true, tabChangeStatus: tabChangeStatus)
                productViewModel.delegate = self
                productViewModel.initiate(id: 0) {
                EthosLoader.shared.show(view: self.view, frame: self.view.frame)
                self.productViewModel.categoryId = self.categoryId
                self.productViewModel.getNewProductsFromCategory(site: self.isForPreOwned ? .secondMovement : .ethos, searchString: self.finalSearchString == "" ? " " : self.finalSearchString, searchStatus: self.searchBtnPressStatus)
                }
            }
            
            if finalSearchString != ""{
                Mixpanel.mainInstance().trackWithLogs(event: "Search Used" , properties: [
                    "Email": Userpreference.email,
                    "UID" : Userpreference.userID,
                    "Gender" : Userpreference.gender,
                    "Registered" : ((Userpreference.token == nil || Userpreference.token == "") ? "N" : "Y"),
                    "Platform" : "IOS",
                    "Search Text" : finalSearchString
                ])
            }
        }
    }
    
    func updateView() {
        if self.productViewModel.selectedSortBy == self.productViewModel.defaultSortBy {
            self.btnRedDotSortBy.isHidden = true
        } else {
            self.btnRedDotSortBy.isHidden = false
        }
        if self.productViewModel.selectedFilters.count == 0 && self.productViewModel.lowerPriceLimit == nil && self.productViewModel.upperPriceLimit == nil {
            self.btnRedDot.isHidden = true
        } else {
            self.btnRedDot.isHidden = false
        }
    }
    
    @IBAction func productBtnAction(_ sender: UIButton) {
        selectedIndexForSearch = 0
        if productViewModel.products.count == 0{
            emptyMsg = ""
            callApiForSearch()
        }else{
            if productViewModel.products.count == 0{
                viewFilterAndSortBy.isHidden = true
            }else if productViewModel.products.count == 1 && productViewModel.selectedFilters.count == 0{
                viewFilterAndSortBy.isHidden = true
            }else{
                viewFilterAndSortBy.isHidden = false
            }
        }
        slecetedUnselectProductHeader(productStatus: true, tabChangeStatus: true)
    }
    
    @IBAction func articleBtnAction(_ sender: UIButton) {
        viewFilterAndSortBy.isHidden = true
        selectBtnStatus = true
        selectedIndexForSearch = 1
        if articleViewModel.articles.count == 0{
            emptyMsg = ""
            callApiForSearch()
        }
        slecetedUnselectProductHeader(productStatus: false, tabChangeStatus: true)
    }
    
}

extension SearchNewViewController: GetSearchSuggestionViewModelDelegate{
    func errorInGettingArticles(error: String) {
        print(error)
    }
    
    func startIndicators() {
        print("start")
    }
    
    func stopIndicators() {
        print("end")
    }
    
    func didGetSearchSuggestion(searchSuggestionModel : GetSearchSuggestion, site : Site, searchString : String){
        recentSearchSelectedData = searchSuggestionModel.data ?? []
        if apiType == "popularSearch"{
            popularSearchDataArr = searchSuggestionModel.data ?? []
            if let encoded = try? JSONEncoder().encode(popularSearchDataArr) {
                UserDefaults.standard.set(encoded, forKey: UserPerferenceKey.popularSearchData.rawValue)
            }
            
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.popularSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                print(data)
                popularSearchDataArr = data
                searchDataCollection.reloadData()
            }
        }else{
            dropDown.anchorView = recentSearchDropDownView.plainView
            dropDown.width = recentSearchDropDownView.frame.width
            DropDown.appearance().cornerRadius = 10
            var suggestionData = [String]()
            for (_, item) in (searchSuggestionModel.data ?? []).enumerated(){
                suggestionData.append(item.title ?? "")
            }
            dropDown.dataSource = suggestionData
            if searchSuggestionModel.data?.count ?? 0 > 0{
                if isKeyboardVisible{
                    dropDown.show()
                }
            }else{
                dropDown.hide()
            }
        }
    }
}

extension SearchNewViewController: GetProductViewModelDelegate{
    func didGetProducts(site : Site?, CategoryId : Int?) {
        if productViewModel.products.count == 0 {
            emptyMsg = "SORRY, NO RESULTS WERE FOUND."
            DispatchQueue.main.async {
                self.viewFilterAndSortBy.isHidden = true
            }
        }else{
            emptyMsg = ""
            if CategoryId ?? 0 == 0{
                DispatchQueue.main.async {
                    self.viewFilterAndSortBy.isHidden = true
                }
            }else{
                DispatchQueue.main.async {
                    if self.selectedIndexForSearch == 0{
                        if self.productViewModel.products.count == 0{
                            self.viewFilterAndSortBy.isHidden = true
                        }else if self.productViewModel.products.count == 1 && self.productViewModel.selectedFilters.count == 0{
                            self.viewFilterAndSortBy.isHidden = true
                        }else{
                            self.viewFilterAndSortBy.isHidden = false
                        }
                    }
                }
            }
        }
        
        categoryId = CategoryId ?? 0
        DispatchQueue.main.async {
            self.productViewModel.categoryName = self.saerchTxtField.text ?? ""
            self.updateView()
            self.searchDataCollection.reloadData()
        }
        
        if searchBtnPressStatus{
            if productViewModel.searchInputData?.filter?.values?.count ?? 0 > 0{
                let attrValueId = productViewModel.searchInputData?.filter?.values?[0].attributeValueId ?? 0
                let attributeId: Int? = attrValueId
                let attributeCode = productViewModel.searchInputData?.filter?.attributeCode
                let attributeName = productViewModel.searchInputData?.filter?.attributeName
                if attributeName?.uppercased() == EthosConstants.collection.uppercased() || attributeName?.uppercased() == EthosConstants.series.uppercased(){
                    screenType = "search"
                }else{
                    screenType = ""
                }
                
                var filterValues: [FilterValue] = []
                for model in (productViewModel.searchInputData?.filter?.values ?? []) {
                    if let attrValueIdStr = model.attributeValueId {
                        let filterValue = FilterValue(attributeValueId: attrValueIdStr, attributeValueName: model.attributeValueName)
                        filterValues.append(filterValue)
                    }
                }
                
                let filterModel = FilterModel(attributeId: attributeId, attributeCode: attributeCode, attributeName: attributeName, values: filterValues)
                if let filters = [filterModel] as? [FilterModel] {
                    productViewModel.selectedFilters = filters
                }
            }
            getFilters()
        }
        
    }
    
    func errorInGettingProducts(error: String) {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            if self.selectBtnStatus == false {
                EthosLoader.shared.show(view: self.view, frame: self.view.frame)
                self.searchDataCollection.showAnimatedGradientSkeleton()
            }
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            EthosLoader.shared.hide()
            self.searchDataCollection.hideSkeleton()
            self.refreshControl.endRefreshing()
        }
    }
    
    func startFooterIndicator() {
        DispatchQueue.main.async {
//            self.footerIndicator.startAnimating()
        }
    }
    
    func stopFooterIndicator() {
        DispatchQueue.main.async {
            self.apiCallStatus = false
            self.footerIndicator.stopAnimating()
        }
    }
    
    func didGetProductDetails(details: Product) {
        
    }
    
    func failedToGetProductDetails() {
        
    }
    
    func didGetFilters() {
        DispatchQueue.main.async {
            if self.productViewModel.filters.count > 0 {
                self.btnFilter.isEnabled = true
            }
        }
    }
    
    func errorInGettingFilters() {
        
    }
}

extension SearchNewViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        viewFilterAndSortBy.isHidden = true
        if articleViewModel.articles.count == 0{
            emptyMsg = "SORRY, NO RESULTS WERE FOUND."
        }else{
            emptyMsg = ""
        }
        DispatchQueue.main.async {
            self.searchDataCollection.reloadData()
        }
    }
    
    func startIndicatorArticle() {
        DispatchQueue.main.async {
            self.searchDataCollection.showAnimatedGradientSkeleton()
        }
    }
    
    func stopIndicatorArticle() {
        DispatchQueue.main.async {
            self.apiCallStatus = false
            self.searchDataCollection.hideSkeleton()
        }
    }
}

extension SearchNewViewController: SuperViewDelegate {
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
            selectedIndexForSearch = 0
            resetAllProductData(resetStatus: true)
            callApiForSearch()
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys, key == .openWebPage, let urlstr = info?[EthosKeys.url] as? String {
            UserActivityViewModel().getDataFromActivityUrl(url: urlstr)
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys, key == .applyFilters, let filters = info? [EthosKeys.filters] as? [FilterModel] , let selectedFilters = info? [EthosKeys.selectedFilters] as? [FilterModel]{
            if let minPriceLimit = info?[EthosKeys.minPriceLimit] as? Int,
               let maxPriceLimit = info?[EthosKeys.maxPriceLimit] as? Int {
                self.productViewModel.minPriceLimit = minPriceLimit
                self.productViewModel.maxPriceLimit = maxPriceLimit
            }
            
            if let lowerPriceLimit = info?[EthosKeys.lowerPriceLimit] as? Int,
               let upperPriceLimit = info?[EthosKeys.upperPriceLimit] as? Int {
                self.productViewModel.lowerPriceLimit = lowerPriceLimit
                self.productViewModel.upperPriceLimit = upperPriceLimit
            }
            
            productViewModel.selectedFilters = selectedFilters
            productViewModel.filters = filters
            updateView()
            selectedIndexForSearch = 0
            if selectedFilters.count == 0 && productViewModel.selectedSortBy == EthosConstants.bestSeller{
                searchBtnPressStatus = true
                resetAllProductData(resetStatus: false)
            }else{
                resetAllProductData(resetStatus: true)
            }
            callApiForSearch()
            
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
            resetFilter()
            btnFilter.isEnabled = false
            UserDefaults.standard.removeObject(forKey: "filtersData")
            updateView()
            searchBtnPressStatus = false
            selectedIndexForSearch = 0
            productViewModel.selectedSortBy = EthosConstants.bestSeller
            emptySearchField()
        }
        
        if let key = info?[EthosKeys.key] as? EthosKeys, key == .resetFiltersBack {
            if self.selectedIndexForSearch == 0{
                if self.productViewModel.products.count == 0{
                    self.viewFilterAndSortBy.isHidden = true
                }else if self.productViewModel.products.count == 1 && self.productViewModel.selectedFilters.count == 0{
                    self.viewFilterAndSortBy.isHidden = true
                }else{
                    self.viewFilterAndSortBy.isHidden = false
                }
            }
        }
    }
    
    func resetFilter() {
        productViewModel.products.removeAll()
        productViewModel.minPriceLimit = nil
        productViewModel.maxPriceLimit = nil
        productViewModel.lowerPriceLimit = nil
        productViewModel.upperPriceLimit = nil
        productViewModel.filters.removeAll()
        productViewModel.selectedFilters.removeAll()
        productViewModel.selectedSortBy = EthosConstants.bestSeller
    }
}

extension SearchNewViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching == false{
            searchDataCollection.restore()
            popularTitleLbl.setAttributedTitleWithProperties(title: apiType == "popularSearch" ? "TRENDING SEARCHES" : "RECENT SEARCHES", font: EthosFont.Brother1816Medium(size: 10),foregroundColor: .black, kern: 0.5)
            if apiType == "popularSearch" {
                return popularSearchDataArr.count
            } else if isForPreOwned {
                if preOwnedRecentSearchDataArr.count > 5{
                    return 5
                }else{
                    return preOwnedRecentSearchDataArr.count
                }
            } else {
                if recentSearchDataArr.count > 5{
                    return 5
                }else{
                    return recentSearchDataArr.count
                }
            }
        }else{
            if selectedIndexForSearch == 0 {
                if productViewModel.products.count == 0{
                    searchDataCollection.setEmptyMessage(emptyMsg)
                }else{
                    searchDataCollection.restore()
                }
                return productViewModel.products.count
            }else{
                if articleViewModel.articles.count == 0{
                    searchDataCollection.setEmptyMessage(emptyMsg)
                }else{
                    searchDataCollection.restore()
                }
                return articleViewModel.articles.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isSearching == false{
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RecentSearchCollectionViewCell.self), for: indexPath) as? RecentSearchCollectionViewCell{
                if indexPath.row == 0{
                    cell.topConstraintTitleLbl.constant = 22
                }else{
                    cell.topConstraintTitleLbl.constant = 16
                }
                if apiType == "popularSearch"{
                    cell.titleLbl?.setAttributedTitleWithProperties(title: popularSearchDataArr[indexPath.row].title ?? "", font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black, kern: 0.5)
                }else{
                    if isForPreOwned{
                        if preOwnedRecentSearchDataArr.count > 0{
                            cell.titleLbl?.setAttributedTitleWithProperties(title: preOwnedRecentSearchDataArr[indexPath.row].title ?? "", font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black, kern: 0.5)
                        }
                    }else{
                        cell.titleLbl?.setAttributedTitleWithProperties(title: recentSearchDataArr[indexPath.row].title ?? "", font: EthosFont.Brother1816Regular(size: 10),foregroundColor: .black, kern: 0.5)
                    }
                }
                return cell
            }
        }else{
            if selectedIndexForSearch == 0 {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                    cell.hideSkeleton()
                    cell.isForPreOwned = self.isForPreOwned
                    if indexPath.item < productViewModel.products.count {
                        cell.product = productViewModel.products[indexPath.item]
                        if indexPath.item == 0 || indexPath.item == 1 {
                            cell.contraintHeightCrossBtn.constant = 20
                        } else {
                            cell.contraintHeightCrossBtn.constant = 0
                        }
                    }
                    cell.constraintBottomPrice.constant = 60
                    return cell
                }
            }else{
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SearchArticleCollectionViewCell.self), for: indexPath) as? SearchArticleCollectionViewCell {
                    cell.hideSkeleton()
                    cell.isForPreOwn = self.isForPreOwned
                    if articleViewModel.articles.count == 0{
                        cell.viewRedline.isHidden = true
                    }else{
                        cell.viewRedline.isHidden = false
                        cell.article = articleViewModel.articles[indexPath.row]
                    }
                    return cell
                }
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSearching == false {
            saerchTxtField.text = ""
            var data: GetSearchSuggestionModel?
            
            if isForPreOwned{
                if let recentSearchDataLocal = UserDefaults.standard.object(forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue) as? Data,
                   let recentSearchDataDecode = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: recentSearchDataLocal) {
                    if preOwnedRecentSearchDataArr.first(where: { $0.title?.contains(preOwnedRecentSearchDataArr[indexPath.row].title ?? "") ?? false }) != nil {
                        data = preOwnedRecentSearchDataArr.first(where: { $0.title ?? "" == preOwnedRecentSearchDataArr[indexPath.row].title ?? "" })!
                        let indexs = preOwnedRecentSearchDataArr.firstIndex(where: { ( $0.title ?? "" == preOwnedRecentSearchDataArr[indexPath.row].title ?? "" ) } ) ?? 0
                        preOwnedRecentSearchDataArr.remove(at: indexs)
                        preOwnedRecentSearchDataArr.insert(data!, at: 0)
                    } else {
                        preOwnedRecentSearchDataArr.insert(preOwnedRecentSearchDataArr[indexPath.row], at: 0)
                    }
                    
                    if let encoded = try? JSONEncoder().encode(preOwnedRecentSearchDataArr) {
                        UserDefaults.standard.set(encoded, forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue)
                    }
                    
                    if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue) as? Data,
                       let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                        preOwnedRecentSearchDataArr = data
                        searchDataCollection.reloadData()
                    }
                }else{
                    if popularSearchDataArr.first(where: { $0.title?.contains(popularSearchDataArr[indexPath.row].title ?? "") ?? false }) != nil {
                        data = popularSearchDataArr.first(where: { $0.title ?? "" == popularSearchDataArr[indexPath.row].title ?? "" })!
                        let indexs = popularSearchDataArr.firstIndex(where: { ( $0.title ?? "" == popularSearchDataArr[indexPath.row].title ?? "" ) } ) ?? 0
                        popularSearchDataArr.remove(at: indexs)
                        popularSearchDataArr.insert(data!, at: 0)
                    } else {
                        popularSearchDataArr.insert(popularSearchDataArr[indexPath.row], at: 0)
                    }
                    
                    if let encoded = try? JSONEncoder().encode(popularSearchDataArr) {
                        UserDefaults.standard.set(encoded, forKey: UserPerferenceKey.popularSearchData.rawValue)
                    }
                    
                    if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.popularSearchData.rawValue) as? Data,
                       let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                        popularSearchDataArr = data
                        searchDataCollection.reloadData()
                    }
                }
            }else{
                if let recentSearchDataLocal = UserDefaults.standard.object(forKey: UserPerferenceKey.recentSearchData.rawValue) as? Data,
                   let recentSearchDataDecode = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: recentSearchDataLocal) {
                    if recentSearchDataArr.first(where: { $0.title?.contains(recentSearchDataArr[indexPath.row].title ?? "") ?? false }) != nil {
                        data = recentSearchDataArr.first(where: { $0.title ?? "" == recentSearchDataArr[indexPath.row].title ?? "" })!
                        let indexs = recentSearchDataArr.firstIndex(where: { ( $0.title ?? "" == recentSearchDataArr[indexPath.row].title ?? "" ) } ) ?? 0
                        recentSearchDataArr.remove(at: indexs)
                        recentSearchDataArr.insert(data!, at: 0)
                    } else {
                        recentSearchDataArr.insert(recentSearchDataArr[indexPath.row], at: 0)
                    }
                    
                    if let encoded = try? JSONEncoder().encode(recentSearchDataArr) {
                        UserDefaults.standard.set(encoded, forKey: UserPerferenceKey.recentSearchData.rawValue)
                    }
                    
                    if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.recentSearchData.rawValue) as? Data,
                       let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                        recentSearchDataArr = data
                        searchDataCollection.reloadData()
                    }
                    
                }else{
                    if popularSearchDataArr.first(where: { $0.title?.contains(popularSearchDataArr[indexPath.row].title ?? "") ?? false }) != nil {
                        data = popularSearchDataArr.first(where: { $0.title ?? "" == popularSearchDataArr[indexPath.row].title ?? "" })!
                        let indexs = popularSearchDataArr.firstIndex(where: { ( $0.title ?? "" == popularSearchDataArr[indexPath.row].title ?? "" ) } ) ?? 0
                        popularSearchDataArr.remove(at: indexs)
                        popularSearchDataArr.insert(data!, at: 0)
                    } else {
                        popularSearchDataArr.insert(popularSearchDataArr[indexPath.row], at: 0)
                    }
                    
                    if let encoded = try? JSONEncoder().encode(popularSearchDataArr) {
                        UserDefaults.standard.set(encoded, forKey: UserPerferenceKey.popularSearchData.rawValue)
                    }
                    
                    if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.popularSearchData.rawValue) as? Data,
                       let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                        popularSearchDataArr = data
                        searchDataCollection.reloadData()
                    }
                }
            }
            
            if data?.type == "filter_query" || data?.type == "category"{
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NewCatalogViewController.self)) as? NewCatalogViewController {
                    vc.isForPreOwned = isForPreOwned
                    if data?.type == "filter_query"{
                        vc.productViewModel.categoryName = data?.title
                        vc.productViewModel.categoryId = Int(data?.filters?.categoryId?[0] ?? "")
                        let attrValueId = Int(data?.filters?.value?[0].attrValueId ?? "") ?? nil
                        let attributeId: Int? = attrValueId
                        
                        let attributeCode = data?.filters?.attrCode
                        let attributeName = data?.filters?.attrName
                        if attributeName?.uppercased() == EthosConstants.collection.uppercased() || attributeName?.uppercased() == EthosConstants.series.uppercased(){
                            vc.screenType = "search"
                        }else{
                            vc.screenType = ""
                        }
                        
                        var filterValues: [FilterValue] = []
                        for model in (data?.filters?.value ?? []) {
                            if let attrValueIdStr = model.attrValueId,
                               let attrValueIdInt = Int(attrValueIdStr) {
                                let filterValue = FilterValue(attributeValueId: attrValueIdInt, attributeValueName: model.attrValueName)
                                filterValues.append(filterValue)
                            }
                        }
                        
                        let filterModel = FilterModel(attributeId: attributeId, attributeCode: attributeCode, attributeName: attributeName, values: filterValues)
                        
                        if let filters = [filterModel] as? [FilterModel] {
                            vc.productViewModel.selectedFilters = filters
                        }
                    }else if data?.type == "category"{
                        vc.productViewModel.categoryName = data?.title
                        vc.productViewModel.categoryId = Int(data?.id ?? "")
                    }
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                if self.isForPreOwned {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                        vc.sku = data?.sku ?? ""
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                        vc.sku = data?.sku ?? ""
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            
        }else{
            if selectedIndexForSearch == 0 {
                if self.isForPreOwned {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                        vc.sku = productViewModel.products[indexPath.item].sku
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                        vc.sku = productViewModel.products[indexPath.item].sku
                        Mixpanel.mainInstance().trackWithLogs(
                            event: "Product Clicked",
                            properties: [
                                "Email": Userpreference.email,
                                "UID" : Userpreference.userID,
                                "Gender" : Userpreference.gender,
                                "Registered" : ((Userpreference.token == nil || Userpreference.token == "") ? "N" : "Y"),
                                "Platform" : "IOS",
                                "Product SKU" : productViewModel.products[indexPath.item].sku,
                                "Product Type" : productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.brand,
                                "Product Name" : productViewModel.products[indexPath.item].extensionAttributes?.ethProdCustomeData?.productName,
                                "SKU" : productViewModel.products[indexPath.item].sku,
                                "Price" : productViewModel.products[indexPath.item].price,
                                "Shop Type" : "Ethos",
                                "Product Sub Category" :  "Saved Products"
                            ]
                        )
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }else{
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                    vc.isForPreOwned = self.isForPreOwned
                    vc.articleId = articleViewModel.articles[indexPath.row].id
                    
                    Mixpanel.mainInstance().trackWithLogs(event: "Article Clicked", properties: [
                        "Email": Userpreference.email,
                        "UID" : Userpreference.userID,
                        "Gender" : Userpreference.gender,
                        "Registered" : ((Userpreference.token == nil || Userpreference.token == "") ? "N" : "Y"),
                        "Platform" : "IOS",
                        "Article ID": articleViewModel.articles[indexPath.row].id,
                        "Article Title" : articleViewModel.articles[indexPath.row].title,
                        "Article Category" : articleViewModel.articles[indexPath.row].category
                    ])
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isSearching {
            if selectedIndexForSearch == 0 {
                if indexPath.item == productViewModel.products.count - 2 && apiCallStatus == false{
                    callApiForSearch()
                }
            }else{
                if indexPath.item == articleViewModel.articles.count - 1 && apiCallStatus == false{
                    apiCallStatus = true
                    articleViewModel.getNewArticles(searchString: self.saerchTxtField.text ?? "", site : isForPreOwned ? .secondMovement : .ethos)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSearching == false {
            return CGSize(width: collectionView.frame.width, height: 35)
        }else{
            if selectedIndexForSearch == 0 {
                if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(2 - 1))
                    let size = CGFloat((self.view.frame.width - totalSpace) / CGFloat(2))
                    return CGSize(width: size, height: (indexPath.row == 0 || indexPath.row == 1) ? 366 : 346)
                }
            }else{
                if articleViewModel.articles[indexPath.row].title?.count ?? 0 < 30 {
                    return CGSize(width: collectionView.frame.width, height: 400)
                }else if articleViewModel.articles[indexPath.row].title?.count ?? 0 < 64 {
                    return CGSize(width: collectionView.frame.width, height: 445)
                }else{
                    return CGSize(width: collectionView.frame.width, height: 460)
                }
            }
        }
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}

extension SearchNewViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == saerchTxtField {
            dropDown.hide()
            view.endEditing(true)
            let trimmedText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if trimmedText.isEmpty {
                saerchTxtField.text = ""
            }else{
                if textField.text == "" {
                    viewFilterAndSortBy.isHidden = true
                    emptySearchField()
                } else if isSearching == false {
                    searchBtnPressStatus = true
                    emptyMsg = ""
                    isSearching = true
                    resetAllProductData()
                    callApiForSearch(tabChangeStatus: true)
                } else {
                    searchBtnPressStatus = true
                    emptyMsg = ""
                    selectBtnStatus = false
                    resetAllProductData()
                    callApiForSearch(tabChangeStatus: true)
                }
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == saerchTxtField{
            if let text = textField.text, let textRange = Range(range, in: text) {
                finalSearchString = text.replacingCharacters(in: textRange, with: string)
            }
            print(finalSearchString)
            if finalSearchString != ""{
                if finalSearchString.count > 2{
                    apiType = ""
                    callApiForSearchSuggestion(str: finalSearchString, apiType: apiType ?? "")
                }else{
                    dropDown.hide()
                }
            }else{
                dropDown.hide()
                searchBtnPressStatus = true
                emptySearchField()
                //                self.callApiForSearch()
            }
        }
        
        return true
    }
}
