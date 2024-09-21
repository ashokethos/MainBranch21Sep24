//
//  EthosStoreViewController.swift
//  Ethos
//
//  Created by mac on 09/08/23.
//

import UIKit
import Mixpanel
import SkeletonView

class EthosStoreViewController: UIViewController {
    
    @IBOutlet weak var tableViewStores: UITableView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var loadingStores = true {
        didSet {
            DispatchQueue.main.async {
                self.tableViewStores.reloadData()
            }
        }
    }
    
    var loadingNewStores = true {
        didSet {
            DispatchQueue.main.async {
                if self.tableViewStores?.numberOfSections ?? 0 > 1 {
                    self.tableViewStores.reloadSections([1], with: .automatic)
                }
            }
        }
    }
    
    var isForPreOwn = false
    
    var searchKeyWords = ""
    
    var storeCount : Int {
        return self.searchKeyWords == "" ? self.viewModel.cities.count : self.viewModel.filteredCities(filteredString: searchKeyWords).count
    }
    
    var viewModel = GetStoreViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.callApi()
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        self.tableViewStores.registerCell(className: HorizontalCollectionTableViewCell.self)
        self.tableViewStores.registerCell(className: EthosStoreTableViewCell.self)
        self.tableViewStores.registerCell(className: SectionHeaderCell.self)
        self.tableViewStores.registerCell(className: TitleTableViewCell.self)
        self.tableViewStores.registerCell(className: FindAStoreTableViewCell.self)
        self.tableViewStores.registerCell(className: SpacingTableViewCell.self)
        self.viewModel.delegate = self
    }
    
    func callApi() {
        viewModel.getStores(site: self.isForPreOwn ? .secondMovement : .ethos)
        viewModel.getNewBoutiques(site: self.isForPreOwn ? .secondMovement : .ethos)
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwn
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension EthosStoreViewController : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.loadingStores {
            return 3
        } else {
            return (self.storeCount > 0) ? (self.storeCount + 2) : 3
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1 : return 1
        default :
            if self.loadingStores {
                return 3
            } else {
                if self.storeCount > 0 {
                    return searchKeyWords == "" ? viewModel.cities[section-2].stores.count : viewModel.filteredCities(filteredString: searchKeyWords)[section-2].stores.count
                } else {
                    return 1
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.loadingStores {
            switch indexPath.section {
            case 0, 1 : break
            default :
                if self.storeCount > 0 {
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosBoutiqueDescriptionViewController.self)) as? EthosBoutiqueDescriptionViewController {
                        
                        vc.store = (searchKeyWords == "") ? (viewModel.cities[indexPath.section-2].stores[safe : indexPath.row]) : (viewModel.filteredCities(filteredString: searchKeyWords)[indexPath.section-2].stores[safe : indexPath.row])
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0,1 : return nil
        default :
            if self.loadingStores {
                return nil
            } else {
                if self.storeCount > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SectionHeaderCell.self)) as? SectionHeaderCell {
                        cell.contentView.hideSkeleton()
                        cell.setTitle(title: (searchKeyWords == "") ? (viewModel.cities[section - 2].name?.uppercased() ?? "") : (viewModel.filteredCities(filteredString: searchKeyWords)[section - 2].name?.uppercased() ?? ""))
                        return cell
                    }
                }
            }
            
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.loadingStores {
            return nil
        } else {
            let indx = self.storeCount > 0 ? self.storeCount + 1 : 2
            switch section {
            case 0, 1, indx : return nil
            default :
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
                    cell.setSpacing()
                    return cell
                }
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.loadingStores == false && self.storeCount == 0 && indexPath.section == 2 {
            return 80
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.loadingStores {
            return 0
        } else {
            if self.storeCount > 0 {
                switch section {
                case 0, 1 :
                    return 0
                case self.storeCount + 1 :
                    return 0
                default :
                    return UITableView.automaticDimension
                }
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FindAStoreTableViewCell.self)) as? FindAStoreTableViewCell {
                cell.delegate = self
                cell.textFieldSearch.text = self.searchKeyWords
                cell.btnSearch.addTarget(self, action: #selector(self.btnStoreSearchDidTapped), for: .touchUpInside)
                return cell
            }
            
        case 1 :
            if self.loadingNewStores {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self)) as? HorizontalCollectionTableViewCell {
                    cell.setTitle(title: EthosConstants.ExploreNewBoutiques.uppercased())
                    cell.forSecondMovement = self.isForPreOwn
                    cell.key = .forStore
                    cell.viewBtnViewAll.isHidden = true
                    cell.contentView.backgroundColor = EthosColor.appBGColor
                    
                    cell.contentView.showAnimatedGradientSkeleton()
                    cell.collectionView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HorizontalCollectionTableViewCell.self)) as? HorizontalCollectionTableViewCell {
                    cell.hideSkeleton()
                    cell.collectionView.hideSkeleton()
                    cell.setTitle(title: EthosConstants.ExploreNewBoutiques.uppercased())
                    cell.forSecondMovement = self.isForPreOwn
                    cell.key = .forStore
                    cell.storeViewModel.newStores = self.viewModel.newStores
                    cell.viewBtnViewAll.isHidden = true
                    cell.contentView.backgroundColor = EthosColor.appBGColor
                    cell.delegate = self
                    cell.didGetNewStores(stores: self.viewModel.newStores)
                    return cell
                }
            }
            
            
        default :
            if self.loadingStores {
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoreTableViewCell.self)) as? EthosStoreTableViewCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            } else {
                if self.storeCount > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EthosStoreTableViewCell.self)) as? EthosStoreTableViewCell {
                        cell.contentView.hideSkeleton()
                        
                        cell.store = searchKeyWords == "" ? viewModel.cities[indexPath.section-2].stores[safe : indexPath.row] : viewModel.filteredCities(filteredString: searchKeyWords)[indexPath.section-2].stores[safe : indexPath.row]
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TitleTableViewCell.self)) as? TitleTableViewCell {
                        cell.titleLabel.setAttributedTitleWithProperties(title: "Sorry, No results were found".uppercased(), font: EthosFont.Brother1816Medium(size: 14))
                        cell.titleLabel.textAlignment = .center
                        return cell
                    }
                }
            }
            
        }
        return  UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0
        } else {
            if self.loadingStores {
                return 0
            } else {
                if self.storeCount > 0 {
                    return UITableView.automaticDimension
                } else {
                    return 0
                }
            }
            
        }
    }
    
    @objc func btnStoreSearchDidTapped() {
        self.view.endEditing(true)
    }
}

extension EthosStoreViewController : GetStoresViewModelDelegate {
    func didGetNewStores(stores: [Store]) {
        self.loadingNewStores = false
    }
    
    func didFailedToGetStores() {
        self.loadingStores = false
    }
    
    func didFailedToGetNewStores() {
        self.loadingNewStores = false
    }
    
    
    func startIndicator() {
        
    }
    
    func stopIndicator() {
        
    }
    
    func didGetStores(stores: [StoreCity], forLatest: Bool) {
        self.loadingStores = false
    }
}

extension EthosStoreViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys {
            if key == .search,
               let str =  info?[EthosKeys.value] as? String {
                self.searchKeyWords = str
                self.view.endEditing(true)
                DispatchQueue.main.async {
                    self.tableViewStores.reloadData()
                    DispatchQueue.main.async {
                        if self.searchKeyWords != "" {
                            self.tableViewStores.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
                        }
                    }
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
        }
    }
}
