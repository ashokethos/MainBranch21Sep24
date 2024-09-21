//
//  RepairAndServiceViewController.swift
//  Ethos
//
//  Created by mac on 14/08/23.
//

import UIKit
import Mixpanel

class RepairAndServiceViewController: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableViewRepairAndService: UITableView!
    @IBOutlet weak var btnSearch: UIButton!
    
    var isForPreOwned = false
    
    var ArrWhatWeDo : [TitleDescriptionImageModel]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        load()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func load() {
        ArrWhatWeDo.append(TitleDescriptionImageModel(title: EthosConstants.MovementOverhaul, description: EthosConstants.movementOverhaulDescription, image: EthosConstants.movementOverHaul))
        
        ArrWhatWeDo.append(TitleDescriptionImageModel(title: EthosConstants.UltrasonicCleaning, description: EthosConstants.ultrasonicCleaningDescription, image: EthosConstants.ultraSonicCleaning))
        
        ArrWhatWeDo.append(TitleDescriptionImageModel(title: EthosConstants.Polishing, description: EthosConstants.polishingDescription, image: EthosConstants.polishing))
        
        ArrWhatWeDo.append(TitleDescriptionImageModel(title: EthosConstants.PerformanceTest, description: EthosConstants.performanceTestDescription, image: EthosConstants.performanceTest))
        
        ArrWhatWeDo.append(TitleDescriptionImageModel(title: EthosConstants.ReplacementOfParts, description: EthosConstants.replacementOfPartsDescription, image: EthosConstants.replacementOfParts))
        
        tableViewRepairAndService.reloadData()
    }
    
    func setup() {
        self.tableViewRepairAndService.registerCell(className: RepairAndServiceCell.self)
        self.tableViewRepairAndService.registerCell(className: AboutCollectionTableViewCell.self)
        self.tableViewRepairAndService.registerCell(className: RepairAndServiceContactsCell.self)
        self.tableViewRepairAndService.registerCell(className: SpacingTableViewCell.self)
        self.tableViewRepairAndService.registerCell(className: RepairAndServiceNew.self)
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwned
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension RepairAndServiceViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 2 : return ArrWhatWeDo.count
        default: return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceCell.self)) as? RepairAndServiceCell
            cell?.key = .forWhatWeDo
            cell?.delegate = self
            return cell
        default : return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceNew.self)) as? RepairAndServiceNew {
                cell.key = .forDetails
                cell.delegate = self
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceCell.self)) as? RepairAndServiceCell {
                cell.key = .forWhoWeAre
                cell.delegate = self
                
                return cell
            }
            
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AboutCollectionTableViewCell.self)) as? AboutCollectionTableViewCell {
                cell.index = indexPath.row + 1
                cell.key = .forRepairAndService
                cell.data = ArrWhatWeDo[safe : indexPath.row]
                return cell
            }
            
        case 3 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
            cell.setSpacing()
            return cell
        }
         
        case 4:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceCell.self)) as? RepairAndServiceCell {
                cell.key = .forFromTheWatchGuide
                return cell
            }
            
        case 5 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
            cell.setSpacing()
            return cell
        }
            
        case 6:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceCell.self)) as? RepairAndServiceCell {
                cell.key = .forReapirAndServiceLocateUs
                cell.delegate = self
                return cell
            }
            
        case 7:
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RepairAndServiceContactsCell.self)) as? RepairAndServiceContactsCell {
                cell.delegate = self
                return cell
            }
       
            
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    
}

extension RepairAndServiceViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let value = info?[EthosKeys.key] as? EthosKeys,
           value == EthosKeys.route {
            if let id = info?[EthosKeys.value] as? String,
               let vc = self.storyboard?.instantiateViewController(withIdentifier: id) {
                
                if vc is EthosTableViewController {
                    (vc as? EthosTableViewController)?.key = .glossary
                }
                
                if vc is EthosStoreViewController {
                    if self.isForPreOwned == true {
                        self.navigationController?.popViewController(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            if let topController = UIApplication.topViewController() as? PreOwnedViewController {
                                topController.selectedIndex = 3
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                    topController.tableViewStory.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                                }
                            }
                        }
                        return
                    }
                }
                
                if vc is HelpAndSupportViewController {
                    (vc as? HelpAndSupportViewController)?.isForPreOwned = self.isForPreOwned
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if info?[EthosKeys.key] as? EthosKeys == EthosKeys.routeToArticleDetail,
           let  articleId = info?[EthosKeys.value] as? Int,
           let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
            vc.articleId = articleId
            if let forSecondMovement = info?[EthosKeys.forSecondMovement] as? Bool {
                vc.isForPreOwned = forSecondMovement
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        if let value = info?[EthosKeys.key] as? EthosKeys, value == .requestACallBack {
            if  let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: RequestACallBackFormViewController.self)) as? RequestACallBackFormViewController {
                vc.isforPreOwned = self.isForPreOwned
                vc.selectedTabIndex = self.tabBarController?.selectedIndex
                vc.screenLocation = "Repair-Service"
                Mixpanel.mainInstance().trackWithLogs(event: "Repair Call Back Clicked", properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    "Screen Location" : "Request A CallBack"
                ])
                self.present(vc, animated: true)
            }
        }
        
        if let value = info?[EthosKeys.key] as? EthosKeys, value == .scheduleAPickup {
            if  let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ScheduleAPickupViewController.self)) as? ScheduleAPickupViewController {
                vc.isforPreOwned = self.isForPreOwned
                vc.selectedTabIndex = self.tabBarController?.selectedIndex
                self.present(vc, animated: true)
            }
        }
    }
}
