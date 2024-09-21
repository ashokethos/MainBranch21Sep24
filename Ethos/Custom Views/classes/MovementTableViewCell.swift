//
//  VideoTableViewCell.swift
//  Ethos
//
//  Created by mac on 06/07/23.
//

import UIKit

class MovementTableViewCell: UITableViewCell {


    @IBOutlet weak var lblCallibreDescription: UILabel!
    @IBOutlet weak var collectionViewMovement: EthosContentSizedCollectionView!
    @IBOutlet weak var imgViewThumbNail: UIImageView!
    @IBOutlet weak var constraintHeightImageView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopCalibreDescription: NSLayoutConstraint!
    
    var ArrMovement = [(String, String)]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionViewMovement.delegate = self
        self.collectionViewMovement.dataSource = self
        self.collectionViewMovement.registerCell(className: SpecificationCollectionViewCell.self)
        
    }
    
    override func prepareForReuse() {
        self.ArrMovement.removeAll()
        self.calibreImage = nil
        self.movement = nil
        self.imgViewThumbNail.image = nil
        self.constraintHeightImageView.constant = 0
        self.lblCallibreDescription.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Regular(size: 12))
    }
    
    var calibreImage : String? {
        didSet {
            if let calibreImage = self.calibreImage, calibreImage != ""  {
                self.constraintHeightImageView.constant = self.imgViewThumbNail.frame.width
                
                UIImage.loadFromURL(url: calibreImage) { image in
                    self.imgViewThumbNail.image = image.withAlignmentRectInsets(UIEdgeInsets(top: -16, left: -16, bottom: -16, right: -16))
                }
                
            } else {
                self.constraintHeightImageView.constant = 0
            }
        }
    }
    
    var callibreDescription : String? {
        didSet {
            if let callibreDescription = self.callibreDescription {
                self.lblCallibreDescription.setAttributedTitleWithProperties(title: callibreDescription.htmlToAttributedString?.string ?? "", font: EthosFont.Brother1816Regular(size: 14), lineHeightMultiple: 1.25, kern: 0.5)
            }
        }
    }
    
    var movement : [String : String]? {
        didSet {
            
            if let movement = self.movement {
                
                var ArrMovement = [(String, String)]()
                
                movement.forEach { (key, value) in
                    ArrMovement.append((key , value))
                }
                
                self.ArrMovement = ArrMovement.sorted(by: { a, b in
                    b.0.lowercased() > a.0.lowercased()
                })
                
                self.collectionViewMovement.reloadData()
            }
        }
    }
    
}


extension MovementTableViewCell : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ArrMovement.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: SpecificationCollectionViewCell.self), for: indexPath) as? SpecificationCollectionViewCell {
            
            let attribute = ArrMovement[indexPath.item].0
            
            let required = attribute.replacingOccurrences(of: "_", with: " ")
            
            let value = ArrMovement[indexPath.item].1
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 11
            style.alignment = .left
            
            
            let attr1 = NSMutableAttributedString(string: required.capitalized, attributes: [NSAttributedString.Key.font : EthosFont.Brother1816Medium(size: 12), NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.kern : 0.1, NSAttributedString.Key.paragraphStyle : style])
            
            let attr2 = NSMutableAttributedString(string: value, attributes: [NSAttributedString.Key.font : EthosFont.Brother1816Regular(size: 12), NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.kern : 0.1, NSAttributedString.Key.paragraphStyle : style])
            
            attr1.append(NSAttributedString(string: "\n"))
            attr1.append(attr2)
            
            cell.attribute = attr1
            return cell
        }
        return UICollectionViewCell()
    }
    
    
}
