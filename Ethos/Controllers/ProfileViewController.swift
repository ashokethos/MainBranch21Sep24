//
//  ProfileViewController.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import Photos
import PhotosUI
import Mixpanel

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var tableViewProfile: UITableView!
    @IBOutlet weak var profileName: UIButton!
    @IBOutlet weak var lblWelcomeMessage: UILabel!
    @IBOutlet weak var lblNumberOfNotifications: UILabel!
    @IBOutlet weak var userLocation: UIButton!
    @IBOutlet weak var scrollViewMain: UIScrollView!
    @IBOutlet weak var viewCustomerData: UIView!
    @IBOutlet weak var viewProfilleSettings: UIView!
    @IBOutlet weak var viewOrderHistory: UIView!
    @IBOutlet weak var viewClubEchoPoints: UIView!
    @IBOutlet weak var lblOrderHistory: UILabel!
    @IBOutlet weak var lblClubEchoPoints: UILabel!
    @IBOutlet weak var lblProfileSettings: UILabel!
    @IBOutlet weak var btnDeleteYourAccount: UIButton!
    @IBOutlet weak var viewLogout: UIView!
    @IBOutlet weak var lblAppVersion: UILabel!
    @IBOutlet weak var iconLogout: UIImageView!
    @IBOutlet weak var lblLogout: UILabel!
    @IBOutlet weak var constraintSpacingLogoutDeleteAccount: NSLayoutConstraint!
    @IBOutlet weak var constrainSpacingTableViewLogout: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingDeleteAccountVersion: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightLogout: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomAppVersionStack: NSLayoutConstraint!
    
    var viewModel = GetCustomerViewModel()
    let picker = UIImagePickerController()
    let refreshControl = UIRefreshControl()
    
    var points = 0
    
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
    
    var shouldShowFollowUsIcons = true {
        didSet {
            self.tableViewProfile.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUI()
    }
    
    func setUI() {
        self.setWelcomeText()
        if Userpreference.token == nil {
            self.profileName.setAttributedTitleWithProperties(title: EthosConstants.Guest, font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), alignment: .center, foregroundColor: .black)
            self.userLocation.setAttributedTitleWithProperties(title: EthosConstants.SignIn.uppercased(), font: EthosFont.Brother1816Regular(size: 12), alignment: .center, foregroundColor: .black, kern: 0.5)
            self.viewLogout.isHidden = true
            self.btnDeleteYourAccount.isHidden = true
            self.constraintHeightLogout.constant = 0
            self.constraintBottomAppVersionStack.constant = 24
//            self.constrainSpacingTableViewLogout.constant = 0
//            self.constraintSpacingLogoutDeleteAccount.constant = 0
//            self.constraintSpacingDeleteAccountVersion.constant = 0
        } else {
            self.constraintHeightLogout.constant = 50
//            self.constrainSpacingTableViewLogout.constant = 24
//            self.constraintSpacingLogoutDeleteAccount.constant = 24
//            self.constraintSpacingDeleteAccountVersion.constant = 16
            self.btnDeleteYourAccount.isHidden = !(Userpreference.shouldShowDeleteAccount ?? true)
            if !(Userpreference.shouldShowDeleteAccount ?? true) == true{
                self.constraintBottomAppVersionStack.constant = 32
            }else{
                self.constraintBottomAppVersionStack.constant = 16
            }
            self.viewLogout.isHidden = false
            self.viewModel.getCustomerDetails()
        }
        
        if let appversion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.lblAppVersion.setAttributedTitleWithProperties(title: "version \(appversion)".uppercased(), font: EthosFont.Brother1816Regular(size: 10), alignment: .center, kern: 0.5)
        }
        
        self.updateNotificationCount()
        DispatchQueue.main.async {
            self.updateWishlistCount()
            DispatchQueue.main.async {
                self.savedArticleArticlesCount()
            }
        }
    }
    
    func setWelcomeText() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 4..<12 : self.lblWelcomeMessage.setAttributedTitleWithProperties(title: GreetingText.morning.rawValue, font: EthosFont.Brother1816Regular(size: 10), alignment: .center)
        case 12..<17 : self.lblWelcomeMessage.setAttributedTitleWithProperties(title: GreetingText.afternoon.rawValue, font: EthosFont.Brother1816Regular(size: 10), alignment: .center)
        default: self.lblWelcomeMessage.setAttributedTitleWithProperties(title: GreetingText.evening.rawValue, font: EthosFont.Brother1816Regular(size: 10), alignment: .center)
        }
    }
    
    func setup() {
        
        NotificationCenter.default.addObserver(forName:  NSNotification.Name("receivedNotification"), object: nil, queue: nil) { notification in
            self.updateNotificationCount()
        }
        
        self.addTapGestureToDissmissKeyBoard()
        self.tableViewProfile.registerCell(className: HeadingCell.self)
        self.tableViewProfile.registerCell(className: FollowUsTableViewCell.self)
        self.imageViewProfile.setBorder(borderWidth: 0.5, borderColor: EthosColor.appBGColor, radius: 30)
        self.viewModel.delegate = self
        self.lblNumberOfNotifications.setBorder(borderWidth: 0, borderColor: .clear, radius: 7.5)
        
        self.lblOrderHistory.setAttributedTitleWithProperties(title: "Order\nHistory".uppercased(), font: EthosFont.Brother1816Medium(size: 10), alignment: .center, lineHeightMultiple: 1.6, kern: 0.5)
        
        self.lblProfileSettings.setAttributedTitleWithProperties(title: "Profile\nSettings".uppercased(), font: EthosFont.Brother1816Medium(size: 10), alignment: .center, lineHeightMultiple: 1.6, kern: 0.5)
        
        
        self.lblClubEchoPoints.setAttributedTitleWithProperties (title: "Club Echo\nPoints".uppercased(), font: EthosFont.Brother1816Medium(size: 10), alignment: .center, lineHeightMultiple: 1.6, kern: 0.5)
        
        self.lblLogout.setAttributedTitleWithProperties(title: "Log Out".uppercased(), font: EthosFont.Brother1816Medium(size: 10), kern: 0.5)
        
        
        self.viewOrderHistory.addBorders(edges: [.right,.top, .bottom], color: EthosColor.appBGColor)
        self.viewClubEchoPoints.addBorders(edges: [.top, .bottom], color: EthosColor.appBGColor)
        self.viewProfilleSettings.addBorders(edges: [.left,.top, .bottom], color: EthosColor.appBGColor)
        
        self.viewLogout.addBorders(edges: .all, color: EthosColor.blackColor)
        
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

    @IBAction func deleteAccountTapped(_ sender: UIButton) {
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
    }
    
    
    @IBAction func userLocationDidTapped(_ sender: UIButton) {
        if Userpreference.token == nil {
            if let loginvc = (UIStoryboard(name: StoryBoard.login.rawValue, bundle: nil)).instantiateViewController(withIdentifier: String(describing: LoginWithMobileViewController.self)) as? LoginWithMobileViewController {
                self.navigationController?.pushViewController(loginvc, animated: true)
            }
        }
    }
    
    
    @IBAction func btnLogoutDidTapped(_ sender: Any) {
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
    }
    
    @IBAction func profileNameDidTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func orderHistoryDidTapped(_ sender: UIButton) {
        if Userpreference.token != nil {
            if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchaseHistoryViewController.self)) as? PurchaseHistoryViewController {
                
                Mixpanel.mainInstance().track(event: "Purchase History Clicked", properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.UserLocation : Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines),
                    EthosConstants.Description : "When a user clicks on the purchase history in the profile section",
                    EthosConstants.Platform : EthosConstants.IOS
                ])
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let loginvc = (UIStoryboard(name: StoryBoard.login.rawValue, bundle: nil)).instantiateViewController(withIdentifier: String(describing: LoginWithMobileViewController.self)) as? LoginWithMobileViewController {
                self.navigationController?.pushViewController(loginvc, animated: true)
            }
        }
    }
    
    @IBAction func clubEchoPointDidTapped(_ sender: UIButton) {
        if Userpreference.token != nil {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ClubEchoPointsViewController.self)) as? ClubEchoPointsViewController {
                vc.points = self.points
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let loginvc = (UIStoryboard(name: StoryBoard.login.rawValue, bundle: nil)).instantiateViewController(withIdentifier: String(describing: LoginWithMobileViewController.self)) as? LoginWithMobileViewController {
                self.navigationController?.pushViewController(loginvc, animated: true)
            }
        }
    }
    
    @IBAction func profileSettingsDidTapped(_ sender: UIButton) {
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
            picker.delegate = self
            picker.allowsEditing = true
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
                self.openGallary()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                alert.popoverPresentationController?.sourceView = sender
                alert.popoverPresentationController?.sourceRect = sender.bounds
                alert.popoverPresentationController?.permittedArrowDirections = .up
            default:
                break
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkCameraPermission(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            present(picker, animated: true, completion: nil)
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    self.present(self.picker, animated: true, completion: nil)
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            print("User do not have access to photo album.")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!){ success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        case .denied:
            print("User has denied the permission.")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!){ success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        case .limited:
            print("User has denied the permissions.")
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!){ success in
                if success {
                    print("URL opened successfully")
                } else {
                    print("Failed to open URL")
                }
            }
        @unknown default:
            print("User has denied the permission default.")
        }
    }
    
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            picker.delegate = self
            checkCameraPermission()
        }else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        checkCameraPermission()
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
//        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchNewViewController.self)) as? SearchNewViewController {
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
                
            }
        }
    }
    
    func stopProfileIndicator() {
        DispatchQueue.main.async {
            
            self.tableViewProfile.refreshControl?.endRefreshing()
        }
    }
    
    func unAuthorizedToken(message: String) {
        print(message)
    }
    
    func didGetCustomerData(data: Customer) {
        DispatchQueue.main.async {
            self.addRefreshControl()
            let name = (data.firstname ?? "") + " " + (data.lastname ?? "")
            let truncatedName: String?
            if name.count > 24 {
                truncatedName = data.firstname ?? "" //String(name.prefix(24)) + "..."
            } else {
                truncatedName = name
            }
            self.profileName.setAttributedTitleWithProperties(title: truncatedName ?? "", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24))
            
            if let location = Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines), location != "", let createdAt = data.createdAt , createdAt != "" {
                let dateStr = EthosDateAndTimeHelper().getYearFromDate(str: createdAt)
                self.userLocation.setAttributedTitleWithProperties(title: "\(location), joined on \(dateStr)", font: EthosFont.Brother1816Regular(size: 10), alignment: .center, foregroundColor: .black)
            } else if let location = Userpreference.location?.trimmingCharacters(in: .whitespacesAndNewlines), location != "" {
                self.userLocation.setAttributedTitleWithProperties(title: "\(location)", font: EthosFont.Brother1816Regular(size: 10),  alignment: .center, foregroundColor: .black)
            } else if let createdAt = data.createdAt , createdAt != "" {
                let dateStr = EthosDateAndTimeHelper().getYearFromDate(str: createdAt)
                self.userLocation.setAttributedTitleWithProperties(title: "Joined on \(dateStr)", font: EthosFont.Brother1816Regular(size: 10), alignment: .center, foregroundColor: .black)
            }
            
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
        self.profileName.setAttributedTitleWithProperties(title: EthosConstants.Guest, font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24))
        self.userLocation.setAttributedTitleWithProperties(title: EthosConstants.SignIn.uppercased(), font: EthosFont.Brother1816Regular(size: 12), alignment: .center, foregroundColor: .black, kern: 0.5)
        
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
        return ((shouldShowFollowUsIcons == true) ?  8 : 7)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: (EthosConstants.MyWishList + " (\(self.productCount))").uppercased(),
                    font: EthosFont.Brother1816Medium(size: 10),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.arrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.appBGColor,
                    topSpacing: 14,
                    bottomSpacing: 14, kern: 0.5, lineHeightMultiple: 1
                )
                return cell
            }
            
        case 1 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: (EthosConstants.SavedArticles + " (\(self.articleCount))").uppercased(),
                    font: EthosFont.Brother1816Medium(size: 10),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.arrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.appBGColor,
                    topSpacing: 14,
                    bottomSpacing: 14, kern: 0.5, lineHeightMultiple: 1
                )
                return cell
            }
            
        case 2 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: "Scan your watch".uppercased(),
                    font: EthosFont.Brother1816Medium(size: 10),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.arrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.appBGColor,
                    topSpacing: 14,
                    bottomSpacing: 14, kern: 0.5, lineHeightMultiple: 1
                )
                return cell
            }
            
        case 3 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.HelpCentre.uppercased(),
                    font: EthosFont.Brother1816Medium(size: 10),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.arrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.appBGColor,
                    topSpacing: 14,
                    bottomSpacing: 14, kern: 0.5, lineHeightMultiple: 1
                )
                return cell
            }
            
        case 4 :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.ContactUs.uppercased(),
                    font: EthosFont.Brother1816Medium(size: 10),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.arrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.appBGColor,
                    topSpacing: 14,
                    bottomSpacing: 14, kern: 0.5, lineHeightMultiple: 1
                )
                return cell
            }
            
        case 5 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                cell.setHeading(
                    title: EthosConstants.ShareThisApp.uppercased(),
                    font: EthosFont.Brother1816Medium(size: 10),
                    leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: UIImage(named: EthosConstants.arrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: EthosColor.appBGColor,
                    topSpacing: 14,
                    bottomSpacing: 14, kern: 0.5, lineHeightMultiple: 1
                )
                return cell
            }
            
        case 6 :
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self), for: indexPath) as? HeadingCell {
                
                cell.setHeading(
                    title: "FOLLOW US",
                    font: EthosFont.Brother1816Medium(size: 10),leading: 0,
                    trailling: 0,
                    showDisclosure: true,
                    disclosureImageDefault: self.shouldShowFollowUsIcons == true ? UIImage(named: EthosConstants.upArrow) : UIImage(named: EthosConstants.downArrow),
                    disclosureHeight: 16,
                    disclosureWidth: 16,
                    showUnderLine: true,
                    underlineColor: self.shouldShowFollowUsIcons == true ? .clear : EthosColor.appBGColor,
                    topSpacing: 14,
                    bottomSpacing: 14, kern: 0.5, lineHeightMultiple: 1
                )
                return cell
            }
            
        case 7 : if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FollowUsTableViewCell.self), for: indexPath) as? FollowUsTableViewCell {
            return cell
        }
            
        default: break
            
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        switch indexPath.section {
            
        case 0 :
            if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosProfileCollectionViewController.self)) as? EthosProfileCollectionViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 1 :
            if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: EthosProfileTableViewController.self)) as? EthosProfileTableViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 2 : break
            
            
        case 3 :
            
            if let vc =  UIStoryboard(name: StoryBoard.home.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing: HelpAndSupportViewController.self)) as? HelpAndSupportViewController {
                
                Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.HelpCenterClicked, properties: [
                    EthosConstants.Email : Userpreference.email,
                    EthosConstants.UID : Userpreference.userID,
                    EthosConstants.Gender : Userpreference.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS
                ])
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 4 :
            
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
            
        case 5 :
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
            
            
        case 6 : self.shouldShowFollowUsIcons = !shouldShowFollowUsIcons
            
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
