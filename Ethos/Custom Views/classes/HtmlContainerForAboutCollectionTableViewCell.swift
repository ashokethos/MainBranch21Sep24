//
//  HtmlContainerForAboutCollectionTableViewCell.swift
//  Ethos
//
//  Created by mac on 25/10/23.
//

import UIKit
import WebKit

class HtmlContainerForAboutCollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var webKitView: WKWebView!
    @IBOutlet weak var constraintHeightWebView: NSLayoutConstraint!
    @IBOutlet weak var imageViewProductGallery: UIImageView!
    
    var superTableView : UITableView?
    var index : IndexPath?
    var delegate : SuperViewDelegate?
    var activityViewModel : UserActivityViewModel = UserActivityViewModel()
    
    var data : (String? , String?)? {
        didSet {
            if let data = self.data {
                if let image = data.0 {
                    UIImage.loadFromURL(url: image) { image in
                        self.imageViewProductGallery.image = image
                        if let html = data.1 {
                            self.loadHtml(string: html)
                        }
                    }
                }
            }
        }
    }
    
    var htmlString : String? {
        didSet {
            self.loadHtml(string: htmlString ?? "")
        }
    }
    
    var urlString : String? {
        didSet {
            self.loadUrl(string: urlString ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        webKitView.navigationDelegate = self
        self.superTableView?.tag = 0
    }
    
    func loadUrl(string : String) {
        if let url = URL(string: string)  {
            let request = URLRequest(url: url)
            webKitView.load(request)
        }
    }
    
    func loadHtml(string : String) {
        let headString = "<head><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></head>"
        webKitView.scrollView.isScrollEnabled = false
        webKitView.loadHTMLString(headString + string, baseURL: URL(string: "https://www.ethoswatches.com/"))
    }
}

extension HtmlContainerForAboutCollectionTableViewCell : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.constraintHeightWebView.constant = webView.scrollView.contentSize.height
            self.webKitView.scrollView.contentSize.width = self.contentView.frame.width
            DispatchQueue.main.async {
                if self.superTableView?.tag == 0 {
                    self.superTableView?.reloadData()
                    self.superTableView?.tag = 1
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url {
                activityViewModel.getDataFromActivityUrl(url: url.absoluteString)
                decisionHandler(.cancel)
                return
            } else {
                print("Open it locally")
                decisionHandler(.allow)
                return
            }
        } else {
            print("not a user click")
            print(navigationAction.description)
            
            decisionHandler(.allow)
            return
        }
    }
    
}

extension HtmlContainerForAboutCollectionTableViewCell {
    
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
    
    
}

