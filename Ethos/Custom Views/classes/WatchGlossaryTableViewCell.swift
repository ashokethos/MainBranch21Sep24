//
//  WatchGlossaryTableViewCell.swift
//  Ethos
//
//  Created by mac on 27/06/23.
//

import UIKit

class WatchGlossaryTableViewCell: UITableViewCell {
    
   @IBOutlet weak var tableViewGlossary: UITableView!
    @IBOutlet weak var collectionViewLetters: UICollectionView!
    @IBOutlet weak var btnViewAll: UIButton!
    let viewModel = GetGlossaryViewModel()
    var delegate : SuperViewDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDelegates()
        setUI()
    }
    
    @objc func viewAllGlossaryData() {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route, EthosKeys.viewModel : viewModel])
    }
    
    func setupDelegates() {
        collectionViewLetters.registerCell(className: DiscoveryTabsCell.self)
        tableViewGlossary.registerCell(className: GlossaryDescriptionCell.self)
        tableViewGlossary.registerCell(className: HeadingCell.self)
        collectionViewLetters.dataSource = self
        collectionViewLetters.delegate = self
        tableViewGlossary.dataSource = self
        tableViewGlossary.delegate = self
        viewModel.delegate = self
    }
    
    func setUI() {
        btnViewAll.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        btnViewAll.addTarget(self, action: #selector(viewAllGlossaryData), for: .touchUpInside)
    }
}

extension WatchGlossaryTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.glossary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DiscoveryTabsCell.self), for: indexPath) as? DiscoveryTabsCell {
            
            if viewModel.selectedIndex == indexPath.item {
                cell.viewIndicator.backgroundColor = .black
                cell.lblTitle.font = EthosFont.Brother1816Bold(size: 10)
            } else {
                cell.viewIndicator.backgroundColor = .clear
                cell.lblTitle.font = EthosFont.Brother1816Regular(size: 10)
            }
            
            cell.lblTitle.text = viewModel.glossary[indexPath.item].header.uppercased()
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
        viewModel.selectedIndex = indexPath.item
        reloadView()
    }
    
    func reloadView() {
        collectionViewLetters.reloadData()
        self.tableViewGlossary.reloadData()
        self.delegate?.updateView(info: [EthosKeys.key: EthosKeys.reloadHeightOfTableView])
    }
}

extension WatchGlossaryTableViewCell : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.glossary.count > viewModel.selectedIndex {
            return viewModel.glossary[viewModel.selectedIndex].data.count
        } else {
            return 0
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GlossaryDescriptionCell.self)) as? GlossaryDescriptionCell {
            cell.element = viewModel.glossary[viewModel.selectedIndex].data[safe : indexPath.row]
            cell.constraintLeading.constant = 0
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
            if viewModel.glossary.count > viewModel.selectedIndex {
                let text = viewModel.glossary[viewModel.selectedIndex].header.uppercased()
                cell.setHeading(title: text,leading: 0,trailling: 0)
                return cell
            }
           
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.glossary[safe : viewModel.selectedIndex]?.data[safe : indexPath.row]?.isExpanded = ((self.viewModel.glossary[viewModel.selectedIndex].data[safe : indexPath.row]?.isExpanded ) == nil)
        reloadView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
}

extension WatchGlossaryTableViewCell : GetGlossaryViewModelDelegate {
    func startIndicator() {
        DispatchQueue.main.async {
            
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            
        }
    }
    
    func didGetGlossary() {
        DispatchQueue.main.async {
            self.reloadView()
        }
    }
}
