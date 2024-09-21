//
//  EthosTableViewController.swift
//  Ethos
//
//  Created by SoftGrid on 24/07/23.
//

import UIKit
import SafariServices
import Mixpanel
import SkeletonView

class EthosTableViewController: UIViewController {
    
    @IBOutlet weak var collectionViewAlphabets: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var constraintTrailingTableView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightCollectionView: NSLayoutConstraint!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var btnSearchCountries: UIButton!
    @IBOutlet weak var textFieldSearch: EthosTextField!
    
    @IBOutlet weak var viewSearch: UIView!
    
    @IBOutlet weak var constraintHeightViewSearch: NSLayoutConstraint!
    
    var key : EthosTableKey = .glossary
    var viewModel = GetGlossaryViewModel()
    var delegate : SuperViewDelegate?
    var countryViewModel = CountryViewModel()
    var scrollingAfterSelection = false
    var isForPreOwned = false
    var searchStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textFieldSearch.initWithUIParameters(placeHolderText: "Search Countries by Name, Code and Dial code")
    }
    
    func setup() {
        self.collectionViewAlphabets.registerCell(className: DiscoveryTabsCell.self)
        self.tableView
            .registerCell(className: GlossaryDescriptionCell.self)
        self.tableView
            .registerCell(className: HeadingCell.self)
        
        self.tableView.isSkeletonable = true
        self.collectionViewAlphabets.isSkeletonable = true
        
        
        self.lblNoData.setAttributedTitleWithProperties(title: "Sorry, No results were found\n\n\n\n\n\n\n".uppercased(), font: EthosFont.Brother1816Medium(size: 14), alignment: .center, kern: 0.5)
        self.textFieldSearch.delegate = self
        
        
        
        switch key {
        case .country :
            self.btnBack.setImage(UIImage(named: EthosConstants.cross), for: .normal)
            self.countryViewModel.loadCountries()
            self.constraintHeightCollectionView.constant = 0
            self.constraintHeightViewSearch.constant = 80
            self.viewSearch.isHidden = false
            self.btnSearch.isHidden = true
        case .glossary :
            viewModel.delegate = self
            viewModel.getGlossaryData(site: isForPreOwned ? .secondMovement : .ethos)
            self.constraintHeightCollectionView.constant = 50
            self.constraintHeightViewSearch.constant = 0
            self.viewSearch.isHidden = true
        }
        reloadView()
    }
    
    func reloadView() {
        self.lblNoData.isHidden = self.countryViewModel.filteredCountries(str: self.searchStr).count > 0 || self.key == .glossary
    }
    
    @IBAction func textFieldDidChangeValue(_ sender: EthosTextField) {
        self.searchStr = textFieldSearch.text ?? ""
        self.tableView.reloadData()
        self.reloadView()
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwned
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func btnSearchCountriesDidTapped(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        switch self.key {
        case .glossary:
            self.navigationController?.popViewController(animated: true)
        case .country:
            self.dismiss(animated: true)
        }
    }
}

