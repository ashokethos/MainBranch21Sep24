//
//  ForAboutCollectionPreOwnedTableViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 24/09/24.
//

import UIKit

class ForAboutCollectionPreOwnedTableViewCell: UITableViewCell {

    @IBOutlet weak var productGalleryImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textDataTableView: UITableView!
    @IBOutlet weak var bottomConstraintTitleLbl: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintTextDataTableView: NSLayoutConstraint!
    
    var index : IndexPath?
    var isForPreOwned = false
    var delegate : SuperViewDelegate?
    var CollectionDescriptionTextDataArr = [CollectionDescriptionTextData]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textDataTableView.registerCell(className: AboutCollectionTextDataTableViewCell.self)
        textDataTableView.dataSource = self
        textDataTableView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        textDataTableView.isScrollEnabled = false
        heightConstraintTextDataTableView.constant = textDataTableView.contentSize.height
        textDataTableView.layoutIfNeeded()
        self.contentView.layoutIfNeeded()
    }
    
    var data : (String? , String?)? {
        didSet {
            if let data = self.data {
                if let image = data.0 {
                    UIImage.loadFromURL(url: image) { image in
                        self.productGalleryImgView.contentMode = .scaleAspectFit
                        self.productGalleryImgView.image = image
//                        self.imageViewProductGallery.image = image.imageResized(to: CGSize(width: self.imageViewProductGallery.frame.width + 200, height: self.imageViewProductGallery.frame.height))
                        if let html = data.1 {
                        }
                    }
                }
            }
        }
    }
    
    var htmlString : String? {
        didSet {
            if htmlString == ""{
                self.heightConstraintTextDataTableView.constant = 0
            }else{
                self.heightConstraintTextDataTableView.constant = textDataTableView.contentSize.height
            }
        }
    }
    
    var titleString : String? {
        didSet {
            if titleString == ""{
                bottomConstraintTitleLbl.constant = 0
            }else{
                bottomConstraintTitleLbl.constant = 20
            }
//            EthosFont.MrsEavesXLSerifNarOTReg(size: 24)
            titleLbl.setAttributedTitleWithProperties(title: titleString ?? "", font: EthosFont.Brother1816Regular(size: 16), lineHeightMultiple: 1.25, kern: 0.1)
        }
    }
    
}

extension ForAboutCollectionPreOwnedTableViewCell: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CollectionDescriptionTextDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = textDataTableView.dequeueReusableCell(withIdentifier: String(describing: AboutCollectionTextDataTableViewCell.self), for: indexPath) as? AboutCollectionTextDataTableViewCell
        
        cell?.titleLbl.setHtmlTitleWithProperties(title: self.CollectionDescriptionTextDataArr[indexPath.row].head ?? "", font: EthosFont.Brother1816Bold(size: 12))
        var des: String?
        if (self.CollectionDescriptionTextDataArr[indexPath.row].subhead ?? "").hasPrefix("<p>") && (self.CollectionDescriptionTextDataArr[indexPath.row].subhead ?? "").hasSuffix("</p>"){
            des = String((self.CollectionDescriptionTextDataArr[indexPath.row].subhead ?? "").dropFirst(3))
            des = String(des!.dropLast(4))
        }else{
            des = (self.CollectionDescriptionTextDataArr[indexPath.row].subhead ?? "").replacingOccurrences(of: "<p>",with: "",options: .caseInsensitive).replacingOccurrences(of: "</p>",with: "", options: .caseInsensitive)
        }
//        let htmlStr = (self.CollectionDescriptionTextDataArr[indexPath.row].subhead ?? "").replacingOccurrences(of: "<p>",with: "<br>",options: .caseInsensitive).replacingOccurrences(of: "</p>",with: "</br>", options: .caseInsensitive)
        cell?.descriptionLbl.setHtmlTitleWithProperties(title: des ?? "", font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.25, kern: 0.5)
        return cell!
    }
}
