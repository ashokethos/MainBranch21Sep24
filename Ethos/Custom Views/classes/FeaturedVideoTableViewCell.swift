//
//  FeaturedVideoTableViewCell.swift
//  Ethos
//
//  Created by mac on 26/06/23.
//

import UIKit
import Mixpanel
import SkeletonView

class FeaturedVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionViewFeaturedVideos: UICollectionView!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var delegate : SuperViewDelegate?
    let viewModel = GetArticlesViewModel()
  
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDelegates()
    }
    
    func setupDelegates() {
        collectionViewFeaturedVideos.registerCell(className: FeaturedVideoCollectionViewCell.self)
        collectionViewFeaturedVideos.dataSource = self
        collectionViewFeaturedVideos.delegate = self
        self.viewModel.delegate = self
        self.pageControl.numberOfPages = viewModel.articles.count
        pageControl.preferredIndicatorImage = UIImage(named : "storyControlUnselected")
    }
    
    override func prepareForReuse() {
        self.contentView.hideSkeleton()
        self.collectionViewFeaturedVideos.hideSkeleton()
    }
    
    @IBAction func btnViewAllDidTapped(_ sender: UIButton) {
        self.delegate?.updateView(info: [EthosKeys.key : EthosKeys.routeToArticleList, EthosKeys.value : HorizontalCollectionKey.forArticle, EthosKeys.category : ArticleCategory.featuredVideo])
    }
    
    func pauseVideo() {
        for indexPath in self.collectionViewFeaturedVideos.indexPathsForVisibleItems {
            if let cell = collectionViewFeaturedVideos.cellForItem(at: indexPath) as? FeaturedVideoCollectionViewCell {
                cell.playerLayer.player?.pause()
                cell.btnPlayPause.isSelected = false
                cell.playerLayer.isHidden = true
            }
        }
    }
}


extension FeaturedVideoTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: FeaturedVideoCollectionViewCell.self), for: indexPath) as? FeaturedVideoCollectionViewCell {
            cell.index = indexPath
            cell.article =  viewModel.articles[safe : indexPath.row]
            cell.delegate = self.delegate
            return cell
        }
        
        return UICollectionViewCell()
        
    }
   
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.item
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is FeaturedVideoCollectionViewCell {
            (cell as? FeaturedVideoCollectionViewCell)?.playerLayer.player?.pause()
            (cell as? FeaturedVideoCollectionViewCell)?.btnPlayPause.isSelected = false
            (cell as? FeaturedVideoCollectionViewCell)?.playerLayer.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension FeaturedVideoTableViewCell : SkeletonCollectionViewDataSource, SkeletonCollectionViewDelegate {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        
        return String(describing: FeaturedVideoCollectionViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: FeaturedVideoCollectionViewCell.self), for: indexPath) as? FeaturedVideoCollectionViewCell {
            cell.lblTitle.skeletonTextNumberOfLines = 3
            cell.lblCategory.skeletonTextNumberOfLines = 1
            cell.lblCreationDate.skeletonTextNumberOfLines = 1
            
            cell.lblTitle.skeletonLineSpacing = 10
            cell.lblCategory.skeletonLineSpacing = 10
            cell.lblCreationDate.skeletonLineSpacing = 10
            
            cell.lblTitle.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
            cell.lblCategory.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
            cell.lblCreationDate.skeletonTextLineHeight = SkeletonTextLineHeight.fixed(10)
            return cell
        }
        return nil
    }
    
    
}

extension FeaturedVideoTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}

extension FeaturedVideoTableViewCell : GetArticlesViewModelDelegate {
    func didGetArticles(category: String, offset: Int, limit: Int, articleModel: GetArticles, site: Site, searchString: String, featuredVideo: Bool, watchGuide: Bool) {
        self.pageControl.numberOfPages = viewModel.articles.count
        self.collectionViewFeaturedVideos.reloadData()
    }
    
    func errorInGettingArticles(error: String) {
        
    }
    
    func startIndicator() {
        DispatchQueue.main.async {
            self.indicator.startAnimating()
        }
    }
    
    func stopIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }}
    
    func startFooterIndicator() {
        
    }
    
    func stopFooterIndicator() {
        
    }
}
