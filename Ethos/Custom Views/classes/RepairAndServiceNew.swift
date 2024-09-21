//
//  RepairAndServiceNew.swift
//  Ethos
//
//  Created by mac on 22/02/24.
//

import UIKit
import Mixpanel

class RepairAndServiceNew: UITableViewCell {
    
    @IBOutlet weak var constraintSpacingScedulePickupAndLblOR: NSLayoutConstraint!
    
    @IBOutlet weak var constraintSpacingLblOrAndSchedulePickup: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeightReqestACallback: NSLayoutConstraint!
    @IBOutlet weak var lblOR: UILabel!
    @IBOutlet weak var constraintHeightScheduleAPickup: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSpacingHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightHeadingView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSpacingLogo: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightLogo: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSpaceSubHeader: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingSubHeadingAndDescription: NSLayoutConstraint!
    @IBOutlet weak var constraintSpacingDescriptionAndCollection: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightImageCollection: NSLayoutConstraint!
    @IBOutlet weak var btnScheduleAPickup: UIButton!
    
    @IBOutlet weak var constraintSpacingProgressViewAndRequestCallBack: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightBtnRequestCallBack: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomRequestCallBack: NSLayoutConstraint!
    @IBOutlet weak var txtBtnKnowMore: UIButton!
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
    
    var key : RepairAndServiceNewKey = .forShopping {
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
        //self.constraintHeightImageCollection.constant = 350
        self.constraintSpaceProgressAndCollection.constant = 32
        self.constraintSpacingProgressViewAndRequestCallBack.constant = 32
        self.constraintHeightBtnRequestCallBack.constant = 40
        self.constraintBottomRequestCallBack.constant = 50
        self.constraintHeightBtnRequestCallBack.constant = 40
        self.constraintSpacingScedulePickupAndLblOR.constant = 24
        self.constraintSpacingLblOrAndSchedulePickup.constant = 24
        self.constraintHeightScheduleAPickup.constant = 40
        self.lblOR.isHidden = false
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
        
        self.btnScheduleAPickup.setAttributedTitleWithProperties(title: EthosConstants.ScheduleAPickup.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .white, backgroundColor: .black, kern: 1)
        
        
        
        self.btnRequestACallBack.backgroundColor = .clear
    }
    
    
    func setUI() {
        
        btnRequestACallBack.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        
        switch self.key {
        case .forShopping, .forPreowned :
            self.collectionViewRepairAndService.tag = 0
            self.constraintTopSpacingHeader.constant = 20
            self.constraintHeightHeadingView.constant = 50
            self.constraintTopSpacingLogo.constant = 32
            self.constraintHeightLogo.constant = 0
            self.constraintTopSpaceSubHeader.constant = 0
            self.constraintSpacingSubHeadingAndDescription.constant = 24
            self.constraintSpacingDescriptionAndCollection.constant = 32
            //self.constraintHeightImageCollection.constant = 350
            self.constraintSpaceProgressAndCollection.constant = 32
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 32
            self.constraintHeightBtnRequestCallBack.constant = 40
            self.constraintBottomRequestCallBack.constant = 50
            self.imageViewLogo.isHidden = true
            self.viewHeadeing.isHidden = false
            self.viewbtnHeadingDisclosure.isHidden = false
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = false
            self.btnRequestACallBack.isHidden = false
            self.viewProgress.isHidden = false
            self.collectionViewRepairAndService.isPagingEnabled = false
            self.viewMainContainer.backgroundColor = EthosColor.appBGColor
    
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.RepairAndService.uppercased(), font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: EthosConstants.repairAndServiceSubHeaderHome, font: EthosFont.Brother1816Medium(size: 14),lineHeightMultiple: 1.13, kern: 0.1)
            
            self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.repairAndServiceDescriptionHome, font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
            
            self.lblDescription.numberOfLines = 0
            self.ArrayImage = [EthosConstants.repairDemo3,EthosConstants.repairDemo4, EthosConstants.repairDemo5, EthosConstants.repairDemo6, EthosConstants.repairDemo7, EthosConstants.repairDemo8]
            
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.RequestCallBack.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
            self.btnScheduleAPickup.isHidden = true
            self.btnRequestACallBack.backgroundColor = .clear
            self.lblOR.isHidden = true
            self.constraintSpacingScedulePickupAndLblOR.constant = 0
            self.constraintSpacingLblOrAndSchedulePickup.constant = 0
            self.constraintHeightScheduleAPickup.constant = 0
            
            
        case .forDetails:
            self.collectionViewRepairAndService.tag = 1
            self.constraintTopSpacingHeader.constant = 20
            self.constraintHeightHeadingView.constant = 0
            self.constraintTopSpacingLogo.constant = 0
            self.constraintHeightLogo.constant = 50
            self.constraintTopSpaceSubHeader.constant = 40
            self.constraintSpacingSubHeadingAndDescription.constant = 24
            self.constraintSpacingDescriptionAndCollection.constant = 32
            //self.constraintHeightImageCollection.constant = 350
            self.constraintSpaceProgressAndCollection.constant = 0
            self.constraintSpacingProgressViewAndRequestCallBack.constant = 32
            self.constraintHeightBtnRequestCallBack.constant = 40
            self.constraintBottomRequestCallBack.constant = 20
            self.imageViewLogo.isHidden = false
            self.viewHeadeing.isHidden = true
            self.viewbtnHeadingDisclosure.isHidden = false
            self.lblHeading.isHidden = false
            self.lblSubHeading.isHidden = false
            self.lblDescription.isHidden = false
            self.collectionViewRepairAndService.isHidden = false
            self.btnRequestACallBack.isHidden = false
            self.viewProgress.isHidden = true
            self.collectionViewRepairAndService.isPagingEnabled = true
            self.viewMainContainer.backgroundColor = EthosColor.white
            
            self.lblHeading.setAttributedTitleWithProperties(title: EthosConstants.RepairAndService.uppercased(), font: EthosFont.Brother1816Medium(size: 12), lineHeightMultiple: 1.32, kern: 1)
            
            self.lblSubHeading.setAttributedTitleWithProperties(title: EthosConstants.repairAndServiceSubHeaderHome, font: EthosFont.Brother1816Medium(size: 14),lineHeightMultiple: 1.13, kern: 0.1)
            
            self.lblDescription.setAttributedTitleWithProperties(title: EthosConstants.repairAndServiceDescriptionHome, font: EthosFont.Brother1816Regular(size: 12), lineHeightMultiple: 1.13, kern: 0.1)
            
            self.lblDescription.numberOfLines = 0
            
            self.ArrayImage = [EthosConstants.repairDemo1]
            self.btnRequestACallBack.setAttributedTitleWithProperties(title: EthosConstants.RequestCallBack.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .black, backgroundColor: .clear, kern: 1)
            self.btnScheduleAPickup.setAttributedTitleWithProperties(title: EthosConstants.ScheduleAPickup.uppercased(), font: EthosFont.Brother1816Medium(size: 12), foregroundColor: .white, backgroundColor: .black, kern: 1)
            self.btnRequestACallBack.backgroundColor = .clear
            self.btnScheduleAPickup.isHidden = false
            self.lblOR.isHidden = false
            self.constraintSpacingScedulePickupAndLblOR.constant = 24
            self.constraintSpacingLblOrAndSchedulePickup.constant = 24
            self.constraintHeightScheduleAPickup.constant = 40
        }
        
