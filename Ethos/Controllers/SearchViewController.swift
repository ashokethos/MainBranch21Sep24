//
//  SearchViewController.swift
//  Ethos
//
//  Created by mac on 23/09/23.
//

import UIKit
import Mixpanel
import SkeletonView

class SearchViewController: UIViewController {
    
    @IBOutlet weak var constraintHeightSearchView: NSLayoutConstraint!
    @IBOutlet weak var constraintheightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var tableViewData: UITableView!
    @IBOutlet weak var textFieldSearch: EthosTextField!
    @IBOutlet weak var collectionViewData: UICollectionView!
    @IBOutlet weak var viewTextField: UIView!
    @IBOutlet weak var collectionViewSearchedData: UICollectionView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var footerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var recentSearchTitleBackView: UIView!
    @IBOutlet weak var recentSearchTitleLbl: UILabel!
    @IBOutlet var recentSearchCollectionView: UICollectionView!
    @IBOutlet weak var recentSearchDropDownView: UIView!
    
    var recentSearchDataArr = [GetSearchSuggestionModel]()
    var preOwnedRecentSearchDataArr = [GetSearchSuggestionModel]()
    var popularSearchDataArr = [GetSearchSuggestionModel]()
    var recentSearchSelectedData = [GetSearchSuggestionModel]()
    let dropDown = DropDown()
    
    var searchSuggestionViewModel = GetSearchSuggestionViewModel()
    let articleViewModel = GetArticlesViewModel()
    var productViewModel = GetProductViewModel()
    var delegate : SuperViewDelegate?
    var emptyMsg = ""
    var finalSearchString = ""
    
    var isForPreOwned = false
    
    var apiType: String?
    var popularSearchDataEmptyStatus = true
    
    
    var ArrSearchedItemsHeader = [TitleDescriptionImageModel(title: EthosConstants.searchProductTitle, description: "", image: EthosConstants.searchWatchesIcon, btnTitle: ""), TitleDescriptionImageModel(title: EthosConstants.searchStoryTitle, description: "", image: EthosConstants.searchStoryIcon, btnTitle: "")]
    
    var ArrTableViewheader = [TitleDescriptionImageModel(title: EthosConstants.searchStoryTitle, description: "", image: EthosConstants.searchStoryIcon, btnTitle: "") , TitleDescriptionImageModel(title: EthosConstants.searchWatchesTitle, description: "", image: EthosConstants.searchWatchesIcon, btnTitle: "") ,  TitleDescriptionImageModel(title: EthosConstants.searchStoresTitle, description: "", image: EthosConstants.searchStoresIcon, btnTitle: "")]
    
    var isSearching = false {
        didSet {
            reloadUI()
        }
    }
    
    private var isKeyboardVisible: Bool = false
    
    func reloadUI() {
        if isSearching {
            tableViewData.isHidden = true
            collectionViewSearchedData.isHidden = true
            if selectedIndexForSearch == 1 {
                collectionViewData.isHidden = false
                tableViewData.isHidden = false
                collectionViewSearchedData.isHidden = false
                if self.articleViewModel.articles.count == 0 {
                    lblNoData.isHidden = false
                    constraintheightCollectionView.constant = 50
                }else{
                    lblNoData.isHidden = true
                    constraintheightCollectionView.constant = 50
                }
            } else {
                collectionViewData.isHidden = false
                tableViewData.isHidden = true
                if self.productViewModel.products.count == 0 {
                    lblNoData.isHidden = false
                    self.constraintheightCollectionView.constant = 50
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.collectionViewSearchedData.isHidden = false
                    }
                }else{
                    self.collectionViewSearchedData.isHidden = false
                    lblNoData.isHidden = true
                    constraintheightCollectionView.constant = 50
                }
            }
        } else {
            lblNoData.isHidden = true
            tableViewData.isHidden = false
            collectionViewData.isHidden = true
            collectionViewSearchedData.isHidden = true
            recentSearchCollectionView.isHidden = false
            recentSearchTitleBackView.isHidden = false
            constraintheightCollectionView.constant = 0
        }
        
