//
//  NotificationsViewController.swift
//  Ethos
//
//  Created by mac on 20/09/23.
//

import UIKit
import SafariServices
import Mixpanel

class NotificationsViewController: UIViewController {

    @IBOutlet weak var collectionViewTabs: UICollectionView!
    @IBOutlet weak var btnCross: UIButton!
    @IBOutlet weak var tableViewNotifications: UITableView!
    @IBOutlet weak var lblNoData: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var imgTitle: UIImageView!
    var isForPreOwned = false
    var selectedIndex = 0
    var Arrtabs = ["Notifications"]
    var ArrMessages = [String]()
    var ArrNotifications = [NotificationDBModel]()
    var userActivtyViewModel = UserActivityViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewNotifications.registerCell(className: NotificationTableViewCell.self)
        self.collectionViewTabs.registerCell(className: DiscoveryTabsCell.self)
        self.fetchNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imgTitle.image = UIImage.imageWithName(name: self.isForPreOwned ? EthosConstants.apptitle2 : EthosConstants.apptitle)
    }
    
    @IBAction func btnCrossDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwned
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchNotifications() {
        DataBaseModel().fetchNotifications { notifications in
            self.ArrNotifications = notifications
            tableViewNotifications.reloadData()
            DataBaseModel().readNotifications {
                reloadView()
            }
        }
    }
    
    func  reloadView() {
        collectionViewTabs.reloadData()
        tableViewNotifications.reloadData()
        
        if self.selectedIndex == 0 {
            self.lblNoData.text = "No Notifications"
            self.lblNoData.isHidden = !self.ArrNotifications.isEmpty
        } else {
            self.lblNoData.text = "No Messages"
            self.lblNoData.isHidden = !self.ArrMessages.isEmpty
        }
    }
    
}

extension NotificationsViewController : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedIndex == 0 {
            return ArrNotifications.count
        } else {
            return ArrMessages.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if selectedIndex == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NotificationTableViewCell.self), for: indexPath) as? NotificationTableViewCell {
                cell.delegate = self
                cell.notification = ArrNotifications[safe : indexPath.row]
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndex == 0 {
            
            if let url = self.ArrNotifications[safe : indexPath.row]?.link {
                userActivtyViewModel.getDataFromActivityUrl(url: url)
            }
            
        }
    }
    
}

extension NotificationsViewController : UICollectionViewDataSource , UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Arrtabs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DiscoveryTabsCell.self), for: indexPath) as? DiscoveryTabsCell {
            cell.lblTitle.text = Arrtabs[indexPath.item]
            if indexPath.item == selectedIndex {
                cell.viewIndicator.backgroundColor = .black
            } else {
                cell.viewIndicator.backgroundColor = .clear
            }
            
        
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
    
}

extension NotificationsViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if info?[EthosKeys.key] as? EthosKeys == .reloadTableView {
            fetchNotifications()
        }
        
        if info?[EthosKeys.key] as? EthosKeys == .openWebPage , let strUrl = info?[EthosKeys.url] as? String {
            UserActivityViewModel().getDataFromActivityUrl(url: strUrl)
        }
    }
}

extension NotificationsViewController {
    
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
    
    
}
