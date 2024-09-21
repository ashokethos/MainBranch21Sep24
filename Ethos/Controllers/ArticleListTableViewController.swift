//
//  ArticleListTableViewController.swift
//  Ethos
//
//  Created by mac on 06/09/23.
//

import UIKit
import Mixpanel
import SkeletonView

class ArticleListTableViewController: UIViewController {
    
    @IBOutlet weak var viewNoArticles: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tableViewArticles: UITableView!
    
    let viewModel = GetArticlesViewModel()
    
    var articleCategory : ArticlesCategory?
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var imageTitle: UIImageView!
    
    @IBOutlet weak var footerIndicator: UIActivityIndicatorView!
    @IBOutlet weak var articleIndicator: UIActivityIndicatorView!
    
    var key : ArticleListKey = .curatedList
    
    var isForPreOwn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewArticles.isSkeletonable = true
        setup()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.setUI()
            self.callApi()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tableViewArticles.reloadData()
    }
    
    func setup() {
        self.tableViewArticles.registerCell(className: HomeTableViewCell.self)
        self.tableViewArticles.registerCell(className: HeadingCell.self)
        self.addTapGestureToDissmissKeyBoard()
        self.viewModel.delegate = self
        self.addRefreshControl()
    }
    
    func addRefreshControl() {
        refreshControl.tintColor = UIColor.black
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing".uppercased(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 10), NSAttributedString.Key.kern : 1])
        self.tableViewArticles.refreshControl = refreshControl
    }
    
    @objc func refreshTable() {
        callApi()
    }
    
    func callApi() {
        switch key {
        case .latest:
            viewModel.getArticles(category: "latest", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
        case .trending:
            viewModel.getArticles(category: "trending", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
        case .revolution:
            viewModel.getArticles(category: "revolution", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: false)
        case .curatedList:
            viewModel.getArticles(category: "curated-list", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
        case .featuredVideos:
            viewModel.getArticles(category: "featured-video", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
        case .editorsPicks:
            viewModel.getArticles(category: "editor-picks", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
        case .readListCategory:
            viewModel.getArticles(category: articleCategory?.name ?? "", site: self.isForPreOwn ? .secondMovement : .ethos)
        }
    }
    
    func setUI() {
        self.imageTitle.image = self.isForPreOwn ? UIImage.imageWithName(name: EthosConstants.apptitle2) : UIImage.imageWithName(name: EthosConstants.apptitle)
        
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwn
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func reloadView() {
        self.tableViewArticles.reloadData()
        self.viewNoArticles.isHidden = !viewModel.articles.isEmpty
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnExploreNowDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ArticleListTableViewController : SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return String(describing: HomeTableViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as? HomeTableViewCell {
            cell.contentView.showAnimatedGradientSkeleton()
            return cell
        }
        return nil
    }
    
    
}

extension ArticleListTableViewController  : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self)) as? HomeTableViewCell {
            cell.isForPreOwn = self.isForPreOwn
            cell.article = viewModel.articles[indexPath.row]
            cell.contentView.hideSkeleton()
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
            vc.isForPreOwned = self.isForPreOwn
            vc.articleId = viewModel.articles[indexPath.row].id
            Mixpanel.mainInstance().track(event: "Article Clicked", properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ArticleID : viewModel.articles[indexPath.row].id,
                EthosConstants.ArticleTitle : viewModel.articles[indexPath.row].title,
                EthosConstants.ArticleCategory : viewModel.articles[indexPath.row].category
            ])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: viewModel.articles.count - 1, section: 0){
            switch key {
            case .latest:
                viewModel.getNewArticles(category: "latest", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
            case .trending:
                viewModel.getNewArticles(category: "trending", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
            case .revolution:
                viewModel.getNewArticles(category: "revolution-list", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
            case .curatedList:
                viewModel.getNewArticles(category: "curated-list", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
            case .featuredVideos:
                viewModel.getNewArticles(category: "featured-video", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
            case .editorsPicks:
                viewModel.getNewArticles(category: "editor-picks", site: self.isForPreOwn ? .secondMovement : .ethos, forViewAll: true)
            case .readListCategory:
                viewModel.getNewArticles(category: articleCategory?.name ?? "", site: self.isForPreOwn ? .secondMovement : .ethos )
            }
        }
    }
    
    
}

extension ArticleListTableViewController : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        reloadView()
    }
    
    func errorInGettingArticles(error: String) {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            if self.tableViewArticles.refreshControl?.isRefreshing != true {
                self.tableViewArticles.showAnimatedGradientSkeleton()
            }
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.tableViewArticles.refreshControl?.endRefreshing()
            self.tableViewArticles.hideSkeleton()
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

