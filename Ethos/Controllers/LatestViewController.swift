//
//  ViewController.swift
//  Ethos
//
//  Created by mac on 21/06/23.
//

import UIKit
import SafariServices
import Mixpanel
import SkeletonView

class LatestViewController: UIViewController {
    
    @IBOutlet weak var tableViewHome: UITableView!
    @IBOutlet weak var lblNoArticles: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblGreeting: UILabel!
    @IBOutlet weak var articleIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileIndicator: UIActivityIndicatorView!
    @IBOutlet weak var footerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var constraintHeightUserView: NSLayoutConstraint!
    @IBOutlet weak var lblNumberOfNotifications: UILabel!
    @IBOutlet weak var viewUser: UIView!
    
    let viewModel = GetArticlesViewModel()
    let customerModel = GetCustomerViewModel()
    let refreshControl = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        callCustomerDetailsApi()
        callGetArticlesApi()
        self.edgesForExtendedLayout = [.bottom]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableViewHome.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewHome.setContentOffset(.zero, animated: true)
        updateNotificationCount()
        callCustomerDetailsApi()
        if tableViewHome.numberOfSections > 0 {
            self.tableViewHome.contentOffset = .zero
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for index in tableViewHome.indexPathsForVisibleRows ?? [] {
            if let view = tableViewHome.footerView(forSection: index.section) as? AdvertisementHeaderFooterView {
                view.playerLayer.player?.pause()
                view.btnPausePlay.isSelected = false
            }
        }
    }
    
    func setup() {
        self.tableViewHome.registerCell(className: HomeTableViewCell.self)
        self.tableViewHome.registerCell(className: SpacingTableViewCell.self)
        self.tableViewHome.register(UINib(nibName: String(describing: AdvertisementHeaderFooterView.self), bundle: nil), forHeaderFooterViewReuseIdentifier:  String(describing: AdvertisementHeaderFooterView.self))
        self.viewModel.delegate = self
        self.customerModel.delegate = self
        self.addTapGestureToDissmissKeyBoard()
        self.setWelcomeText()
        self.setCurrenDate()
        self.addRefreshControl()
        self.lblNumberOfNotifications.setBorder(borderWidth: 0, borderColor: .clear, radius: 7.5)
        NotificationCenter.default.addObserver(forName:  NSNotification.Name("receivedNotification") , object: nil, queue: nil) { notification in
            self.updateNotificationCount()
        }
        self.tableViewHome.isSkeletonable = true
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: EthosConstants.Refreshing.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.tableViewHome.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        self.callGetArticlesApi()
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
    
    func setWelcomeText() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 4..<12 : lblGreeting.text = GreetingText.morning.rawValue
        case 12..<17 : lblGreeting.text = GreetingText.afternoon.rawValue
        default: lblGreeting.text = GreetingText.evening.rawValue
        }
    }
    
    func setCurrenDate() {
        lblDate.text = EthosDateAndTimeHelper().getWelcomeTimeString()
    }
    
    func callCustomerDetailsApi() {
        if Userpreference.token != nil {
            customerModel.getCustomerDetails()
        } else {
            self.lblUserName.text = EthosConstants.Guest
        }
    }
    
    func callGetArticlesApi() {
        viewModel.getArticles()
    }
    
    func reloadView() {
        self.tableViewHome.reloadData()
        self.lblNoArticles.isHidden = !viewModel.articles.isEmpty
    }
    
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = false
            self.navigationController?.pushViewController(vc, animated: true)
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
                "Screen" : "Latest"
            ]
            
            Mixpanel.mainInstance().trackWithLogs(event: "Notifications Clicked" , properties: properties)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

