//
//  RepairAndServiceCell.swift
//  Ethos
//
//  Created by mac on 30/06/23.
//

import UIKit
import Mixpanel

class RepairAndServiceCell: UITableViewCell {
    
    @IBOutlet weak var constraintTopSpacingHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightHeadingView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSpacingLogo: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightLogo: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSpaceSubHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingSubHeadingAndDescription: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingDescriptionAndCollection: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightImageCollection: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpacingProgressViewAndRequestCallBack: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightBtnRequestCallBack: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomRequestCallBack: NSLayoutConstraint!
    
    @IBOutlet weak var txtBtnKnowMore: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var btnRequestACallBack: UIButton!
    @IBOutlet weak var collectionViewRepairAndService: UICollectionView!
    @IBOutlet weak var imageViewLogo: UIImageView!
    @IBOutlet weak var viewHeadeing: UIView!
    @IBOutlet weak var viewMainContainer: UIView!
    @IBOutlet weak var viewProgress: UIProgressView!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSubHeading: UILabel!
    @IBOutlet weak var viewbtnHeadingDisclosure: UIView!
    @IBOutlet weak var constraintSpaceProgressAndCollection: NSLayoutConstraint!
    
    var isForPreOwn = false
    
    var key : RepairAndServiceKey = .forWhatWeDo {
        didSet {
            setUI()
        }
    }
    
    
    var articleViewModel = GetArticlesViewModel()
    
    
    var delegate : SuperViewDelegate?
    
