
//
//  HelpAndSupportViewController.swift
//  Ethos
//
//  Created by mac on 07/08/23.
//

import UIKit
import Mixpanel
import SkeletonView

class HelpAndSupportViewController: UIViewController {
    
    @IBOutlet weak var viewQuestionTxtField: UIView!
    @IBOutlet weak var viewTopicsTxtField: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableViewHelpSupport: UITableView!
    @IBOutlet weak var btnBrowseByTopic: UIButton!
    @IBOutlet weak var tableViewTopic: UITableView!
    @IBOutlet weak var constraintHeightViewBrowseByTopic: NSLayoutConstraint!
    @IBOutlet weak var transParentView: UIView!
    @IBOutlet weak var textFieldBrowseByTopic: EthosTextField!
    @IBOutlet weak var textFieldSearch: EthosTextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var constraintBottomViewBrowseByTopic: NSLayoutConstraint!
    @IBOutlet weak var constraintTopTableview: NSLayoutConstraint!
    
    let ArrFixedTopics : [HelpCenterMainCategories] = [
        HelpCenterMainCategories(title: "Watch Service", subtitle: "Do you need to get your watch serviced? Click here if you have any questions", image: EthosConstants.watchService, categoryId: 9),
        HelpCenterMainCategories(title: "Contact Us", subtitle: "Get in touch with us. We’ll be happy to hear from you", image: EthosConstants.contactUs),
        HelpCenterMainCategories(title: "General Questions", subtitle: "Do you have any query? Let us help you with it", image: EthosConstants.generalQuestion, categoryId: 11)
    ]
  
    let viewModel = GetFAQViewModel()
    var reloadedOnce = false
    var isForPreOwned = false
    
    var selectedIndex = 0 {
        didSet {
            if self.state == .searchByTopic {
                if selectedIndex < self.viewModel.categories.count {
                    self.viewModel.getFAQList(category: self.viewModel.categories[selectedIndex].id ?? 0)
                }
            }
        }
    }
    