extension LatestViewController : UITableViewDataSource, UITableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return String(describing: HomeTableViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self), for: indexPath) as? HomeTableViewCell {
            cell.contentView.showAnimatedGradientSkeleton()
            return cell
        }
        return UITableViewCell()
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableViewHome.dequeueReusableCell(withIdentifier: String(describing: SpacingTableViewCell.self)) as? SpacingTableViewCell {
            cell.setSpacing(height: 2, color: section == 0 ? .clear : .clear)
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.viewModel.advertisements.contains(where: { ad in
            ((ad.position ?? 1) - 1) == section
        }) {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.viewModel.advertisements.contains(where: { ad in
            ((ad.position ?? 1) - 1) == section
        }) {
            let adToShow = self.viewModel.advertisements.first { ad in
                ((ad.position ?? 1) - 1) == section
            }
            
            if let ad = adToShow {
                
                if let view = tableViewHome.dequeueReusableHeaderFooterView(withIdentifier: String(describing: AdvertisementHeaderFooterView.self)) as? AdvertisementHeaderFooterView {
                    view.advertisment = ad
                    view.delegate = self
                    view.superTableView = self.tableViewHome
                    view.superViewController = self
                    return view
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self), for: indexPath) as? HomeTableViewCell {
            cell.hideSkeleton()
            cell.index = indexPath
            cell.isForPreOwn = false
            cell.article = viewModel.articles[safe : indexPath.section]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath) is HomeTableViewCell {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
                vc.articleId = viewModel.articles[safe : indexPath.section]?.id
                vc.isForPreOwned = false
                
                Mixpanel.mainInstance().trackWithLogs (
                    event: EthosConstants.ArticleClicked,
                    properties: [
                        EthosConstants.Email : Userpreference.email,
                        EthosConstants.UID : Userpreference.userID,
                        EthosConstants.Gender : Userpreference.gender,
                        EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                        EthosConstants.Platform : EthosConstants.IOS,
                        EthosConstants.ArticleID : self.viewModel.articles[safe : indexPath.section]?.id,
                        EthosConstants.ArticleTitle : self.viewModel.articles[safe : indexPath.section]?.title,
                        EthosConstants.ArticleCategory : self.viewModel.articles[safe : indexPath.section]?.category
                    ]
                )
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: viewModel.articles.count - 1){
            viewModel.getNewArticles()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        if view is AdvertisementHeaderFooterView {
            (view as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
            (view as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            if scrollView == self.tableViewHome {
                for index in tableViewHome.indexPathsForVisibleRows ?? [] {
                    if let footerView = tableViewHome?.footerView(forSection: index.section), UIApplication.topViewController() == self {
                        let rectOfCell = self.tableViewHome.rectForFooter(inSection: index.section)
                        let rectOfCellInSuperview = self.tableViewHome.convert(rectOfCell, to: self.tableViewHome.superview)
                        if rectOfCellInSuperview.origin.y < footerView.contentView.frame.height - 100, rectOfCellInSuperview.origin.y > 80  {
                            (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.play()
                            (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = true
                        } else {
                            (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
                            (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.tableViewHome {
            for index in tableViewHome.indexPathsForVisibleRows ?? [] {
                if let footerView = tableViewHome?.footerView(forSection: index.section), UIApplication.topViewController() == self {
                    let rectOfCell = self.tableViewHome.rectForFooter(inSection: index.section)
                    let rectOfCellInSuperview = self.tableViewHome.convert(rectOfCell, to: self.tableViewHome.superview)
                    if rectOfCellInSuperview.origin.y < footerView.contentView.frame.height - 100, rectOfCellInSuperview.origin.y > 50  {
                        (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.play()
                        (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = true
                    } else {
                        (footerView as? AdvertisementHeaderFooterView)?.playerLayer.player?.pause()
                        (footerView as? AdvertisementHeaderFooterView)?.btnPausePlay.isSelected = false
                    }
                }
            }
        }
    }
    
}

extension LatestViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        reloadView()
    }
    
    func errorInGettingArticles(error: String) {
        DispatchQueue.main.async {
            
        }
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.tableViewHome.showAnimatedGradientSkeleton()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.tableViewHome.hideSkeleton()
            self.tableViewHome.refreshControl?.endRefreshing()
        }
    }
    
    func startFooterIndicator() {
        DispatchQueue.main.async {
            self.footerIndicator.startAnimating()
        }
    }
    
    func stopFooterIndicator() {
        DispatchQueue.main.async {
            self.footerIndicator.stopAnimating()
        }
    }
}

extension LatestViewController : GetCustomerViewModelDelegate {
    func userDeleteSuccess() {
        
    }
    
    func userDeleteFailed(error: String) {
        
    }
    
    func didGetCustomerPoints(points: Int) {
        
    }
    
    func updateProfileSuccess(message: String) {
        
    }
    
    func updateProfileFailed(message: String) {
        
    }
    
    func startProfileIndicator() {
        DispatchQueue.main.async {
            self.profileIndicator.startAnimating()
        }
    }
    
    func stopProfileIndicator() {
        DispatchQueue.main.async {
            self.profileIndicator.stopAnimating()
        }
    }
    
    func unAuthorizedToken(message : String) {
        DispatchQueue.main.async {
            if let alertController = self.storyboard?.instantiateViewController(withIdentifier: String(
                describing: EthosAlertController.self
            )
            ) as? EthosAlertController {
                alertController.setActions(
                    title: "Your session has expired. Please log in again.",
                    message: "",
                    secondActionTitle: "Ok",
                    secondAction:  {
                        Userpreference.resetValues()
                        let vc = UIStoryboard(name: StoryBoard.login.rawValue, bundle: nil).instantiateViewController(withIdentifier: EthosIdentifiers.rootNavigationViewController)
                        UIApplication
                            .shared
                            .connectedScenes
                            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                            .last { $0.isKeyWindow }?.rootViewController = vc
                    })
                self.present(alertController, animated: true)
            }
        }
    }
    
    func didGetCustomerData(data: Customer) {
        self.profileIndicator.stopAnimating()
        self.lblUserName.text = (data.firstname ?? "") + " " + (data.lastname ?? "")
        
        if Userpreference.shouldSendSignUpAnalytics == true {
            Userpreference.shouldSendSignUpAnalytics = false
            Mixpanel.mainInstance().identify(distinctId: "\(data.id ?? 0)")
            Mixpanel.mainInstance().people.set(properties: ["$email": data.email ?? "", "$name" : (data.firstname ?? "" + " " + (data.lastname ?? ""))?.trimmingCharacters(in: .whitespacesAndNewlines)])
            Mixpanel.mainInstance().trackWithLogs(
                event: "User Signed Up",
                properties:[
                    EthosConstants.UID : data.id,
                    EthosConstants.Email : data.email,
                    "Method" : Userpreference.currentLoginSignupSource,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Gender : data.gender ?? ""
                ])
        }
        
        if Userpreference.shouldSendLoginAnalytics == true {
            Userpreference.shouldSendLoginAnalytics = false
            Mixpanel.mainInstance().identify(distinctId: "\(data.id ?? 0)")
            Mixpanel.mainInstance().people.set(properties: ["$email": data.email ?? "", "$name" : (data.firstname ?? "" + " " + (data.lastname ?? ""))?.trimmingCharacters(in: .whitespacesAndNewlines)])
            Mixpanel.mainInstance().trackWithLogs(
                event: "User Signed In",
                properties:[
                    EthosConstants.UID : data.id,
                    EthosConstants.Gender : data.gender,
                    EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                    EthosConstants.Platform : EthosConstants.IOS,
                    EthosConstants.Email : data.email,
                    "Method" : Userpreference.currentLoginSignupSource
                ]
            )
        }
    }
}

extension LatestViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys {
            if key == .openWebPage, let urlstr = info?[EthosKeys.url] as? String {
                UserActivityViewModel().getDataFromActivityUrl(url: urlstr)
            }
        }
    }
}

extension LatestViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableViewHome {
            if scrollView.contentOffset.y <= 0 {
                self.constraintHeightUserView.constant = 103
            } else if scrollView.contentOffset.y <= 103 {
                self.constraintHeightUserView.constant = 103 - scrollView.contentOffset.y
            } else {
                self.constraintHeightUserView.constant = 0
            }
            self.view.layoutIfNeeded()
        }
    }
}
