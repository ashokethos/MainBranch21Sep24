//
//  RevolutionTableViewHeaderCell.swift
//  Ethos
//
//  Created by Ashok kumar on 31/07/24.
//

import UIKit
import Mixpanel

protocol RevolutionTableViewCellDelegate: NSObjectProtocol{
    func didPressCell(sender: IndexPath)
}

class RevolutionTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var websiteBtn: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var instagramBtnLbl: UILabel!
    @IBOutlet weak var revolutionArticleTableView: UITableView!
    @IBOutlet weak var heightConstraintRevolutionArticleTableView: NSLayoutConstraint!
    @IBOutlet weak var heightBottomSpaceView: NSLayoutConstraint!
    
    var articles = [Article]()
    var heightRevolutionTableView : CGFloat = 0
    var delegate:RevolutionTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        revolutionArticleTableView.registerCell(className: RevolutionReviewTableViewCell.self)
        revolutionArticleTableView.dataSource = self
        revolutionArticleTableView.delegate = self
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
       
        if heightRevolutionTableView == 0 {
            heightRevolutionTableView = revolutionArticleTableView.contentSize.height
        }else if heightRevolutionTableView < revolutionArticleTableView.contentSize.height {
            heightRevolutionTableView = revolutionArticleTableView.contentSize.height
        }else{
            heightRevolutionTableView = revolutionArticleTableView.contentSize.height
        }
        revolutionArticleTableView.isScrollEnabled = false
        heightConstraintRevolutionArticleTableView.constant = heightRevolutionTableView
        revolutionArticleTableView.layoutIfNeeded()
    }
    
    func setSpacing(height: CGFloat = 8, color : UIColor = EthosColor.appBGColor) {
        self.heightBottomSpaceView.constant = height
//        self.contentView.backgroundColor = color
        self.layoutIfNeeded()
    }
    
}

extension RevolutionTableViewHeaderCell: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if articles.count > 7{
            return 6
        }else{
            return articles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RevolutionReviewTableViewCell.self)) as! RevolutionReviewTableViewCell
        if articles.count > 0{
            if let url = URL(string: (articles[indexPath.row].topFeaturedImage ?? "")) {
                cell.revolutionImg.kf.setImage(with: url)
            }
            cell.reviewLbl.setAttributedTitleWithProperties(
                title: articles[indexPath.row].category?.uppercased() ?? "",
                font: EthosFont.Brother1816Regular(size: 10),
                foregroundColor: EthosColor.red,
                kern: 0.5
            )
            cell.reviewTitleLbl.numberOfLines = 3
            cell.reviewTitleLbl.setAttributedTitleWithProperties(
                title: articles[indexPath.row].title ?? "",
                font: EthosFont.MrsEavesXLSerifNarOTReg(size: 18),
                lineHeightMultiple: 1.25,
                kern: 0.1
            )
            if let createdDate = articles[indexPath.row].createdDate {
                let strCreatedDate = EthosDateAndTimeHelper().getStringFromTimeStamp(timeStamp:createdDate)
                cell.dateLbl.setAttributedTitleWithProperties(
                    title: strCreatedDate,
                    font: EthosFont.MrsEavesXLSerifNarOTRegItalic(size: 14),
                    foregroundColor: EthosColor.darkGrey,
                    lineHeightMultiple: 1.43,
                    kern: 0.1
                )
            }
            
            if articles.count > 7{
                if indexPath.row == 5{
                    cell.bottomLineView.isHidden = true
                    cell.setSpacing(height: 0, color: UIColor.init(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0000))
                }else{
                    cell.bottomLineView.isHidden = false
                    cell.setSpacing(height: 0, color: .clear)
                }
            }else{
                if indexPath.row == articles.count - 1{
                    cell.bottomLineView.isHidden = true
                    cell.setSpacing(height: 0, color: UIColor.init(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0000))
                }else{
                    cell.bottomLineView.isHidden = false
                    cell.setSpacing(height: 0, color: .clear)
                }
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.didPressCell(sender: indexPath)
    }
    
}
