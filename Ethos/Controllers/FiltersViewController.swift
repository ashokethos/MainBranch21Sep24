//
//  FiltersViewController.swift
//  Ethos
//
//  Created by mac on 15/09/23.
//

import UIKit
import Mixpanel

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var tableViewFilters: UITableView!
    @IBOutlet weak var tableViewValues: UITableView!
    @IBOutlet weak var textFieldSearch: EthosTextField!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnApplyFilters: UIButton!
    @IBOutlet weak var constraintTextField: NSLayoutConstraint!
    @IBOutlet weak var viewTextFieldSeperator: UIView!
    
    var viewModel = GetProductViewModel()
    var delegate : SuperViewDelegate?
    var isForPreOwned = false
    var screenType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        self.addTapGestureToDissmissKeyBoard()
        self.tableViewValues.registerCell(className: HeadingCell.self)
        self.tableViewValues.registerCell(className: PriceSliderTableViewCell.self)
        self.tableViewFilters.registerCell(className: HeadingCell.self)
        self.tableViewFilters.registerCell(className: SingleButtonWithDisclosureTableViewCell.self)
        let image = UIImageView(image: UIImage.imageWithName(name: EthosConstants.search))
        self.textFieldSearch.initWithUIParameters(placeHolderText: "Search",leftView: image, textInset: 10)
        self.btnReset.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        self.btnApplyFilters.setAttributedTitleWithProperties(title: "APPLY FILTERS", font: EthosFont.Brother1816Medium(size: 12),foregroundColor: .white, backgroundColor: .black, kern: 1)
        self.btnReset.setAttributedTitleWithProperties(title: "RESET", font: EthosFont.Brother1816Medium(size: 12),foregroundColor: .black, backgroundColor: .white, kern: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.filters.count > 0 {
            viewModel.selectedFilter = viewModel.filters.first
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.reloadView()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true)
    }
    
    func reloadView() {
        if self.viewModel.selectedFilter?.attributeName?.uppercased() == "PRICE" {
            self.textFieldSearch.isHidden = true
            self.viewTextFieldSeperator.isHidden = true
            self.constraintTextField.constant = 0
            
        } else {
            self.textFieldSearch.isHidden = false
            self.viewTextFieldSeperator.isHidden = false
            self.constraintTextField.constant = 50
        }
        
        self.tableViewFilters.reloadData()
        self.tableViewValues.reloadData()
        self.lblTitle.text = "Filter products".uppercased()
        self.textFieldSearch.initWithUIParameters(placeHolderText: "Search")
        self.view.layoutIfNeeded()
    }
    
    
    @IBAction func textFieldSearchDidChangeValue(_ sender: EthosTextField) {
        self.tableViewFilters.reloadData()
        self.tableViewValues.reloadData()
    }
    
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResetDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.resetFilters])
        }
    }
    
    @IBAction func btnApplyFiltersDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.applyFilters, EthosKeys.selectedFilters : self.viewModel.selectedFilters, EthosKeys.filters : self.viewModel.filters, EthosKeys.lowerPriceLimit : self.viewModel.lowerPriceLimit, EthosKeys.upperPriceLimit : self.viewModel.upperPriceLimit, EthosKeys.minPriceLimit : self.viewModel.minPriceLimit, EthosKeys.maxPriceLimit : self.viewModel.maxPriceLimit])
        }
    }
}