extension EthosTableViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch self.key {
        case .glossary:
            return viewModel.glossary.count
        case .country:
            return 1
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.key {
        case .glossary:
            return viewModel.glossary[section].data.count
        case .country:
            return countryViewModel.filteredCountries(str: self.searchStr).count
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !self.tableView.sk.isSkeletonActive {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                cell.hideSkeleton()
                switch self.key {
                case .glossary:
                    cell.setHeading(title: viewModel.glossary[section].header.uppercased())
                case .country:
                    cell.setHeading(title: EthosConstants.SelectCountry, font: EthosFont.Brother1816Medium(size: 20))
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                cell.setHeading(title: "  ", leading: 30, trailling: 30, showDisclosure: false, showTopLine: false, showBulletLine: false)
                cell.contentView.showAnimatedGradientSkeleton()
                return cell
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.key {
        case .glossary:
            return UITableView.automaticDimension
        case .country:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.key {
        case .glossary:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GlossaryDescriptionCell.self), for: indexPath) as! GlossaryDescriptionCell
            cell.hideSkeleton()
            cell.lblTitle.font = EthosFont.Brother1816Medium(size: 12)
            cell.lblDescription.font = EthosFont.Brother1816Regular(size: 12)
            cell.lblTitle.textColor = EthosColor.barTintColor
            cell.lblDescription.textColor = EthosColor.darkGrey
            let arrData = viewModel.glossary[safe : indexPath.section]?.data
            cell.element = arrData?[safe : indexPath.row]
            cell.selectionStyle = .none
            return cell
        case .country:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                let country = countryViewModel.filteredCountries(str: self.searchStr)[safe : indexPath.row]
                cell.setHeading(title: (country?.dialCode ?? "") + " " + (country?.name ?? ""),
                                font: EthosFont.Brother1816Regular(size: 16),
                                numberOfLines: 0,
                                image: UIImage(named: country?.code ?? ""),
                                imageHeight: 30,
                                spacingTitleImage: 20,
                                disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                                AspectRationConstant: 10)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.key {
        case .glossary:
            return UITableView.automaticDimension
        case .country:
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.key {
        case .glossary:
            
            self.viewModel.glossary[safe : indexPath.section]?.data[safe : indexPath.row]?.isExpanded = !(self.viewModel.glossary[safe : indexPath.section]?.data[safe : indexPath.row]?.isExpanded ?? false)
            
            tableView.reloadData()
            
        case .country:
            self.dismiss(animated: true) {
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.updateView, EthosKeys.value : self.countryViewModel.filteredCountries(str: self.searchStr)[safe : indexPath.row]])
            }
        }
    }
}

extension EthosTableViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.glossary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DiscoveryTabsCell.self), for: indexPath) as? DiscoveryTabsCell {
            cell.contentView.hideSkeleton()
            if viewModel.selectedIndex == indexPath.item {
                cell.viewIndicator.backgroundColor = .black
            } else {
                cell.viewIndicator.backgroundColor = .clear
            }
            
            cell.lblTitle.text = viewModel.glossary[indexPath.item].header.uppercased()
            cell.lblTitle.font = EthosFont.Brother1816Medium(size: 10)
            cell.lblTitle.textColor = .black
            cell.lblTitle.backgroundColor = .clear
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectedIndex = indexPath.row
        collectionView.reloadData()
        self.scrollingAfterSelection = true
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: indexPath.row), at: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.scrollingAfterSelection = false
        }
        
    }
}

extension EthosTableViewController : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return "DiscoveryTabsCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: DiscoveryTabsCell.self), for: indexPath) as? DiscoveryTabsCell {
            DispatchQueue.main.async {
                cell.contentView.showAnimatedGradientSkeleton()
            }
            
            return cell
        }
        return nil
    }
    
    
}

extension EthosTableViewController : SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        "GlossaryDescriptionCell"
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GlossaryDescriptionCell.self), for: indexPath) as! GlossaryDescriptionCell
        cell.lblTitle.skeletonTextNumberOfLines = 1
        cell.lblDescription.skeletonTextNumberOfLines = 2
        cell.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        cell.lblDescription.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
        cell.lblDescription.skeletonLineSpacing = 10
        cell.contentView.showAnimatedGradientSkeleton()
        return cell
    }
}


extension EthosTableViewController : GetGlossaryViewModelDelegate {
    func startIndicator() {
        
        self.tableView.showAnimatedGradientSkeleton(transition: .none)
        self.collectionViewAlphabets.showAnimatedGradientSkeleton(transition: .none)
        
    }
    
    func stopIndicator() {
        
    }
    
    func didGetGlossary() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.tableView.hideSkeleton()
            self.collectionViewAlphabets.hideSkeleton()
        }
    }
    
    
}

extension EthosTableViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if key == .glossary,
           scrollView == tableView,
           scrollingAfterSelection == false {
            if let currentIndex = tableView.indexPathForRow(at: scrollView.contentOffset) {
                viewModel.selectedIndex = currentIndex.section
                collectionViewAlphabets.reloadData()
                self.collectionViewAlphabets.scrollToItem(at: IndexPath(row: viewModel.selectedIndex, section: 0), at: .left, animated: true)
            }
        }
    }
}

extension EthosTableViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}


