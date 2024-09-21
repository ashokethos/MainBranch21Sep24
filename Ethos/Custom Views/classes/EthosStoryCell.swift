//
//  EthosStoryCell.swift
//  Ethos
//
//  Created by mac on 26/06/23.
//

import UIKit
import AVFoundation
import SkeletonView

class EthosStoryCell: UITableViewCell {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionViewStories: UICollectionView!
    
    var delegate : SuperViewDelegate?
    var viewModel = GetBannersViewModel()
    var superTableView : UITableView?
    var currentPlayingStoryIndex = 0
    var isforPreOwned = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionViewStories.registerCell(className: EthosStoryCollectionViewCell.self)
        self.viewModel.delegate = self
        self.collectionViewStories.dataSource = self
        self.collectionViewStories.delegate = self
        pageControl.preferredIndicatorImage = UIImage(named : "storyControlUnselected")
    }
    
    override func prepareForReuse() {
        self.isforPreOwned = false
        self.currentPlayingStoryIndex = 0
        self.pageControl.numberOfPages = 0
    }
    
    func updateStoryChangingUI() {
        pageControl.numberOfPages = viewModel.banners.count
        pageControl.currentPage = self.currentPlayingStoryIndex
    }
    
   
}

extension EthosStoryCell : GetBannersViewModelDelegate {
    func startIndicator() {
        self.indicator.startAnimating()
    }
    
    func stopIndicator() {
        self.indicator.stopAnimating()
    }
    
    func didGetBanners(banners: [Banner]) {
        indicator.stopAnimating()
        self.pageControl.numberOfPages = viewModel.banners.count
        self.collectionViewStories.reloadData()
       
    }
}

extension EthosStoryCell : SkeletonCollectionViewDataSource {
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
        return String(describing: EthosStoryCollectionViewCell.self)
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
        if let cell = skeletonView.dequeueReusableCell(withReuseIdentifier: String(describing: EthosStoryCollectionViewCell.self), for: indexPath) as? EthosStoryCollectionViewCell {
            cell.contentView.showAnimatedGradientSkeleton()
            return cell
        }
        return UICollectionViewCell()
    }
    
    
    
    
}

extension EthosStoryCell : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.banners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EthosStoryCollectionViewCell.self), for: indexPath) as? EthosStoryCollectionViewCell {
            cell.isForPreOwned = self.isforPreOwned
            cell.index = indexPath.item
            cell.indexPath = indexPath
            cell.superCollectionView = self.collectionViewStories
            cell.masterTableView = self.superTableView
            cell.superCell = self
            cell.delegate = self
            cell.totalDataCount = viewModel.banners.count
            cell.story = viewModel.banners[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.contentView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is EthosStoryCollectionViewCell {
            (cell as? EthosStoryCollectionViewCell)?.avPlayerLayer.player?.pause()
            (cell as? EthosStoryCollectionViewCell)?.btnPausePlay.isSelected = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.item
        if let cell = collectionView.cellForItem(at: indexPath) as? EthosStoryCollectionViewCell {
            cell.btnPausePlay.isSelected = true
            cell.avPlayerLayer.player?.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? EthosStoryCollectionViewCell {
            cell.didTapActionBtn(UIButton())
        }
    }
    
    func pauseVideo() {
        for indexPath in collectionViewStories.indexPathsForVisibleItems {
            if let cell = collectionViewStories.cellForItem(at: indexPath) as? EthosStoryCollectionViewCell {
                cell.btnPausePlay.isSelected = false
                cell.avPlayerLayer.player?.pause()
            }
        }
    }
}

extension EthosStoryCell : SuperViewDelegate {
    func updateView(info: [EthosKeys : Any?]?) {
        if let key = info?[EthosKeys.key] as? EthosKeys {
           if key == .changeStory {
                self.collectionViewStories.contentOffset = CGPoint(x: collectionViewStories.contentOffset.x + self.contentView.frame.width, y: 0)
            }
            
            if key == .changeToTop {
                if let index = info?[EthosKeys.currentIndex] as? Int {
                    if self.viewModel.banners.count-1 == index && viewModel.banners.count > 1 && self.collectionViewStories.indexPathsForVisibleItems.contains(where: { indexPath in
                        indexPath.row == index
                    }) {
                        self.collectionViewStories.reloadData()
                        self.collectionViewStories.contentOffset = .zero
                    }
                }
            }
            
            if key == .routeToArticleDetail || key == .routeToProductDetails || key == .routeToProducts {
                    self.delegate?.updateView(info: info)
            }
        }
    }
}