    var state : HelpCenterState = .fixedTopics {
        didSet {
            switch state {
            case .fixedTopics:
                self.showHideViewTopic(isHidden: true)
                
            case .searchByTopic:
                self.showHideViewTopic(isHidden: false)
                if self.viewModel.categories.count > selectedIndex {
                    self.textFieldBrowseByTopic.text = self.viewModel.categories[selectedIndex].name
                    self.viewModel.getFAQList(category: self.viewModel.categories[selectedIndex].id)
                }
                
            case .searchByKeyWords:
                self.showHideViewTopic(isHidden: true)
                self.viewModel.getFAQList()

            }
            
            self.tableViewTopic.reloadData()
            self.tableViewHelpSupport.reloadData()
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewHelpSupport.isSkeletonable = true
        self.tableViewHelpSupport.isUserInteractionDisabledWhenSkeletonIsActive = true
        setup()
    }
    
    func showHideViewTopic(isHidden: Bool) {
        switch self.state {
        case .fixedTopics:
            self.constraintTopTableview.constant = 0
            self.constraintHeightViewBrowseByTopic.constant = 0
            self.constraintBottomViewBrowseByTopic.constant = 0
        case .searchByTopic:
            self.constraintTopTableview.constant = 0
            self.constraintHeightViewBrowseByTopic.constant = 44
            self.constraintBottomViewBrowseByTopic.constant = 50
        case .searchByKeyWords:
            self.constraintTopTableview.constant = 0
            self.constraintHeightViewBrowseByTopic.constant = 0
            self.constraintBottomViewBrowseByTopic.constant = 0
        }
        
        self.viewTopicsTxtField.isHidden = isHidden
        self.view.layoutIfNeeded()
    }
    
    func setup() {
        self.viewModel.delegate = self
        self.tableViewHelpSupport.registerCell(className: HelpAndSupportCell.self)
        self.tableViewHelpSupport.registerCell(className: FAQCell.self)
        self.tableViewHelpSupport.registerCell(className: HeadingCell.self)
        self.tableViewHelpSupport.registerCell(className: SectionHeaderCell.self)
        self.tableViewHelpSupport.registerCell(className: TitleTableViewCell.self)
        self.showHideViewTopic(isHidden: true)
        self.tapGesture.cancelsTouchesInView = false
        self.tableViewTopic.registerCell(className: HeadingCell.self)
        self.addTapGestureToDissmissKeyBoard()
        self.setBorders()
        self.setTextFields()
        self.viewModel.getFAQCategories()
    }
    
    func setBorders() {
        self.viewQuestionTxtField.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
        self.viewTopicsTxtField.setBorder(borderWidth: 1, borderColor: .black, radius: 0)
    }
    
    func setTextFields() {
        self.textFieldSearch.delegate = self
        textFieldBrowseByTopic.initWithUIParameters(placeHolderText: EthosConstants.SelectTopic, underLineColor: .clear, textInset: 0)
        textFieldSearch.initWithUIParameters(placeHolderText: EthosConstants.TypeYourQuestonHere, underLineColor: .clear, textInset: 0)
    }
    
    @IBAction func didTapOntransparentView(_ sender: UITapGestureRecognizer) {
        self.transParentView.isHidden = true
        
    }
    
    @IBAction func btnSearchdidTapped(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: SearchViewController.self)) as? SearchViewController {
            vc.isForPreOwned = self.isForPreOwned
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func textFieldDidChangeValue(_ sender: EthosTextField) {
        if sender.text == "" {
            self.state = .fixedTopics
        } else {
            self.state = .searchByKeyWords
        }
    }
    
    @IBAction func btnBrowseByTopicDidTapped(_ sender : UIButton) {
        self.showHideViewTopic(isHidden: false)
        self.state = .searchByTopic
    }
    
    @IBAction func btnBackDidTapped(_ sender : UIButton) {
        switch state {
        case .fixedTopics:
            self.navigationController?.popViewController(animated: true)
        case .searchByTopic:
            if !self.indicator.isAnimating {
                self.state = .fixedTopics
            }
            
        case .searchByKeyWords:
            if !self.indicator.isAnimating {
                self.state = .fixedTopics
            }
        }
    }
    
    @IBAction func textFieldBrowseDidTapped(_ sender: EthosTextField) {
        
    }
    
    
    @IBAction func btnTextFieldBrowseDidTapped(_ sender: Any) {
        self.transParentView.isHidden = false
    }
    
}

extension HelpAndSupportViewController : SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        switch skeletonView {
        case tableViewTopic : return "HeadingCell"
            
        case tableViewHelpSupport :
            switch state {
            case .fixedTopics: return "HelpAndSupportCell"
            case .searchByTopic : return "FAQCell"
            case .searchByKeyWords: return "FAQCell"
            }
        default:
            return ""
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch skeletonView {
        case tableViewTopic :
            return viewModel.categories.count
        case tableViewHelpSupport :
            switch state {
            case .fixedTopics:
                return ArrFixedTopics.count
            case .searchByTopic:
                return 4
            case .searchByKeyWords:
                return 4
            }
        default:
            return 0
        }
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, skeletonCellForRowAt indexPath: IndexPath) -> UITableViewCell? {
        switch skeletonView {
        case tableViewTopic :
            if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                cell.contentView.showAnimatedGradientSkeleton()
                return cell
            }
            
        case tableViewHelpSupport :
            switch state {
            case .fixedTopics:
                if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: HelpAndSupportCell.self)) as? HelpAndSupportCell {
                    if indexPath.row < ArrFixedTopics.count {
                        cell.imageViewIcon.image = UIImage(named: ArrFixedTopics[safe : indexPath.row]?.image ?? "")
                        
                        cell.lblTitle.setAttributedTitleWithProperties(title: ArrFixedTopics[safe : indexPath.row]?.title.uppercased() ?? "", font: EthosFont.Brother1816Medium(size: 12), alignment: .center, kern: 1)
                        
                        
                        cell.lblDescription.text = ArrFixedTopics[safe : indexPath.row]?.subtitle
                    }
                    
                    if reloadedOnce == false {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                            self.reloadedOnce = true
                            self.tableViewHelpSupport.reloadData()
                        }
                    }
                    