        DispatchQueue.main.async {
            self.collectionViewRepairAndService.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.collectionViewRepairAndService.reloadData()
            }
        }
        
        self.updateProgressView()
    }
    
    @IBAction func btnKnowMoreDidTapped(_ sender: UIButton) {
        
        var screenName = ""
        
        if self.delegate is ShopViewController {
            screenName = "Shop"
        }
        
        if self.delegate is PreOwnedViewController {
            screenName = "Pre-Owned"
        }
        
        Mixpanel.mainInstance().trackWithLogs(event: "Repair and Service Know More Clicked", properties: [
            EthosConstants.Email : Userpreference.email,
            EthosConstants.UID : Userpreference.userID,
            EthosConstants.Gender : Userpreference.gender,
            EthosConstants.Registered : ((Userpreference.token == nil || Userpreference.token == "") ? EthosConstants.N : EthosConstants.Y),
            EthosConstants.Platform : EthosConstants.IOS,
            "Screen Location" : screenName
        ])
        
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.route, EthosKeys.value : String(describing: RepairAndServiceViewController.self)])
        
    }
    
    @IBAction func btnRequestCallBackDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.requestACallBack])
    }
    
    @IBAction func btnScheduleAPickupDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.scheduleAPickup])
    }
    
    func updateProgressView() {
        DispatchQueue.main.async {
            let multiplier = (self.collectionViewRepairAndService.contentOffset.x + self.collectionViewRepairAndService.frame.width)/self.collectionViewRepairAndService.contentSize.width
            self.viewProgress.progress = Float(multiplier)
        }
    }
    
}

extension RepairAndServiceNew : UICollectionViewDataSource , UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ArrayImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionViewCell.self), for: indexPath) as? ImageCollectionViewCell {
            cell.mainImage.image = UIImage(named: ArrayImage[indexPath.item])
            cell.mainImage.contentMode = .scaleAspectFill
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}

extension RepairAndServiceNew : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let multiplier = (scrollView.contentOffset.x + scrollView.frame.width)/scrollView.contentSize.width
        self.viewProgress.progress = Float(multiplier)
    }
}

extension RepairAndServiceNew : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        DispatchQueue.main.async {
            self.collectionViewRepairAndService.reloadData()
        }
       
    }
    
    func errorInGettingArticles(error: String) {
        print(error)
    }
    
    func startIndicator() {
        
       
    }
    
    func stopIndicator() {
       
    }
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
    
    
}
