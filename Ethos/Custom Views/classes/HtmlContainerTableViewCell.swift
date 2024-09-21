//
//  HtmlContainerTableViewCell.swift
//  Ethos
//
//  Created by mac on 11/08/23.
//

import UIKit
import WebKit
import SafariServices

class HtmlContainerTableViewCell: UITableViewCell {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var webKitView: WKWebView!
    @IBOutlet weak var constraintHeightWebView: NSLayoutConstraint!
    
    var delegate : SuperViewDelegate?
    
    
    var activityViewModel : UserActivityViewModel = UserActivityViewModel()
    
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
    }
    
    func loadUrl(string : String) {
        if let url = URL(string: string)  {
            let request = URLRequest(url: url)
            webKitView.load(request)
        }
    }
    
    func unloadUrl() {
        if let url = URL(string:"about:blank") {
            self.webKitView.load(URLRequest(url: url))
        }
        
    }

    func loadHtml(string : String) {
        webKitView.scrollView.isScrollEnabled = false
        webKitView.loadHTMLString(string, baseURL: URL(string: "https://www.youtube.com/"))
    }
}

extension HtmlContainerTableViewCell : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //self.constraintHeightWebView.constant = webView.scrollView.contentSize.height
        self.webKitView.scrollView.contentSize.height = self.contentView.frame.height
        self.webKitView.scrollView.contentSize.width = self.contentView.frame.width
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

extension HtmlContainerTableViewCell {
  
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