    var ArrayImage = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCells()
        
    }
    
    override func prepareForReuse() {
        self.isForPreOwn = false
        self.articleViewModel.articles.removeAll()
        self.collectionViewRepairAndService.isPagingEnabled = true
        self.collectionViewRepairAndService.reloadData()
    }
    
    func setupCells() {
        collectionViewRepairAndService.registerCell(className: ImageCollectionViewCell.self)
        collectionViewRepairAndService.registerCell(className: ReadListCollectionViewCell.self)
        collectionViewRepairAndService.dataSource = self
        collectionViewRepairAndService.delegate = self
        
        self.txtBtnKnowMore.setAttributedTitleWithProperties(title: EthosConstants.KnowMore.uppercased(), font: EthosFont.Brother1816Regular(size: 10), foregroundColor: .black, kern: 0.5)
        self.articleViewModel.delegate = self
    }
    
    
    func resetConstraints() {
        self.constraintTopSpacingHeader.constant = 20
        self.constraintHeightHeadingView.constant = 50
        self.constraintTopSpacingLogo.constant = 32
        self.constraintHeightLogo.constant = 50
        self.constraintTopSpaceSubHeader.constant = 40
        self.constraintSpacingSubHeadingAndDescription.constant = 24
        self.constraintSpacingDescriptionAndCollection.constant = 32
        self.constraintHeightImageCollection.constant = 383
        self.constraintSpaceProgressAndCollection.constant = 32
        self.constraintSpacingProgressViewAndRequestCallBack.constant = 32
        self.constraintHeightBtnRequestCallBack.constant = 40
        self.constraintBottomRequestCallBack.constant = 50
        self.imageViewLogo.isHidden = false
        self.viewHeadeing.isHidden = false
        self.viewbtnHeadingDisclosure.isHidden = false
        self.lblHeading.isHidden = false
        self.lblSubHeading.isHidden = false
        self.lblDescription.isHidden = false
        self.collectionViewRepairAndService.isHidden = false
        self.btnRequestACallBack.isHidden = false
        self.viewProgress.isHidden = false
        self.collectionViewRepairAndService.isPagingEnabled = false
        self.viewMainContainer.backgroundColor = EthosColor.white
        self.lblHeading.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
        
        self.lblSubHeading.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Medium(size: 14),lineHeightMultiple: 1.6, kern: 0.5)
        
        self.lblDescription.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
        
        
        
        self.ArrayImage = []
        
        self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.RequestCallBack.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
        
        self.btnRequestACallBack.backgroundColor = .clear
    }
    
    
    func setUI() {
        
        btnRequestACallBack.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        
        switch self.key {
            
        case .forWhoWeAre:
            self.collectionViewRepairAndService.tag = 2
            self.constraintTopSpacingHeader.constant = 20
            self.constraintHeightHeadingView.constant = 50
            self.constraintTopSpacingLogo.constant = 20
            self.constraintHeightLogo.constant = 0
            self.constraintTopSpaceSubHeader.constant = 0
            self.constraintSpacingSubHeadingAndDescription.constant = 24
            self.constraintSpacingDescriptionAndCollection.constant = 32
            self.constraintHeightImageCollection.constant = 230
            self.constraintSpaceProgressAndCollection.constant = 32
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 24
            self.constraintHeightBtnRequestCallBack.constant = 0
            self.constraintBottomRequestCallBack.constant = 40
            self.imageViewLogo.isHidden = true
            self.viewHeadeing.isHidden = false
            self.viewbtnHeadingDisclosure.isHidden = true
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = false
            self.btnRequestACallBack.isHidden = true
            self.viewProgress.isHidden = false
            self.collectionViewRepairAndService.isPagingEnabled = true
            self.viewMainContainer.backgroundColor = EthosColor.appBGColor
            
            
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.WhoWeAre, font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: EthosConstants.AboutEthosWatchCare, font: EthosFont.Brother1816Medium(size: 14),lineHeightMultiple: 1.6, kern: 0.5)
            
            self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.AboutEthosWatchCareDescription, font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
            
            self.lblDescription.numberOfLines = 0
            
            self.ArrayImage = [EthosConstants.repairDemo8,EthosConstants.repairDemo5, EthosConstants.repairDemo6, EthosConstants.repairDemo4, EthosConstants.repairDemo7]
            
            self.collectionViewRepairAndService.isPagingEnabled = false
            
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.RequestCallBack.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
            
            self.btnRequestACallBack.backgroundColor = .clear
            
        case .forWhatWeDo:
            self.collectionViewRepairAndService.tag = 3
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.WhatWeDo.uppercased(), font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: EthosConstants.WeOfferFollowingServices, font: EthosFont.Brother1816Medium(size: 14),lineHeightMultiple: 1.6, kern: 0.5)
            
            self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.weOfferFollowingServicesDescription, font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
            
            self.lblDescription.numberOfLines = 0
            
            self.constraintTopSpacingHeader.constant = 20
            self.constraintHeightHeadingView.constant = 50
            self.constraintTopSpacingLogo.constant = 0
            self.constraintHeightLogo.constant = 0
            self.constraintTopSpaceSubHeader.constant = 20
            self.constraintSpacingSubHeadingAndDescription.constant = 24
            self.constraintSpacingDescriptionAndCollection.constant = 0
            self.constraintHeightImageCollection.constant = 0
            self.constraintSpaceProgressAndCollection.constant = 0
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 0
            self.constraintHeightBtnRequestCallBack.constant = 0
            self.constraintBottomRequestCallBack.constant = 0
            self.ArrayImage = []
            self.imageViewLogo.isHidden = true
            self.viewHeadeing.isHidden = false
            self.viewbtnHeadingDisclosure.isHidden = true
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = true
            self.btnRequestACallBack.isHidden = true
            self.viewProgress.isHidden = true
            self.collectionViewRepairAndService.isPagingEnabled = false
            self.viewMainContainer.backgroundColor = EthosColor.white
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.RequestCallBack.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
            
            self.btnRequestACallBack.backgroundColor = .clear
            
        case .forFromTheWatchGuide:
            self.collectionViewRepairAndService.tag = 4
            self.constraintTopSpacingHeader.constant = 0
            self.constraintHeightHeadingView.constant = 50
            self.constraintTopSpacingLogo.constant = 0
            self.constraintHeightLogo.constant = 0
            self.constraintTopSpaceSubHeader.constant = 0
            self.constraintSpacingSubHeadingAndDescription.constant = 24
            self.constraintSpacingDescriptionAndCollection.constant = 0
            self.constraintHeightImageCollection.constant = 383
            self.constraintSpaceProgressAndCollection.constant = 32
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 32
            self.constraintHeightBtnRequestCallBack.constant = 40
            self.constraintBottomRequestCallBack.constant = 30
            self.imageViewLogo.isHidden = true
            self.viewHeadeing.isHidden = false
            self.viewbtnHeadingDisclosure.isHidden = true
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = false
            self.btnRequestACallBack.isHidden = false
            self.viewProgress.isHidden = false
            self.collectionViewRepairAndService.isPagingEnabled = false
            self.viewMainContainer.backgroundColor = EthosColor.white
            
            self.articleViewModel.getArticles(site: self.isForPreOwn ? .secondMovement : .ethos, watchGuide : true)
            
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.fromWatchGuide.uppercased(), font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Medium(size: 14),lineHeightMultiple: 1.6, kern: 0.5)
            
            self.lblDescription.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
            
            
            self.lblDescription.numberOfLines = 0
            
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.viewWatchGlossary.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
            
            self.btnRequestACallBack.backgroundColor = .clear
            
        case .forsecondMovementSell:
            self.collectionViewRepairAndService.tag = 5
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.SellYourWatch.uppercased(), font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Medium(size: 14),lineHeightMultiple: 1.6, kern: 0.5)
            
            self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.secondMovementSellDescription, font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13)
            
            
            self.lblDescription.numberOfLines = 0
            self.constraintTopSpacingHeader.constant = 20
            self.constraintHeightHeadingView.constant = 50
            self.constraintTopSpacingLogo.constant = 0
            self.constraintHeightLogo.constant = 0
            self.constraintTopSpaceSubHeader.constant = 20
            self.constraintSpacingSubHeadingAndDescription.constant = 0
            self.constraintSpacingDescriptionAndCollection.constant = 0
            self.constraintHeightImageCollection.constant = 0
            self.constraintSpaceProgressAndCollection.constant = 0
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 0
            self.constraintHeightBtnRequestCallBack.constant = 0
            self.constraintBottomRequestCallBack.constant = 0
            self.ArrayImage = []
            self.imageViewLogo.isHidden = true
            self.viewHeadeing.isHidden = false
            self.viewbtnHeadingDisclosure.isHidden = true
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = true
            self.btnRequestACallBack.isHidden = true
            self.viewProgress.isHidden = true
            self.collectionViewRepairAndService.isPagingEnabled = false
            self.viewMainContainer.backgroundColor = EthosColor.white
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.RequestCallBack.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
            self.btnRequestACallBack.backgroundColor = .clear
            
            
        case .forsecondMovementTrade:
            self.collectionViewRepairAndService.tag = 6
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.TradeYourWatch.uppercased(), font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: EthosConstants.secondMovementTradeDescription, font: EthosFont.Brother1816Regular(size: 12))
            
            
            self.lblDescription.setAttributedTitleWithProperties(title: "", font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13)
            
            self.lblDescription.numberOfLines = 0
            
            self.constraintTopSpacingHeader.constant = 20
            self.constraintHeightHeadingView.constant = 50
            self.constraintTopSpacingLogo.constant = 0
            self.constraintHeightLogo.constant = 0
            self.constraintTopSpaceSubHeader.constant = 20
            self.constraintSpacingSubHeadingAndDescription.constant = 0
            self.constraintSpacingDescriptionAndCollection.constant = 0
            self.constraintHeightImageCollection.constant = 0
            self.constraintSpaceProgressAndCollection.constant = 0
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 0
            self.constraintHeightBtnRequestCallBack.constant = 0
            self.constraintBottomRequestCallBack.constant = 0
            self.ArrayImage = []
            self.imageViewLogo.isHidden = true
            self.viewHeadeing.isHidden = false
            self.viewbtnHeadingDisclosure.isHidden = true
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = true
            self.btnRequestACallBack.isHidden = true
            self.viewProgress.isHidden = true
            self.collectionViewRepairAndService.isPagingEnabled = false
            self.viewMainContainer.backgroundColor = EthosColor.appBGColor
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.RequestCallBack.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
            self.btnRequestACallBack.backgroundColor = .clear
        
        case .forReapirAndServiceLocateUs:
            
            self.collectionViewRepairAndService.tag = 7
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.WhereToLocateUs.uppercased(), font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: EthosConstants.FindADropLocation.uppercased(), font: EthosFont.Brother1816Medium(size: 14), lineHeightMultiple: 1.6, kern: 0.5)
            
            
            self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.whereToLocateUsDescription, font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
            
            self.lblDescription.numberOfLines = 0
            
            self.constraintTopSpacingHeader.constant = 16
            self.constraintHeightHeadingView.constant = 50
            self.constraintTopSpacingLogo.constant = 0
            self.constraintHeightLogo.constant = 0
            self.constraintTopSpaceSubHeader.constant = 20
            self.constraintSpacingSubHeadingAndDescription.constant = 20
            self.constraintSpacingDescriptionAndCollection.constant = 0
            self.constraintHeightImageCollection.constant = 0
            self.constraintSpaceProgressAndCollection.constant = 0
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 20
            self.constraintHeightBtnRequestCallBack.constant = 40
            self.constraintBottomRequestCallBack.constant = 0
            self.ArrayImage = []
            self.imageViewLogo.isHidden = true
            self.viewHeadeing.isHidden = false
            self.viewbtnHeadingDisclosure.isHidden = true
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = true
            self.btnRequestACallBack.isHidden = false
            self.viewProgress.isHidden = true
            self.collectionViewRepairAndService.isPagingEnabled = false
            self.viewMainContainer.backgroundColor = .white
            
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.FindOurBoutiques.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .white, backgroundColor: .black, kern: 1)
            
            self.btnRequestACallBack.backgroundColor = .black
        }
        
        DispatchQueue.main.async {
            self.collectionViewRepairAndService.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.collectionViewRepairAndService.reloadData()
            }
        }
        
        if key == .forFromTheWatchGuide {
            self.viewProgress.backgroundColor = EthosColor.appBGColor
        } else {
            self.viewProgress.backgroundColor = EthosColor.white
        }
        
        self.updateProgressView()
    }
    
    @IBAction func btnKnowMoreDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route, EthosKeys.value : String(describing: RepairAndServiceViewController.self)])
    }
    
    @IBAction func btnRequestCallBackDidTapped(_ sender: UIButton) {
        switch key {
        case .forFromTheWatchGuide:
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route, EthosKeys.value : String(describing: EthosTableViewController.self)])
        case .forWhoWeAre:
            break
        case .forWhatWeDo:
            break
        case .forsecondMovementSell:
            break
        case .forsecondMovementTrade:
            break
        case .forReapirAndServiceLocateUs:
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route, EthosKeys.value : String(describing: EthosStoreViewController.self)])
        }
    }
    
    func updateProgressView() {
        DispatchQueue.main.async {
            let multiplier = (self.collectionViewRepairAndService.contentOffset.x + self.collectionViewRepairAndService.frame.width)/self.collectionViewRepairAndService.contentSize.width
            self.viewProgress.progress = Float(multiplier)
        }
    }
    
}