        DispatchQueue.main.async {
            self.tableViewData.reloadData()
            self.collectionViewData.reloadData()
            self.collectionViewSearchedData.reloadData()
            self.view.layoutIfNeeded()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.collectionViewSearchedData.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        // Remove observers when the view controller is deallocated
        NotificationCenter.default.removeObserver(self)
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
    
    var selectedIndexForSearch = Userpreference.preferSearchProducts == true ? 0 : 1 {
        didSet {
            emptyMsg = ""
            resetData()
            if isSearching {
                if selectedIndexForSearch == 1 {
                    self.lblNoData.isHidden = true
                    self.articleViewModel.getArticles(site : isForPreOwned ? .secondMovement : .ethos , searchString: self.finalSearchString)
                } else {
                    self.productViewModel.initiate(id: 0) {
                        self.lblNoData.isHidden = true
                        self.productViewModel.getProductsFromCategory(site: self.isForPreOwned ? .secondMovement : .ethos, searchString: self.finalSearchString == "" ? " " : self.finalSearchString)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextField()
        setup()
        let properties : Dictionary<String, any MixpanelType> = [
            "Email": Userpreference.email,
            "UID" : Userpreference.userID,
            "Gender" : Userpreference.gender,
            "Registered" : ((Userpreference.token == nil || Userpreference.token == "") ? "N" : "Y"),
            "Platform" : "IOS"
        ]
        Mixpanel.mainInstance().trackWithLogs(event: "Search Clicked" , properties: properties)
    }
    
    func setup() {
        
        tableViewData.isSkeletonable = true
        collectionViewSearchedData.isSkeletonable = true
        addTapGestureToDissmissKeyBoard()
        collectionViewData.registerCell(className: SearchCollectionViewCell.self)
        recentSearchCollectionView.registerCell(className: RecentSearchCollectionViewCell.self)
        tableViewData.registerCell(className: HeadingCell.self)
        collectionViewSearchedData.registerCell(className: ProductCollectionViewCell.self)
        tableViewData.registerCell(className: HomeTableViewCell.self)
        productViewModel.delegate = self
        articleViewModel.delegate = self
        isSearching = false
        
        //Get RecentSearchData
        if isForPreOwned{
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.preOwnedRecentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                apiType = ""
                popularSearchDataEmptyStatus = false
                preOwnedRecentSearchDataArr = data
                recentSearchCollectionView.reloadData()
            }else{
                apiType = "popularSearch"
                popularSearchDataEmptyStatus = true
                callApiForSearchSuggestion(str: "", apiType: apiType)
            }
        }else{
            if let data = UserDefaults.standard.object(forKey: UserPerferenceKey.recentSearchData.rawValue) as? Data,
               let data = try? JSONDecoder().decode([GetSearchSuggestionModel].self, from: data) {
                apiType = ""
                popularSearchDataEmptyStatus = false
                recentSearchDataArr = data
                recentSearchCollectionView.reloadData()
            }else{
                apiType = "popularSearch"
                popularSearchDataEmptyStatus = true
                callApiForSearchSuggestion(str: "", apiType: apiType)
            }
        }
        
        let columnLayout = CustomViewFlowLayout()
        columnLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        recentSearchCollectionView.collectionViewLayout = columnLayout
        recentSearchCollectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            textFieldSearch.text = ""
            apiType = ""
            recentSearchCollectionView.isHidden = false
            recentSearchTitleBackView.isHidden = false
            dropDownSelectData(index: index, item: item)
        }
    }
    
    func dropDownSelectData(index: Int, item: String?){
        if isForPreOwned{
            if popularSearchDataEmptyStatus{
                preOwnedRecentSearchDataArr.removeAll()
                popularSearchDataEmptyStatus = false
            }
            
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
                recentSearchCollectionView.reloadData()
            }
        }else{
            if popularSearchDataEmptyStatus{
                recentSearchDataArr.removeAll()
                popularSearchDataEmptyStatus = false
            }
            
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
                recentSearchCollectionView.reloadData()
            }
        }
        
        if recentSearchSelectedData[index].type == "category" || recentSearchSelectedData[index].type == "filter_query"{
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !tableViewData.isDecelerating {
            view.endEditing(true)
        }
    }
    
    func setTextField() {
        
        textFieldSearch.delegate = self
        viewTextField.setBorder(borderWidth: 1, borderColor: EthosColor.lightGrey, radius: 25)
        let btnCross = UIButton(type: .custom)
        btnCross.setImage(UIImage.imageWithName(name: EthosConstants.cross), for: .normal)
        btnCross.backgroundColor = .white
        btnCross.addTarget(self, action: #selector(btnCrossDidTapped(_ :)), for: .touchUpInside)
        
        textFieldSearch.initWithUIParameters(placeHolderText: EthosConstants.SearchPlaceHolder, placeholderColor: UIColor(white: 0, alpha: 0.3),  underLineColor: .clear, errUnderLineColor: .clear, textInset: 0)
        
        textFieldSearch.adjustsFontSizeToFitWidth = true
    }
    
    @IBAction func btnCrossDidTapped(_ sender : UIButton) {
        if isSearching == true {
            self.selectedIndexForSearch = Userpreference.preferSearchProducts == true ? 0 : 1
            self.textFieldSearch.text = ""
            self.textFieldSearch.endEditing(true)
            self.finishSearching()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func callApiForSearch() {
        self.selectedIndexForSearch = Userpreference.preferSearchProducts == true ? 0 : 1
        if isSearching {
            emptyMsg = ""
            if self.selectedIndexForSearch == 1 {
                self.lblNoData.isHidden = true
                self.articleViewModel.getArticles(site: self.isForPreOwned ? .secondMovement : .ethos, searchString : finalSearchString)
            } else {
                self.productViewModel.initiate(id: 0) {
                    self.lblNoData.isHidden = true
                    self.productViewModel.getProductsFromCategory(site: self.isForPreOwned ? .secondMovement : .ethos, searchString: self.finalSearchString == "" ? " " : self.finalSearchString)
                }
            }
            
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
    
    func callApiForSearchSuggestion(str: String?, apiType: String?) {
        self.searchSuggestionViewModel.delegate = self
        self.searchSuggestionViewModel.getSearchSuggestion(searchString: str ?? "", apiType: apiType ?? "", site: self.isForPreOwned ? .secondMovement : .ethos)
        Mixpanel.mainInstance().trackWithLogs(event: "Search Used" , properties: ["Search term":self.textFieldSearch.text ?? ""])
    }
}

extension SearchViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldSearch {
            recentSearchCollectionView.isHidden = true
            recentSearchTitleBackView.isHidden = true
            dropDown.hide()
            view.endEditing(true)
            if textField.text == "" {
                self.selectedIndexForSearch = Userpreference.preferSearchProducts == true ? 0 : 1
                self.finishSearching()
            } else if isSearching == false {
                self.startSearching()
                self.callApiForSearch()
            } else {
                self.callApiForSearch()
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == textFieldSearch{
            if range.length > 0 {
                finalSearchString = "\(textField.text?.dropLast() ?? "")"
            } else {
                finalSearchString = "\((textField.text ?? "") + string)"
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
                self.callApiForSearch()
            }
        }
        
        return true
    }
    
    func startSearching() {
        isSearching = true
        resetData()
    }
    
    func finishSearching() {
        isSearching = false
        recentSearchTitleBackView.isHidden = false
        recentSearchCollectionView.isHidden = false
        resetData()
    }
    
    func resetData() {
        productViewModel.products.removeAll()
        articleViewModel.articles.removeAll()
        reloadUI()
    }
}

extension SearchViewController : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout, GetSearchSuggestionViewModelDelegate {
    
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
                recentSearchCollectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case collectionViewData:
            return isSearching ? ArrSearchedItemsHeader.count : 0
            
        case recentSearchCollectionView:
            recentSearchTitleLbl.text = apiType == "popularSearch" ? "Popular Searches" : "Recent Searches"
            if apiType == "popularSearch" {
                return popularSearchDataArr.count
            } else if isForPreOwned {
                return preOwnedRecentSearchDataArr.count
            } else {
                return recentSearchDataArr.count
            }
            
        case collectionViewSearchedData:
            guard isSearching, selectedIndexForSearch == 0 else {
                return 0
            }
            lblNoData.text = emptyMsg
//            if productViewModel.products.count == 0{
//                collectionViewSearchedData.setEmptyMessage(emptyMsg)
//            }else{
//                collectionViewSearchedData.restore()
//            }
            return productViewModel.products.count
            
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionViewData {
            return CGSize(width: 20, height: 50)
        } else if collectionView == recentSearchCollectionView {
            return CGSize(width: 20, height: 10)
        }else if collectionView == collectionViewSearchedData {
            if let flowLayout = collectionViewSearchedData.collectionViewLayout as? UICollectionViewFlowLayout {
                let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(2 - 1))
                let size = CGFloat((self.view.frame.width - totalSpace) / CGFloat(2))
                return CGSize(width: size, height: (indexPath.row == 0 || indexPath.row == 1) ? 356 : 346)
            }
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewData {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SearchCollectionViewCell.self), for: indexPath) as? SearchCollectionViewCell {
                if indexPath.item < ArrSearchedItemsHeader.count {
                    if (self.selectedIndexForSearch == indexPath.item) {
                        cell.lblTitle.setAttributedTitleWithProperties(title: ArrSearchedItemsHeader[indexPath.item].title, font: EthosFont.Brother1816Regular(size: 10), foregroundColor: UIColor.black, showUnderline: true)
                    } else {
                        cell.lblTitle.setAttributedTitleWithProperties(title: ArrSearchedItemsHeader[indexPath.item].title, font: EthosFont.Brother1816Regular(size: 10), foregroundColor: EthosColor.darkGrey)
                    }
                    
                    cell.imageView.image = UIImage.imageWithName(name: ArrSearchedItemsHeader[indexPath.item].image).withTintColor( !(self.selectedIndexForSearch == indexPath.item) ? EthosColor.darkGrey : UIColor.black, renderingMode: .alwaysOriginal)
                }
                return cell
            }
        } else if collectionView == recentSearchCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RecentSearchCollectionViewCell.self), for: indexPath) as? RecentSearchCollectionViewCell{
                if apiType == "popularSearch"{
                    cell.titleLbl?.text = (popularSearchDataArr[indexPath.row].title)?.shorted(to: 36)
                }else{
                    if isForPreOwned{
                        if preOwnedRecentSearchDataArr.count > 0{
                            cell.titleLbl?.text = (preOwnedRecentSearchDataArr[indexPath.row].title)?.shorted(to: 36)
                        }
                    }else{
                        cell.titleLbl?.text = (recentSearchDataArr[indexPath.row].title)?.shorted(to: 36)
                    }
                }
                return cell
            }
        }else if collectionView == collectionViewSearchedData {
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
            print("dbfvasbdbasjkjdklasjdlja")
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  collectionView == collectionViewData {
            self.selectedIndexForSearch = indexPath.item
        }  else if  collectionView == recentSearchCollectionView {
            textFieldSearch.text = ""
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
                        recentSearchCollectionView.reloadData()
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
                        recentSearchCollectionView.reloadData()
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
                        recentSearchCollectionView.reloadData()
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
                        recentSearchCollectionView.reloadData()
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
            
        }else if collectionView == collectionViewSearchedData {
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
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == collectionViewSearchedData && indexPath.item == self.productViewModel.products.count - 1 && self.selectedIndexForSearch == 0 && self.isSearching {
            self.productViewModel.initiate(id: 0) {
                self.productViewModel.getNewProducts(site: self.isForPreOwned ? .secondMovement : .ethos, searchString: self.textFieldSearch.text ?? "")
            }
        }
    }
}

extension SearchViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            if selectedIndexForSearch == 1{
                if articleViewModel.articles.count == 0{
                    tableView.setEmptyMessage(emptyMsg)
                }else{
                    tableView.restore()
                }
                return articleViewModel.articles.count
            } else {
//                if productViewModel.products.count == 0{
//                    tableView.setEmptyMessage(emptyMsg)
//                }else{
//                    tableView.restore()
//                }
                lblNoData.text = emptyMsg
                return productViewModel.products.count
            }
        } else {
            //            return ArrTableViewheader.count
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            if selectedIndexForSearch == 1 {
                if indexPath.row < articleViewModel.articles.count {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as? HomeTableViewCell {
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
                
            } else {
                return UITableViewCell()
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                if indexPath.row < ArrTableViewheader.count {
                    cell.setHeading (
                        title: ArrTableViewheader[indexPath.row].title,
                        image: UIImage.imageWithName(name: ArrTableViewheader[indexPath.row].image),
                        imageHeight: 20,
                        spacingTitleImage:  10,
                        disclosureImageDefault:  UIImage.imageWithName(name: EthosConstants.diagonalArrowIcon),
                        disclosureHeight: 20,
                        disclosureWidth: 20
                    )
                }
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isSearching == false {
            return 50
        } else {
            return UITableView.automaticDimension
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearching {
            
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
        } else {
            if indexPath.row == 0 {
                if isForPreOwned {
                    var found = false
                    for vc in self.navigationController?.viewControllers ?? [] {
                        if vc is PreOwnedViewController {
                            (vc as? SuperViewDelegate)?.updateView(info: [EthosKeys.key : EthosKeys.visitArticles])
                            self.navigationController?.popToViewController(vc, animated: true)
                            found = true
                            break
                        }
                    }
                    
                    if found == false {
                        self.navigationController?.popToRootViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            UIApplication.topViewController()?.tabBarController?.selectedIndex = 3
                            DispatchQueue.main.async {
                                if UIApplication.topViewController() is PreOwnedViewController {
                                    (((UIApplication.topViewController()) as? PreOwnedViewController))?.updateView(info: [EthosKeys.key : EthosKeys.visitArticles])
                                }
                            }
                        }
                    }
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        UIApplication.topViewController()?.tabBarController?.selectedIndex = 0
                    }
                }
            } else if indexPath.row == 1 {
                if isForPreOwned {
                    var found = false
                    for vc in self.navigationController?.viewControllers ?? [] {
                        if vc is PreOwnedViewController {
                            (vc as? SuperViewDelegate)?.updateView(info: [EthosKeys.key : EthosKeys.visitProducts])
                            self.navigationController?.popToViewController(vc, animated: true)
                            found = true
                            break
                        }
                    }
                    
                    if found == false {
                        self.navigationController?.popToRootViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            UIApplication.topViewController()?.tabBarController?.selectedIndex = 3
                            DispatchQueue.main.async {
                                if UIApplication.topViewController() is PreOwnedViewController {
                                    (((UIApplication.topViewController()) as? PreOwnedViewController))?.updateView(info: [EthosKeys.key : EthosKeys.visitProducts])
                                }
                            }
                        }
                    }
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        UIApplication.topViewController()?.tabBarController?.selectedIndex = 2
                    }
                }
            } else if indexPath.row == 2 {
                if isForPreOwned {
                    var found = false
                    for vc in self.navigationController?.viewControllers ?? [] {
                        if vc is PreOwnedViewController {
                            (vc as? SuperViewDelegate)?.updateView(info: [EthosKeys.key : EthosKeys.visitOurBoutique])
                            self.navigationController?.popToViewController(vc, animated: true)
                            found = true
                            break
                        }
                    }
                    
                    if found == false {
                        self.navigationController?.popToRootViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            UIApplication.topViewController()?.tabBarController?.selectedIndex = 3
                            DispatchQueue.main.async {
                                if UIApplication.topViewController() is PreOwnedViewController {
                                    (((UIApplication.topViewController()) as? PreOwnedViewController))?.updateView(info: [EthosKeys.key : EthosKeys.visitOurBoutique])
                                }
                            }
                        }
                    }
                } else {
                    self.navigationController?.popToRootViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosStoreViewController.self)) as? EthosStoreViewController {
                            vc.isForPreOwn = self.isForPreOwned
                            UIApplication.topViewController()?.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (tableView == tableViewData) && indexPath.row == (self.articleViewModel.articles.count - 1) && isSearching == true && self.selectedIndexForSearch == 1 {
            self.articleViewModel.getNewArticles(searchString: self.textFieldSearch.text ?? "", site : isForPreOwned ? .secondMovement : .ethos)
        }
    }
}

extension SearchViewController : GetProductViewModelDelegate {
    func didGetProducts(site : Site?, CategoryId : Int?) {
        if productViewModel.products.count == 0 {
            emptyMsg = "SORRY, NO RESULTS WERE FOUND."
        }else{
            emptyMsg = ""
        }
        DispatchQueue.main.async {
            self.reloadUI()
        }
        
    }
    
    func errorInGettingProducts(error: String) {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.tableViewData.showAnimatedGradientSkeleton()
            self.collectionViewSearchedData.showAnimatedGradientSkeleton()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.tableViewData.hideSkeleton()
            self.collectionViewSearchedData.hideSkeleton()
        }
    }
    
    func startFooterIndicator() {
        DispatchQueue.main.async {
            self.footerIndicator.startAnimating()
        }
    }
    
    func stopFooterIndicator() {
        DispatchQueue.main.async {
            self.footerIndicator.stopAnimating()
        }
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

extension SearchViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        if articleViewModel.articles.count == 0{
            emptyMsg = "SORRY, NO RESULTS WERE FOUND."
        }else{
            emptyMsg = ""
        }
        DispatchQueue.main.async {
            self.reloadUI()
        }
    }
    
    func errorInGettingArticles(error: String) {
        
    }
}

extension SearchViewController : SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "HomeTableViewCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as? HomeTableViewCell {
            if selectedIndexForSearch == 1 {
                cell.viewRedline.isHidden = true
                cell.isForPreOwn = self.isForPreOwned
                cell.contentView.showAnimatedGradientSkeleton()
            }else{
                cell.viewRedline.isHidden = true
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
}

extension SearchViewController : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "ProductCollectionViewCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell?  {
        if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
            cell.showAnimatedGradientSkeleton()
            if indexPath.item == 0 || indexPath.item == 1 {
                cell.contraintHeightCrossBtn.constant = 20
            } else {
                cell.contraintHeightCrossBtn.constant = 0
            }
            cell.isForPreOwned = self.isForPreOwned
            cell.constraintBottomPrice.constant = 60
            return cell
        }
        
        return nil
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
}

class CustomViewFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 10
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 10.0
        self.sectionInset = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 16.0)
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}
