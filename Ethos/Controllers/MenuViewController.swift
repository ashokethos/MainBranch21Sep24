//
//  MenuViewController.swift
//  Ethos
//
//  Created by mac on 18/09/23.
//

import Foundation
import UIKit
import Mixpanel

class MenuViewController: UIViewController {
    
    @IBOutlet weak var constraintHeightSearchView: NSLayoutConstraint!
    @IBOutlet weak var constraintheightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var tableViewData: UITableView!
    @IBOutlet weak var textFieldSearch: EthosTextField!
    @IBOutlet weak var collectionViewData: UICollectionView!
    @IBOutlet weak var viewTextField: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewSearchedData: UICollectionView!
    @IBOutlet weak var collectionViewAlphabets: UICollectionView!
    
    @IBOutlet weak var constraintTrailing: NSLayoutConstraint!
    let categoryViewModel = GetCategoryViewModel()
    let articleViewModel = GetArticlesViewModel()
    var productViewModel = GetProductViewModel()
    
    var values = [AlphabeticFilters]()
    
    var isForPreOwn = false
    
    var isSearching = false {
        didSet {
            reloadUI()
        }
    }
    
    func reloadUI() {
        if isSearching {
            constraintTrailing.constant = 0
            if selectedIndexForSearch == 0 {
                tableViewData.isHidden = false
                collectionViewSearchedData.isHidden = true
                collectionViewAlphabets.isHidden = true
                
            } else {
                tableViewData.isHidden = true
                collectionViewSearchedData.isHidden = false
                collectionViewAlphabets.isHidden = true
            }
        } else {
            constraintTrailing.constant = -20
            tableViewData.isHidden = false
            collectionViewSearchedData.isHidden = true
            collectionViewAlphabets.isHidden = false
        }
    }
    