                    return cell
                }
                
            case .searchByTopic :
                
                    if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: FAQCell.self)) as? FAQCell {
                        cell.contentView.showAnimatedGradientSkeleton()
                        return cell
                    }
              
            case .searchByKeyWords:
               
                if let cell = skeletonView.dequeueReusableCell(withIdentifier: String(describing: FAQCell.self)) as? FAQCell {
                    cell.contentView.showAnimatedGradientSkeleton()
                    return cell
                }
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    
}

extension HelpAndSupportViewController : UITableViewDataSource, UITableViewDelegate {
    
    @objc func imgViewIconBtnAction(sender: UIButton){
        print(sender.tag)
        switch state {
        case .fixedTopics:
            switch sender.tag {
            case 0,2, 3 :
                self.state = .searchByTopic
                if let selectedCategory = viewModel.categories.first(where: { category in
                    category.id == self.ArrFixedTopics[safe : sender.tag]?.categoryId
                }) {
                    self.selectedIndex = viewModel.categories.firstIndex(where: { category in
                        category.id == self.ArrFixedTopics[safe : sender.tag]?.categoryId
                    }) ?? 0
                    self.textFieldBrowseByTopic.text = selectedCategory.name
                }
                
                
                
            case 1 :
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ContactUsViewController.self)) as? ContactUsViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            default : break
                
            }
        case .searchByTopic:
            break
        case .searchByKeyWords:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        case tableViewTopic :
            return viewModel.categories.count
        case tableViewHelpSupport :
            switch state {
            case .fixedTopics:
                return ArrFixedTopics.count
            case .searchByTopic:
                return viewModel.faqList.count > 0 ? viewModel.faqList.count : 1
            case .searchByKeyWords:
                return viewModel.filteredFaqs.count > 0 ? viewModel.filteredFaqs.count : 1
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tableViewHelpSupport && self.state == .searchByTopic {
            return UITableView.automaticDimension
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tableViewHelpSupport && self.state == .searchByTopic {
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SectionHeaderCell.self)) as? SectionHeaderCell {
                if self.viewModel.categories.count > selectedIndex {
                    cell.setTitle(title: self.viewModel.categories[selectedIndex].name?.uppercased() ?? "")
                }
                return cell
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case tableViewTopic :
            if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HeadingCell.self)) as? HeadingCell {
                if indexPath.row < viewModel.categories.count {
                    cell.setHeading(
                        title: viewModel.categories[safe : indexPath.row]?.name ?? "",
                        textColor: (selectedIndex == indexPath.row) ? .white : .black,
                        backgroundColor: (selectedIndex == indexPath.row) ? .black : .white,
                        image: UIImage.imageWithName(name: (selectedIndex == indexPath.row) ? EthosConstants.tick : ""),
                        imageHeight: 20,
                        spacingTitleImage: 11,
                        leading: 11,
                        trailling: 11
                    )
                }
                
                return cell
            }
            