extension FiltersViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableViewFilters {
            return 1
        }
        
        if tableView == tableViewValues {
            if viewModel.selectedFilter?.attributeName?.lowercased() == "price" {
                return 1
            } else {
                if self.textFieldSearch.text == "" || self.textFieldSearch.text == nil {
                    return viewModel.selectedFilter?.alphabeticFilterValues?.count ?? 0
                } else {
                    return viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?.count ?? 0
                }
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableViewFilters {
            return viewModel.filters.count
        }
        
        if tableView == tableViewValues {
            if viewModel.selectedFilter?.attributeName?.lowercased() == "price" {
                return 1
            } else {
                if self.textFieldSearch.text == "" || self.textFieldSearch.text == nil {
                    return viewModel.selectedFilter?.alphabeticFilterValues?[section].values.count ?? 0
                } else {
                    return viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[section].values.count ?? 0
                }
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableViewValues {
            if self.viewModel.selectedFilter?.attributeName?.lowercased() == "price" {
                return nil
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    
                    if self.textFieldSearch.text == "" || self.textFieldSearch.text == nil {
                        cell.setHeading(title: viewModel.selectedFilter?.alphabeticFilterValues?[section].header.uppercased() ?? "", numberOfLines : 0, leading: 10, trailling: 10, topSpacing: 10, bottomSpacing: 10)
                        
                    } else {
                        cell.setHeading(title: viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[section].header.uppercased() ?? "", numberOfLines : 0, leading: 10, trailling: 10, topSpacing: 10, bottomSpacing: 10)
                    }
                    
                    return cell
                }
            }
        }
        
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView == self.tableViewValues {
            if viewModel.selectedFilter?.attributeName?.lowercased() == "price" {
                return 0
            } else {
                return UITableView.automaticDimension
            }
            
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tableViewFilters {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SingleButtonWithDisclosureTableViewCell.self)) as? SingleButtonWithDisclosureTableViewCell {
                cell.btn.isUserInteractionEnabled = false
                cell.txtBtn.isUserInteractionEnabled = false
                cell.btnDisClosure.isUserInteractionEnabled = false
                cell.txtBtn.titleLabel?.numberOfLines = 0
                cell.constraintSpacingBtnTitle.constant = 10
                cell.constraintTopSpacing.constant = 10
                cell.constraintBottomSpacing.constant = 10
                var containsvalue = false
                if viewModel.selectedValues.contains(where: { val in
                    val.filterModelName == viewModel.filters[safe : indexPath.row]?.attributeName
                }) {
                    containsvalue = true
                }
                
                if viewModel.filters[safe : indexPath.row]?.attributeName?.uppercased() == "PRICE", self.viewModel.lowerPriceLimit != nil, self.viewModel.upperPriceLimit != nil {
                    containsvalue = true
                }
                
                if viewModel.selectedFilter?.attributeName == viewModel.filters[safe : indexPath.row]?.attributeName {
                    
                    cell.txtBtn.setAttributedTitleWithProperties(title: viewModel.filters[safe : indexPath.row]?.attributeName?.uppercased() ?? "", font: EthosFont.Brother1816Bold(size: 12))
                    
                } else {
                    cell.txtBtn.setAttributedTitleWithProperties(title: viewModel.filters[safe : indexPath.row]?.attributeName?.uppercased() ?? "", font: EthosFont.Brother1816Regular(size: 12))
                }
                
                cell.btnDisClosure.setImage(containsvalue ? UIImage.imageWithName(name: "redDot") : nil , for: .normal)
                
                cell.constraintLeading.constant = 20
                return cell
            }
        }
        
        if tableView == tableViewValues {
            if viewModel.selectedFilter?.attributeName?.lowercased() == "price" {
              
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PriceSliderTableViewCell.self)) as? PriceSliderTableViewCell {
                    cell.superController = self
                    cell.setSliderWithValues(viewModel: self.viewModel)
                  
                    return cell
                }
            } else {
                
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                    
                    if self.textFieldSearch.text == "" || self.textFieldSearch.text == nil {
                        if viewModel.selectedValues.contains(where: { value in
                            (viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueId == value.filtervalue.attributeValueId) && (viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName == value.filtervalue.attributeValueName)
                        }) {
                            
                            cell.setHeading(title: viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName?.uppercased() ?? "", font: EthosFont.Brother1816Regular(size: 12), numberOfLines : 0, image: UIImage.imageWithName(name: EthosConstants.checkboxSelected), imageHeight: 16, spacingTitleImage: 10, leading: 10, trailling: 10, topSpacing: 10, bottomSpacing: 10)
                            
                        } else {
                            
                            cell.setHeading(title: viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName?.uppercased() ?? "", font: EthosFont.Brother1816Regular(size: 12), numberOfLines : 0, image: UIImage.imageWithName(name: EthosConstants.checkboxUnselected), imageHeight: 16, spacingTitleImage: 10, leading: 10, trailling: 10, topSpacing: 10, bottomSpacing: 10)
                            
                        }
                        
                        
                    } else {
                        if viewModel.selectedValues.contains(where: { value in
                            (viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueId == value.filtervalue.attributeValueId) && (viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName == value.filtervalue.attributeValueName)
                        }) {
                            
                            cell.setHeading(title: viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName?.uppercased() ?? "", font: EthosFont.Brother1816Regular(size: 12), numberOfLines : 0, image: UIImage.imageWithName(name: EthosConstants.checkboxSelected), imageHeight: 16, spacingTitleImage: 10, leading: 10, trailling: 10, topSpacing: 10, bottomSpacing: 10)
                            
                        } else {
                            
                            cell.setHeading(title: viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName?.uppercased() ?? "", font: EthosFont.Brother1816Regular(size: 12), numberOfLines : 0, image: UIImage.imageWithName(name: EthosConstants.checkboxUnselected), imageHeight: 16, spacingTitleImage: 10, leading: 10, trailling: 10, topSpacing: 10, bottomSpacing: 10)
                            
                        }
                    }
                    
                    
                    if let text = cell.titleLabel.text {
                        let components = text.components(separatedBy: " ")
                        if components.contains("MM") {
                            cell.titleLabel.text = text.replacingOccurrences(of: "MM", with: "mm")
                        }
                    }
                    
                    return cell
                }
            }
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tableViewFilters {
            self.textFieldSearch.text = ""
            viewModel.selectedFilter = viewModel.filters[safe : indexPath.row]
            self.reloadView()
        }
        
        if tableView == tableViewValues {
            if viewModel.selectedFilter?.attributeName?.lowercased() == "price" {
               
            } else {
                if self.textFieldSearch.text == "" || self.textFieldSearch.text == nil {
                    
                    if viewModel.selectedValues.contains(where: { value in
                        (viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueId == value.filtervalue.attributeValueId &&  viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName == value.filtervalue.attributeValueName)
                    }) {
                        viewModel.selectedValues.removeAll { value in
                            (value.filtervalue.attributeValueId ==  viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueId && value.filtervalue.attributeValueName ==  viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName)
                        }
                        
                        
                        
                    } else {
                        let selectedModel = SelectedFilterData(filterModelName: viewModel.selectedFilter?.attributeName ?? "", filterModelCode: viewModel.selectedFilter?.attributeCode ?? "", filterModelId: viewModel.selectedFilter?.attributeId ?? 0, filtervalue: viewModel.selectedFilter?.alphabeticFilterValues?[safe : indexPath.section]?.values[safe : indexPath.row] ?? FilterValue())
                        viewModel.selectedValues.append(selectedModel)
                        
                    }
                } else {
                    
                    if viewModel.selectedValues.contains(where: { value in
                        (viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueId == value.filtervalue.attributeValueId) && (viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName == value.filtervalue.attributeValueName)
                    }) {
                        
                        viewModel.selectedValues.removeAll { value in
                            (value.filtervalue.attributeValueId ==  viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueId) && (value.filtervalue.attributeValueName ==  viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row]?.attributeValueName)
                        }
                        
                        
                    } else {
                        
                        let selectedModel = SelectedFilterData(filterModelName: viewModel.selectedFilter?.attributeName ?? "", filterModelCode: viewModel.selectedFilter?.attributeCode ?? "", filterModelId: viewModel.selectedFilter?.attributeId ?? 0, filtervalue: viewModel.selectedFilter?.filteredAlphabeticFilterValues(searchString: self.textFieldSearch.text ?? "")?[safe : indexPath.section]?.values[safe : indexPath.row] ?? FilterValue())
                        viewModel.selectedValues.append(selectedModel)
                    }
                }
                
                viewModel.selectedFilters = viewModel.getSelectedFiltersFromSelectedValues()
                
                self.reloadView()
                
                viewModel.getFilters(site: self.isForPreOwned ? .secondMovement : .ethos, screenType: self.screenType)
                
            }
        }
    }
}

extension FiltersViewController : GetProductViewModelDelegate {
    func didGetProducts(site : Site?, CategoryId : Int?) {
        DispatchQueue.main.async {
            
        }
    }
    
    func errorInGettingProducts(error: String) {
        DispatchQueue.main.async {
            
        }
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            EthosLoader.shared.show(view: self.view, frame: self.view.frame)
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            EthosLoader.shared.hide()
        }
    }
    
    func startFooterIndicator() {
        DispatchQueue.main.async {
            
        }
    }
    
    func stopFooterIndicator() {
        DispatchQueue.main.async {
            
        }
    }
    
    func didGetProductDetails(details: Product) {
        DispatchQueue.main.async {
            
        }
    }
    
    func failedToGetProductDetails() {
        DispatchQueue.main.async {
            
        }
    }
    
    func didGetFilters() {
        DispatchQueue.main.async {
            self.reloadView()
        }
    }
    
    func errorInGettingFilters() {
        DispatchQueue.main.async {
            
        }
    }
    
    
}
