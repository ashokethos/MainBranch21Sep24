//
//  EthosBottomSheetTableViewController.swift
//  Ethos
//
//  Created by mac on 21/08/23.
//

import UIKit

class EthosBottomSheetTableViewController: UIViewController {
    
    @IBOutlet weak var tableViewData: EthosContentSizedTableView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var constraintHeightBtnDone: NSLayoutConstraint!
    
    var delegate : SuperViewDelegate?
    var key : BottomSheetKey = .forSortBy
    var superController : UIViewController?
    var forMultipleSelection = false
    var data = [String]()
    var selectedItem : String? = nil
    var selectedItems = [String]()
    var selectedTabIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewData.registerCell(className: HeadingCell.self)
        self.viewMain.layer.masksToBounds = true
        self.viewMain.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.viewMain.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnDone.isHidden = !self.forMultipleSelection
        constraintHeightBtnDone.constant = forMultipleSelection ? 50 : 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: true) {
            if self.superController is RequestACallBackFormViewController || self.superController is ScheduleAPickupViewController {
                if self.selectedTabIndex != self.superController?.presentingViewController?.tabBarController?.selectedIndex {
                    self.superController?.dismiss(animated: true)
                }
            }
        }
    }
    
    
    @IBAction func btnDoneDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.reloadCollectionView, EthosKeys.value : self.selectedItems , EthosKeys.type : self.key])
        }
    }
    
    @IBAction func btnTransParentBackGroundDidTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension EthosBottomSheetTableViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
            if forMultipleSelection == false {
                
                if key != .forPhoneNumber {
                    if selectedItem == data[safe : indexPath.row] {
                        cell.setHeading(title: data[safe : indexPath.row] ?? "" ,  image: UIImage.imageWithName(name: EthosConstants.tickMark), imageHeight: 16, spacingTitleImage: 20, showUnderLine: true, underlineColor: EthosColor.lightGrey)
                    } else {
                        cell.setHeading(title: data[safe : indexPath.row] ?? "" ,  image: UIImage.imageWithName(name: EthosConstants.checkboxUnselected), imageHeight: 16, spacingTitleImage: 20, showUnderLine: true, underlineColor: EthosColor.lightGrey)
                    }
                } else {
                    cell.setHeading(title: data[safe : indexPath.row] ?? "" ,  image: UIImage.imageWithName(name: "Call icon"), imageHeight: 30, spacingTitleImage: 20, showUnderLine: true, underlineColor: .clear)
                }
            } else {
                if selectedItems.contains(where: { item in
                    item == data[safe : indexPath.row]
                }) {
                    cell.setHeading(title: data[safe : indexPath.row] ?? "" ,  image: UIImage.imageWithName(name: EthosConstants.tickMark), imageHeight: 16, spacingTitleImage: 20, showUnderLine: true, underlineColor: EthosColor.lightGrey)
                } else {
                    cell.setHeading(title: data[safe : indexPath.row] ?? "" ,  image: UIImage.imageWithName(name: EthosConstants.checkboxUnselected), imageHeight: 16, spacingTitleImage: 20, showUnderLine: true, underlineColor: EthosColor.lightGrey)
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if forMultipleSelection == false {
            self.dismiss(animated: true) {
                self.selectedItem = self.data[safe : indexPath.row]
                self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.reloadCollectionView, EthosKeys.value : self.selectedItem ?? "", EthosKeys.type : self.key])
            }
        } else {
            if self.selectedItems.contains(where: { item in
                item == data[safe : indexPath.row]
            }) {
                if let index = selectedItems.firstIndex(where: { item in
                    item == data[safe : indexPath.row]
                }) {
                    selectedItems.remove(at: index)
                }
            } else {
                if let itemToAppend = data[safe : indexPath.row] {
                    selectedItems.append(itemToAppend)
                }
               
            }
            self.tableViewData.reloadData()
        }
    }
}
