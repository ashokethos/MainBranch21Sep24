//
//  EthosBoutiqueDescriptionViewController.swift
//  Ethos
//
//  Created by mac on 23/02/24.
//

import UIKit
import Mixpanel

class EthosBoutiqueDescriptionViewController: UIViewController {

    @IBOutlet weak var tableViewBoutiqueDescription: UITableView?
    @IBOutlet weak var btnSearch: UIButton?
    @IBOutlet weak var btnBack: UIButton?
    
    var forSpecialBoutique = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewBoutiqueDescription?.registerCell(className: BoutiqueImagesTableViewCell.self)
        self.addTapGestureToDissmissKeyBoard()
    }
    
    var store : Store? {
        didSet {
            DispatchQueue.main.async {
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.BoutiqueClicked , properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.BoutiqueCode : self.store?.storeCode,
                    EthosConstants.BoutiqueName : self.store?.storeName
                ])
                self.tableViewBoutiqueDescription?.reloadData()
            }
        }
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension EthosBoutiqueDescriptionViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BoutiqueImagesTableViewCell.self)) as? BoutiqueImagesTableViewCell {
            cell.forSpecialBoutique = self.forSpecialBoutique
            cell.store = self.store
            cell.superTableView = self.tableViewBoutiqueDescription
            cell.delegate = self
            cell.collectionViewImages.reloadData()
            cell.superViewController = self
            return cell
        }
        return UITableViewCell()
    }
    
    
}

extension EthosBoutiqueDescriptionViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys {
            if key == .showAlert, let title = info?[EthosKeys.alerTitle] as? String, let message = info?[EthosKeys.alertMessage] as? String {
                self.showAlertWithSingleTitle(title: title, message: message)
            }
        }
    }
}

