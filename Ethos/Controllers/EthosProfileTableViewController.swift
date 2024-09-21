//
//  EthosProfileTableViewController.swift
//  Ethos
//
//  Created by mac on 03/08/23.
//

import UIKit
import Mixpanel

class EthosProfileTableViewController: UIViewController {
    
    @IBOutlet weak var btnExploreNow: UIButton!
    @IBOutlet weak var viewNoArticles: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tableViewArticles: UITableView!
    @IBOutlet weak var lblScreenTitle: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var savedArticles = [Article]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchArticles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      
    }
    
    func setup() {
        self.lblTitle.setAttributedTitleWithProperties(title: "You haven’t added any articles yet", font: EthosFont.MrsEavesXLSerifNarOTReg(size: 24), alignment: .center, lineHeightMultiple: 1.25, kern: 0.1)
        self.tableViewArticles.registerCell(className: HomeTableViewCell.self)
        self.addTapGestureToDissmissKeyBoard()
        self.setUI()
    }
    
    func setUI() {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named:EthosConstants.profileBookmark)
        imageAttachment.bounds = CGRect(x: 0, y: -3, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        let completeText = NSMutableAttributedString(string: EthosConstants.Click + "  ")
        completeText.append(attachmentString)
        let textAfterIcon = NSAttributedString(string: EthosConstants.tosavearticles)
        completeText.append(textAfterIcon)
        self.lblMessage.textAlignment = .center
        self.lblMessage.attributedText = completeText
        
        self.btnExploreNow.setAttributedTitleWithProperties(title: "EXPLORE NOW", font: EthosFont.Brother1816Medium(size: 12),  alignment: .center, foregroundColor: .white , backgroundColor: .black, lineHeightMultiple: 1.5, kern: 1)
    }
    
    func fetchArticles() {
        DataBaseModel().fetchArticles { articles in
            var articleArr = [Article]()
            for article in articles {
                let art = Article(id: Int(article.articleId), title: article.title, author: article.author, video: article.video, category: article.category, mainCategories: article.mainCategories, createdDate: Int(article.createdAt), commentCount: Int(article.commentCount), assets: [Asset(id: 0, url: article.imageUrl, type: article.assetType, duration: Int(article.duration) )])
                art.forPreOwn = article.preowned
                articleArr.append(art)
            }
            
            self.savedArticles = articleArr
            
            DispatchQueue.main.async {
                self.tableViewArticles.reloadData()
                self.reloadView()
            }
        }
    }
    
    func reloadView() {
        
        self.tableViewArticles.reloadData()
        self.viewNoArticles.isHidden = !savedArticles.isEmpty
    }
    
    @IBAction func btnBackDidTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnExploreNowDidTapped(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func btnSearchDidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}

extension EthosProfileTableViewController  : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.savedArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HomeTableViewCell.self), for: indexPath) as? HomeTableViewCell {
            cell.article = savedArticles[safe : indexPath.row]
            cell.isForPreOwn = (cell.article?.forPreOwn ?? false)
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ArticleDetailViewController.self)) as? ArticleDetailViewController {
            vc.isForPreOwned = self.savedArticles[safe : indexPath.row]?.forPreOwn ?? false
            vc.articleId = self.savedArticles[safe : indexPath.row]?.id
            Mixpanel.mainInstance().trackWithLogs(event: EthosConstants.ArticleClicked, properties: [
                EthosConstants.Email : Userpreference.email,
                EthosConstants.UID : Userpreference.userID,
                EthosConstants.Gender : Userpreference.gender,
                EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
                EthosConstants.Platform : EthosConstants.IOS,
                EthosConstants.ArticleID : self.savedArticles[safe : indexPath.row]?.id,
                EthosConstants.ArticleTitle : self.savedArticles[safe : indexPath.row]?.title,
                EthosConstants.ArticleCategory : self.savedArticles[safe : indexPath.row]?.category
            ])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { act, view, act2 in
            if let article = self.savedArticles[safe : indexPath.row] {
                DataBaseModel().checkArticleExistsFromArticle(article: article) { exist in
                    if exist {
                        DataBaseModel().unsaveArticleFromArticle(article: article) {
                            self.fetchArticles()
                        }
                    }
                }
            }
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
        
        
    }
    
}

extension EthosProfileTableViewController : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys {
            if key == .reloadTableView {
                self.fetchArticles()
            }
        }
    }
}

