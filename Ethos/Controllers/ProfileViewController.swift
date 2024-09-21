//
//  ProfileViewController.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import PhotosUI
import Mixpanel

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var tableViewProfile: UITableView!
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var btnShowProfile: UIButton!
    @IBOutlet weak var profileIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var lblNumberOfNotifications: UILabel!
    
    var points = 0
    
    var viewModel = GetCustomerViewModel()
    
    let refreshControl = UIRefreshControl()
    
    var articleCount = 0 {
        didSet {
            self.tableViewProfile.reloadData()
        }
    }
    var productCount = 0 {
        didSet {
            self.tableViewProfile.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateNotificationCount()
        DispatchQueue.main.async {
            self.updateWishlistCount()
            DispatchQueue.main.async {
                self.savedArticleArticlesCount()
            }
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if Userpreference.token == nil {
            self.btnShowProfile.setAttributedTitleWithProperties(title: EthosConstants.SignIn.uppercased(), font: EthosFont.Brother1816Regular(size: 10), alignment: .center, foregroundColor: .black, kern: 0.5)
            self.lblProfileName.text = EthosConstants.Guest
        } else {
            self.btnShowProfile.setAttributedTitleWithProperties(title: "SHOW PROFILE", font: EthosFont.Brother1816Regular(size: 10), alignment: .center, foregroundColor: .black, kern: 0.5)
            self.viewModel.getCustomerDetails()
        }
    }
    
    func setup() {
        self.addTapGestureToDissmissKeyBoard()
        tableViewProfile.registerCell(className: HeadingCell.self)
        self.imageViewProfile.setBorder(borderWidth: 0.5, borderColor: EthosColor.appBGColor, radius: 35)
        self.viewModel.delegate = self
        self.lblNumberOfNotifications.setBorder(borderWidth: 0, borderColor: .clear, radius: 7.5)
        
        NotificationCenter.default.addObserver(forName:  NSNotification.Name("receivedNotification"), object: nil, queue: nil) { notification in
            self.updateNotificationCount()
        }
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.tableViewProfile.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        if Userpreference.token != nil {
            self.viewModel.getCustomerDetails()
        } else {
            self.tableViewProfile.refreshControl?.endRefreshing()
        }
        
    }
    
    func updateNotificationCount() {
        DataBaseModel().fetchNotifications { notifications in
            
            let unreadMessages = notifications.filter { notification in
                notification.isRead == false
            }
            
            self.lblNumberOfNotifications.isHidden = (unreadMessages.count == 0)
            self.lblNumberOfNotifications.text = String(unreadMessages.count)
        }
    }
    
    func updateWishlistCount() {
        DataBaseModel().fetchProducts { products in
            self.productCount = products.count
        }
    }
    
    func savedArticleArticlesCount() {
        DataBaseModel().fetchArticles { articles in
            self.articleCount = articles.count
        }
    }
    
    @IBAction func btnShowProfileDidTapped(_ sender: UIButton) {
        if Userpreference.token != nil {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ProfileDetailViewController.self)) as? ProfileDetailViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let loginvc = (UIStoryboard(name: StoryBoard.login.rawValue, bundle: nil)).instantiateViewController(withIdentifier: String(describing: LoginWithMobileViewController.self)) as? LoginWithMobileViewController {
                self.navigationController?.pushViewController(loginvc, animated: true)
            }
        }
    }
    
    @IBAction func btnProfilePicDidTapped(_ sender: UIButton) {
        if Userpreference.token != nil {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: true)
        }
    }
    
    @IBAction func btnNotificationDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: NotificationsViewController.self)) as? NotificationsViewController {
            
            let properties : Dictionary<String, any MixpanelType> = [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.Screen : EthosConstants.Profile
            ]
            
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.NotificationsClicked , properties: properties)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ProfileViewController : GetCustomerViewModelDelegate {
    func userDeleteSuccess() {
        Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.AccountDeleted, properties: [
            EthosConstants.Email : Userpreference.email,
            EthosConstants.UID : Userpreference.userID,
            EthosConstants.Gender : Userpreference.gender,
            EthosConstants.Platform : EthosConstants.IOS,
            EthosConstants.Registered : Userpreference.token == nil || Userpreference.token == "" ? EthosConstants.N : EthosConstants.Y,
        ])
        DispatchQueue.main.async {
            self.backToRoot()
        }
    }
    
    func userDeleteFailed(error: String) {
        DispatchQueue.main.async {
            self.showAlertWithSingleTitle(title: error, message: "")
        }
    }
    
    func didGetCustomerPoints(points: Int) {
        DispatchQueue.main.async {
            self.points = points
            self.tableViewProfile.reloadData()
        }
    }
    
    func updateProfileSuccess(message: String) {
        
    }
    
    func updateProfileFailed(message: String) {
        
    }
    
    func startProfileIndicator() {
        DispatchQueue.main.async {
            if self.tableViewProfile.refreshControl?.isRefreshing != true {
                self.profileIndicator.startAnimating()
            }
        }
    }
    
    func stopProfileIndicator() {
        DispatchQueue.main.async {
            self.profileIndicator.stopAnimating()
            self.tableViewProfile.refreshControl?.endRefreshing()
        }
    }
    
    func unAuthorizedToken(message: String) {
        print(message)
    }
    
    func didGetCustomerData(data: Customer) {
        DispatchQueue.main.async {
            self.addRefreshControl()
            self.lblProfileName.text = (data.firstname ?? "") + " " + (data.lastname ?? "")
            if let image = data.extraAttributes?.profileImage {
                UIImage.loadFromURL(url: image) { image in
                    self.imageViewProfile.image = image
                }
            }
            
            self.viewModel.getCustomersPointBalance()
        }
    }
    
    func backToRoot() {
        Userpreference.resetValues()
        self.tableViewProfile.reloadData()
        self.lblProfileName.text = EthosConstants.Guest
        self.btnShowProfile.setAttributedTitleWithProperties(title: EthosConstants.SignIn.uppercased(), font: EthosFont.Brother1816Regular(size: 10), alignment: .center, foregroundColor: .black, kern: 0.5)
        self.imageViewProfile.image = UIImage.imageWithName(name: EthosConstants.placeHolderUser)
        self.tabBarController?.selectedIndex = 0
        let nc = UIApplication.topViewController()?.navigationController
        for controller in nc?.viewControllers ?? [] {
            if controller is LatestViewController {
                nc?.popToViewController(controller, animated: true)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            (UIApplication.topViewController() as? LatestViewController)?.tableViewHome.contentOffset = .zero
            (UIApplication.topViewController() as? LatestViewController)?.lblUserName.text = EthosConstants.Guest
        }
    }
}