        case tableViewHelpSupport :
            switch state {
            case .fixedTopics:
                if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HelpAndSupportCell.self)) as? HelpAndSupportCell {
                    if indexPath.row < ArrFixedTopics.count {
                        cell.imageViewIcon.image = UIImage(named: ArrFixedTopics[safe : indexPath.row]?.image ?? "")
                        cell.imgViewIconBtn.tag = indexPath.row
                        cell.imgViewIconBtn.addTarget(self, action: #selector(imgViewIconBtnAction), for: .touchUpInside)
                        cell.lblTitle.setAttributedTitleWithProperties(title: ArrFixedTopics[safe : indexPath.row]?.title.uppercased() ?? "", font: EthosFont.Brother1816Medium(size: 12), alignment: .center, kern: 1)
                        
                        
                        cell.lblDescription.text = ArrFixedTopics[safe : indexPath.row]?.subtitle
                    }
                    
                    if reloadedOnce == false {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                            self.reloadedOnce = true
                            self.tableViewHelpSupport.reloadData()
                        }
                    }
                    
                    return cell
                }
                
            case .searchByTopic :
                if viewModel.faqList.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FAQCell.self)) as? FAQCell {
                        cell.contentView.hideSkeleton()
                        if indexPath.row < viewModel.faqList.count {
                            cell.faq = viewModel.faqList[safe : indexPath.row]
                        }
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TitleTableViewCell.self), for: indexPath) as? TitleTableViewCell {
                        cell.titleLabel.setAttributedTitleWithProperties(title: "\n\n\n\n\nSorry, No results were found\n\n\n\n\n".uppercased(), font: EthosFont.Brother1816Medium(size: 14))
                        cell.titleLabel.textAlignment = .center
                        return cell
                    }
                }
            case .searchByKeyWords:
                if viewModel.filteredFaqs.count > 0 {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FAQCell.self)) as? FAQCell {
                        cell.contentView.hideSkeleton()
                        if indexPath.row < viewModel.filteredFaqs.count {
                            cell.faq = viewModel.filteredFaqs[safe : indexPath.row]
                        }
                        return cell
                    }
                } else {
                    if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TitleTableViewCell.self), for: indexPath) as? TitleTableViewCell {
                        cell.titleLabel.setAttributedTitleWithProperties(title: "\n\n\n\n\nSorry, No results were found\n\n\n\n\n".uppercased(), font: EthosFont.Brother1816Medium(size: 14))
                        cell.titleLabel.textAlignment = .center
                        return cell
                    }
                }
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case tableViewTopic :
            self.selectedIndex = indexPath.row
            self.state = .searchByTopic
            
        case tableViewHelpSupport :
            switch state {
            case .fixedTopics:
                switch indexPath.row {
                case 0,2, 3 :
                    print("select index")
//                    self.state = .searchByTopic
//                    if let selectedCategory = viewModel.categories.first(where: { category in
//                        category.id == self.ArrFixedTopics[safe : indexPath.row]?.categoryId
//                    }) {
//                        self.selectedIndex = viewModel.categories.firstIndex(where: { category in
//                            category.id == self.ArrFixedTopics[safe : indexPath.row]?.categoryId
//                        }) ?? 0
//                        self.textFieldBrowseByTopic.text = selectedCategory.name
//                    }
                    
                    
                    
                case 1 :
                    print("select index")
//                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: String(describing: ContactUsViewController.self)) as? ContactUsViewController {
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
                    
                default : break
                    
                }
            case .searchByTopic:
                break
            case .searchByKeyWords:
                break
            }
        default : break
            
        }
    }
}

extension HelpAndSupportViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension HelpAndSupportViewController : GetFAQViewModelDelegate {
    func startIndicator() {
        DispatchQueue.main.async {
            self.tableViewHelpSupport.showAnimatedGradientSkeleton()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            
        }
    }
    
    func didGetFAQ() {
        DispatchQueue.main.async {
            
            self.tableViewHelpSupport.hideSkeleton()
            
            switch self.state {
            case .fixedTopics:
                break
            case .searchByTopic:
                self.tableViewHelpSupport.reloadData()
            case .searchByKeyWords:
                if self.textFieldSearch.text != "" {
                    var filteredFAQ = [FAQ]()
                    for faq in self.viewModel.faqList {
                        if let text = self.textFieldSearch.text?.lowercased(), faq.question?.lowercased().contains(text) ?? false  {
                            filteredFAQ.append(faq)
                        }
                        
                        if let text = self.textFieldSearch.text?.lowercased(), faq.answer?.lowercased().contains(text) ?? false  {
                            filteredFAQ.append(faq)
                        }
                    }
                    self.viewModel.filteredFaqs = filteredFAQ
                    self.tableViewHelpSupport.reloadData()
                }
            }
        }
    }
    
    func didGetFAQCategories() {
        DispatchQueue.main.async {
            self.tableViewTopic.reloadData()
        }
    }
}