    var selectedIndexForSearch = 0 {
        didSet {
            self.collectionViewData.reloadData()
            self.collectionViewSearchedData.reloadData()
            reloadUI()
            if isSearching {
                if selectedIndexForSearch == 0 {
                    self.articleViewModel.getArticles(site: self.isForPreOwn ? .secondMovement : .ethos,searchString: self.textFieldSearch.text ?? "")
                } else {
                    self.productViewModel.initiate(id: 0) {
                        self.productViewModel.getProductsFromCategory(site: self.isForPreOwn ? .secondMovement : .ethos, searchString: self.textFieldSearch.text ?? "")
                    }
                }
            }
        }
    }
    var ArrSearchedItemsHeader = ["Articles" , "Products"]
    var selectedIndex = 0 {
        didSet {
            self.collectionViewData.reloadData()
            reloadUI()
            if self.selectedIndex < categoryViewModel.categories.count {
                self.indicator.startAnimating()
                self.productViewModel.categoryId = self.categoryViewModel.categories[selectedIndex].id ?? 0
                self.productViewModel.getFilters()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextField()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        self.collectionViewData.registerCell(className: DiscoveryTabsCell.self)
        self.tableViewData.registerCell(className: HeadingCell.self)
        self.collectionViewAlphabets.registerCell(className: SingleCharacterCollectionViewCell.self)
        self.collectionViewSearchedData.registerCell(className: ProductCollectionViewCell.self)
        self.tableViewData.registerCell(className: HomeTableViewCell.self)
        categoryViewModel.delegate = self
        productViewModel.delegate = self
        articleViewModel.delegate = self
        isSearching = false
        categoryViewModel.getCategories()
    }
    
    func setTextField() {
        
        textFieldSearch.delegate = self
        viewTextField.setBorder(borderWidth: 1, borderColor: .black, radius: 30)
        let imgView = UIImageView(image: UIImage.imageWithName(name: EthosConstants.search))
        let btnCross = UIButton(type: .custom)
        btnCross.setImage(UIImage.imageWithName(name: EthosConstants.cross), for: .normal)
        btnCross.addTarget(self, action: #selector(btnCrossDidTapped(_ :)), for: .touchUpInside)
        
        textFieldSearch.initWithUIParameters(placeHolderText: EthosConstants.SearchPlaceHolder, leftView: imgView,rightView: btnCross,placeholderColor: UIColor(white: 0, alpha: 0.3),  underLineColor: .clear, errUnderLineColor: .clear,  leftViewHeight: 20, leftViewWidth: 20, rightViewWidth: 20, rightViewHeight: 20, textInset: 10)
    }
    
    @objc func btnCrossDidTapped(_ sender : UIButton) {
        if isSearching == true {
            self.textFieldSearch.text = ""
            self.textFieldSearch.endEditing(true)
            self.finishSearching()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func callApiForSearch() {
        if isSearching {
            if self.selectedIndexForSearch == 0 {
                self.articleViewModel.getArticles(searchString : self.textFieldSearch.text ?? "")
            } else {
                self.productViewModel.initiate(id: 0) {
                    self.productViewModel.getProductsFromCategory(site: self.isForPreOwn ? .secondMovement : .ethos, searchString: self.textFieldSearch.text ?? "")
                }
            }
        }
    }
    
    
    
}

extension MenuViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldSearch {
            textField.endEditing(true)
            if textField.text == "" {
                self.finishSearching()
            } else if isSearching == false {
                self.startSearching()
            }
            self.callApiForSearch()
        }
        
        return true
    }
    
    func startSearching() {
        self.isSearching = true
        self.resetData()
    }
    
    func finishSearching() {
        self.isSearching = false
        self.resetData()
        
    }
    
    func resetData() {
        self.productViewModel.products.removeAll()
        self.articleViewModel.articles.removeAll()
        self.values.removeAll()
        self.selectedIndexForSearch = Userpreference.preferSearchProducts == true ? 0 : 1
        self.selectedIndex = 0
        self.collectionViewData.reloadData()
        self.collectionViewAlphabets.reloadData()
        self.collectionViewSearchedData.reloadData()
    }
    
}

extension MenuViewController : GetCategoryViewModelDelegate {
    func didFailedToGetCategories() {
        
    }
    
    func didGetCategories() {
        self.selectedIndex = 0
    }
    
}

extension MenuViewController : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if collectionView == collectionViewData {
            if isSearching {
                return ArrSearchedItemsHeader.count
            } else {
                return categoryViewModel.categories.count
            }
        } else if collectionView == collectionViewSearchedData {
            if isSearching {
                if self.selectedIndexForSearch == 1 {
                    return productViewModel.products.count
                }
            }
        } else if collectionView == self.collectionViewAlphabets {
            return EthosConstants.alphabets.count
        }
        
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionViewData {
            if isSearching {
                return collectionView.cellSize(noOfCellsInRow: 2, Height: 50)
            } else {
                return CGSize(width: 50, height: 50)
            }
        } else if collectionView == collectionViewSearchedData {
            
            return collectionView.cellSize(noOfCellsInRow: 2, Height: 346)
        } else if collectionView == collectionViewAlphabets {
            return CGSize(width: 20, height: 20)
        }
        
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewData {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DiscoveryTabsCell.self), for: indexPath) as? DiscoveryTabsCell {
                if isSearching {
                    cell.lblTitle.text = ArrSearchedItemsHeader[indexPath.item]
                    if selectedIndexForSearch == indexPath.item {
                        cell.viewIndicator.backgroundColor = .black
                    } else {
                        cell.viewIndicator.backgroundColor = .clear
                    }
                } else {
                    if selectedIndex == indexPath.item {
                        cell.viewIndicator.backgroundColor = .black
                    } else {
                        cell.viewIndicator.backgroundColor = .clear
                    }
                    cell.lblTitle.text = categoryViewModel.categories[indexPath.item].name
                }
                return cell
            }
        } else if collectionView == collectionViewSearchedData {
                if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ProductCollectionViewCell.self), for: indexPath) as? ProductCollectionViewCell {
                    cell.isForPreOwned = self.isForPreOwn
                    cell.product = productViewModel.products[indexPath.item]
                    cell.constraintBottomPrice.constant = 60
                    return cell
                }
        } else if collectionView == collectionViewAlphabets {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SingleCharacterCollectionViewCell.self), for: indexPath) as? SingleCharacterCollectionViewCell {
                cell.lblCharacter.text = EthosConstants.alphabets[indexPath.item]
                if values.contains(where: { value in
                    value.header == EthosConstants.alphabets[indexPath.item]
                }) {
                    cell.lblCharacter.textColor = .black
                } else {
                    cell.lblCharacter.textColor = EthosColor.seperatorColor
                }
                return cell
            }
        }
        
        
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  collectionView == collectionViewData {
            if isSearching == false {
                self.selectedIndex = indexPath.item
            } else {
                self.selectedIndexForSearch = indexPath.item
            }
        } else if collectionView == collectionViewAlphabets {
            
            if self.values.contains(where: { filter in
                filter.header == EthosConstants.alphabets[safe : indexPath.row]
            }) {
                if let index = values.firstIndex(where: { filter in
                    filter.header == EthosConstants.alphabets[safe : indexPath.row]
                }) {
                    self.tableViewData.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: true)
                }
            }
        } else if collectionView == collectionViewSearchedData {
            if self.isForPreOwn {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SecondMovementProductDetailsVC.self)) as? SecondMovementProductDetailsVC {
                    vc.sku = productViewModel.products[indexPath.item].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProductDetailViewController.self)) as? ProductDetailViewController {
                    vc.sku = productViewModel.products[indexPath.item].sku
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

extension MenuViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewData {
            if isSearching {
                if selectedIndexForSearch == 0 {
                    return articleViewModel.articles.count
                } else {
                    return productViewModel.products.count
                }
            } else {
                if values.count > section {
                    return values[section].values.count
                } else {
                    return 0
                }
            }
        } else {
            if isSearching {
                return 0
            } else {
                return EthosConstants.alphabets.count
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tableViewData {
            if isSearching == false {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    if section < self.values.count {
                        cell.setHeading(title: values[section].header.uppercased())
                    }
                    return cell
                }
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableViewData {
            if isSearching {
                return 1
            } else {
                return self.values.count
            }
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewData {
            if isSearching {
                if selectedIndexForSearch == 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as? HomeTableViewCell {
                        cell.article = articleViewModel.articles[safe : indexPath.row]
                        cell.isForPreOwn = self.isForPreOwn
                        return cell
                    }
                } else {
                    return UITableViewCell()
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    cell.setHeading(title: values[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName?.uppercased() ?? "")
                    return cell
                }
            }} else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    
                    cell.setHeading(title: EthosConstants.alphabets[safe : indexPath.row]?.uppercased() ?? "" )
                    return cell
                }
            }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableViewData {
            if isSearching == false {
                return 50
            } else {
                return UITableView.automaticDimension
            }
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tableViewData {
            if isSearching {
                return 0
            } else {
                return 50
            }
        } else {
            return 0
        }
        
    }
}

extension MenuViewController : GetProductViewModelDelegate {
    func didGetProducts(site : Site?, CategoryId : Int?) {
        DispatchQueue.main.async {
            self.collectionViewSearchedData.reloadData()
            self.collectionViewSearchedData.reloadData()
        }
    }
    
    func errorInGettingProducts(error: String) {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
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
        DispatchQueue.main.async {
            for filter in self.productViewModel.filters {
                if filter.attributeName?.lowercased() == EthosConstants.brand {
                    self.values = filter.alphabeticFilterValues ?? [AlphabeticFilters]()
                }
            }
            self.indicator.stopAnimating()
            self.tableViewData.reloadData()
            self.collectionViewAlphabets.reloadData()
        }
    }
    
    func errorInGettingFilters() {
        
    }
    
    
}

extension MenuViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        self.tableViewData.reloadData()
    }
    
    func errorInGettingArticles(error: String) {
        
    }
    
    
}