extension ProfileViewController : UITableViewDataSource, UITableViewDelegate {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2, 8 : return Userpreference.token != nil ? 1 : 0
        case 7 : return (Userpreference.shouldShowDeleteAccount == true && Userpreference.token != nil) ? 1 : 0
        default : return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        switch indexPath.section {
        case 0 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.MyClubEchoPoints,
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(),
                    disclosureTitleDefault: "\(self.points) Points",
                    disclosureHeight: 40,
                    disclosureWidth:  150,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
            
            
        case 1 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.SavedArticles + " (\(self.articleCount))",
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
        case 2 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.PurchaseHistory,
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
            
            
        case 3 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.MyWishList + " (\(self.productCount))",
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
            
        case 4 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.HelpCentre,
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
        case 5 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.ContactUs,
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
        case 6 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.ShareThisApp,
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
        case 7 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.DeleteYourAccount,
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
            
        case 8 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.LogOut,
                    font: EthosFont.Brother1816Regular(size: 12),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.rightArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.seperatorColor,
                    topSpacing: 30,
                    bottomSpacing: 30
                )
                return cell
            }
            
        default: break
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
            switch indexPath.section {
                
            case 0 : break
                
            case 1 :
                if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosProfileTableViewController.self)) as? EthosProfileTableViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case 2 :
                if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchaseHistoryViewController.self)) as? PurchaseHistoryViewController {
                    
                    Mixpanel.mainInstance().track(event: "Puchase History", properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS
                    ])
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case 3 :  if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosProfileCollectionViewController.self)) as? EthosProfileCollectionViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
                
            case 4 : if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HelpAndSupportViewController.self)) as? HelpAndSupportViewController {
                
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.HelpCenterClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS
                ])
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
                
            case 5 :
                if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: ContactUsViewController.self)) as? ContactUsViewController {
                    Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ContactUsClicked, properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS
                    ])
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case 6 :
                let activityViewController = UIActivityViewController(activityItems: [EthosIdentifiers.appLink], applicationActivities: nil)
                activityViewController.completionWithItemsHandler = {
                    type, complete, res, error in
                    if complete {
                        Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ShareThisAppClicked, properties: [
                            EthosConstants.Email : Userpreference.email,
                            EthosConstants.UID : Userpreference.userID,
                            EthosConstants.Gender : Userpreference.gender,
                            EthosConstants.Platform : EthosConstants.IOS,
                            EthosConstants.Registered : Userpreference.token == nil || Userpreference.token == "" ? EthosConstants.N : EthosConstants.Y,
                            EthosConstants.SharedVia : type?.rawValue
                        ]
                        )
                    }
                }
                self.present(activityViewController, animated: true, completion: nil)
                
            case 7 :
                if let alertController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                    
                    Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.DeleteYourAccountClicked, properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.Registered : Userpreference.token == nil || Userpreference.token == "" ? EthosConstants.N : EthosConstants.Y,
                    ])
                    
                    alertController.setActions(title: EthosConstants.deleteAccountAlertTitle, message: EthosConstants.deleteAccountAlertMessage, firstActionTitle: EthosConstants.Cancel.uppercased(), secondActionTitle: EthosConstants.Confirm.uppercased(), secondAction:  {
                        self.viewModel.deleteAccount()
                    })
                    self.present(alertController, animated: true)
                }
                
            case 8 :
                if let alertController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: EthosAlertController.self)) as? EthosAlertController {
                    alertController.setActions(title: EthosConstants.logoutAlertTitle, message: "", firstActionTitle: EthosConstants.Cancel.uppercased(), secondActionTitle: EthosConstants.Confirm.uppercased(), secondAction:  {
                        Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.UserLoggedOut, properties: [
                            EthosConstants.Email : Userpreference.email,
                            EthosConstants.UID : Userpreference.userID,
                            EthosConstants.Gender : Userpreference.gender,
                            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                            EthosConstants.Platform : EthosConstants.IOS
                        ])
                        self.backToRoot()
                    })
                    self.present(alertController, animated: true)
                }
                
            default: break
                
            }
      
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                
                let imgData = NSData(data: image.jpegData(compressionQuality: 1) ?? Data())
                let imageSize: Int = imgData.count
                let imageSizeinKB = imageSize/1024
                guard imageSizeinKB < 2042 else {
                    self.showAlertWithSingleTitle(title: EthosConstants.ToobigImage, message: "", actionTitle: EthosConstants.Ok.uppercased())
                    return
                }
                
                self.viewModel.updateProfileImage(images: [image]) { image in
                    DispatchQueue.main.async {
                        self.imageViewProfile.image = image
                    }
                }
            }
        }
    }
}