extension RepairAndServiceCell : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.key {
        case .forWhoWeAre:
            return ArrayImage.count
        case .forWhatWeDo:
            return ArrayImage.count
        case .forsecondMovementSell:
            return ArrayImage.count
        case .forFromTheWatchGuide:
            return articleViewModel.articles.count
        case .forsecondMovementTrade:
            return ArrayImage.count
        case .forReapirAndServiceLocateUs:
            return ArrayImage.count
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch key {
        case .forFromTheWatchGuide:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ReadListCollectionViewCell.self), for: indexPath) as? ReadListCollectionViewCell {
                cell.article = self.articleViewModel.articles[indexPath.item]
                return cell
            }
            
        default :
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath) as? ImageCollectionViewCell {
                cell.mainImage.image = UIImage(named: ArrayImage[indexPath.item])
                cell.mainImage.contentMode = .scaleAspectFill
                return cell
            }
        }
        
        return UICollectionViewCell()
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.key == .forFromTheWatchGuide {
            guard let id = self.articleViewModel.articles[indexPath.item].id else { return
            }
            self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleDetail, EthosKeys.value : id])
        }
    }
    
}

extension RepairAndServiceCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let multiplier = (scrollView.contentOffset.x + scrollView.frame.width)/scrollView.contentSize.width
        self.viewProgress.progress = Float(multiplier)
    }
}

extension RepairAndServiceCell : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        DispatchQueue.main.async {
            self.collectionViewRepairAndService.reloadData()
        }
       
    }
    
    func errorInGettingArticles(error: String) {
        print(error)
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
       
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
    
    
}
