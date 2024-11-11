//
//  ForAboutCollectionTableViewCell.swift
//  Ethos
//
//  Created by Ashok kumar on 21/09/24.
//

import UIKit

class ForAboutCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var productGalleryImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textDataTableView: UITableView!
    @IBOutlet weak var constraintHeightImg: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintTitleLbl: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintTextDataTableView: NSLayoutConstraint!
    
    var index : IndexPath?
    var isForPreOwned = false
    var delegate : SuperViewDelegate?
    var imageStr: String?
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
        self.textDataTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        imageData(image: imageStr ?? "")
        
        textDataTableView.isScrollEnabled = false
        heightConstraintTextDataTableView.constant = textDataTableView.contentSize.height
        self.contentView.layoutIfNeeded()
        textDataTableView.layoutIfNeeded()
    }
    
    var data : (String? , String?)? {
        didSet {
            if let data = self.data {
                if let image = data.0 {
                    imageData(image: image)
                }
            }
        }
    }
    
    func imageData(image: String){
        UIImage.loadFromURL(url: image) { image in
            self.productGalleryImgView.image = image
            let aspectRatio = image.size.width / image.size.height
            self.productGalleryImgView.widthAnchor.constraint(equalTo: self.productGalleryImgView.heightAnchor, multiplier: aspectRatio).isActive = true
            self.productGalleryImgView.contentMode = .scaleAspectFit
            self.textDataTableView.reloadData()
            self.heightConstraintTextDataTableView.constant = self.textDataTableView.contentSize.height
            self.contentView.layoutIfNeeded()
            self.textDataTableView.layoutIfNeeded()
            print(image.size.height)
            print(image.size.width)
            //            self.constraintHeightImg.constant = image.size.height / 2
            //            if self.frame.width > 439{
            //                if image.size.height > 760{
            //                    self.productGalleryImgView.contentMode = .scaleAspectFit
            //                    self.constraintHeightImg.constant = 700
            //                    self.contentView.layoutIfNeeded()
            //                    self.textDataTableView.layoutIfNeeded()
            //                }else {
            //                    self.productGalleryImgView.contentMode = .scaleAspectFit
            //                    self.constraintHeightImg.constant = 580
            //                    self.contentView.layoutIfNeeded()
            //                    self.textDataTableView.layoutIfNeeded()
            //                }
            //            }else{
            //                if image.size.height > 760{
            //                    self.productGalleryImgView.contentMode = .scaleAspectFit
            //                    self.constraintHeightImg.constant = 660
            //                    self.contentView.layoutIfNeeded()
            //                    self.textDataTableView.layoutIfNeeded()
            //                }else {
            //                    self.productGalleryImgView.contentMode = .scaleAspectFit
            //                    self.constraintHeightImg.constant = 500
            //                    self.contentView.layoutIfNeeded()
            //                    self.textDataTableView.layoutIfNeeded()
            //                }
            //            }
            
            //            self.productGalleryImgView.contentMode = .scaleAspectFit
            //            let ratio = image.size.width / image.size.height
            //            let newHeight = self.productGalleryImgView.frame.width / ratio
            //            self.constraintHeightImg.constant = newHeight
            //            self.contentView.layoutIfNeeded()
            
            
            
            
            
            //            if image.size.height > 1400{
            ////                self.imageRatioConstraint.constant = 700
            //                self.productGalleryImgView.contentMode = .scaleAspectFill
            //                self.productGalleryImgView.clipsToBounds = true
            //            }else{
            //                self.productGalleryImgView.contentMode = .scaleAspectFit
            //            }
            if self.isForPreOwned{
                //                if image.size.height > 1500{
                //                    self.constraintHeightImg.constant = 680
                //                }
                //                else{
                //                    self.constraintHeightImg.constant = 700
                //                }
            }else{
                //                self.constraintHeightImg.constant = image.size.height - 50
                //                            if self.frame.width > 395 && self.frame.width < 441{
                //                                if image.size.height > 1500{
                //                                    self.constraintHeightImg.constant = 690
                //                                }else if image.size.height > 700 && image.size.height < 1499{
                //                                    self.constraintHeightImg.constant = 580
                //                                }else{
                //                                    self.constraintHeightImg.constant = 690
                //                                }
                //                            }else if self.frame.width > 375 && self.frame.width < 395{
                //                                if image.size.height > 1500{
                //                                    self.constraintHeightImg.constant = image.size.height / 2 - 210
                //                                }else if image.size.height > 700{
                //                                    self.constraintHeightImg.constant = 500
                //                                }else{
                //                                    self.constraintHeightImg.constant = image.size.height / 2 - 210
                //                                }
                //                            }else{
                //                                self.constraintHeightImg.constant = image.size.height / 2.8
                //                            }
                //                            if image.size.height > 1500{
                //                                self.constraintHeightImg.constant = 680
                //                            }else if image.size.height > 700{
                //                                self.constraintHeightImg.constant = 580
                //                            }else{
                //                                self.constraintHeightImg.constant = 700
                //                            }
            }
            
            
            //
            //            self.productGalleryImgView.image = image
            //                        self.imageViewProductGallery.image = image.imageResized(to: CGSize(width: self.imageViewProductGallery.frame.width + 200, height: self.imageViewProductGallery.frame.height))
            if let html = self.data?.1 {
            }
            
            self.contentView.layoutIfNeeded()
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
            titleLbl.setHtmlTitleWithProperties(title: titleString ?? "", font: EthosFont.Brother1816Regular(size: 16))
        }
    }
    
}

extension ForAboutCollectionTableViewCell: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.CollectionDescriptionTextDataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = textDataTableView.dequeueReusableCell(withIdentifier: String(describing: AboutCollectionTextDataTableViewCell.self), for: indexPath) as? AboutCollectionTextDataTableViewCell
//        if indexPath.row == 0{
//            cell?.topConstraintTitleLbl.constant = 0
//        }else{
//            cell?.topConstraintTitleLbl.constant = 12
//        }
//        if self.CollectionDescriptionTextDataArr[indexPath.row].head ?? "" == ""{
//            cell?.topConstraintDescriptionLbl.constant = 0
//        }else{
//            cell?.topConstraintDescriptionLbl.constant = 12
//        }
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


struct CollectionDescriptionTextData {
    var head : String?
    var subhead : String?
}
