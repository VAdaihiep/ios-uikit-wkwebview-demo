//
//  ViewController.swift
//  ios-uikit-wkwebview-demo
//
//  Created by Kushida　Eiji on 2017/03/12.
//  Copyright © 2017年 Kushida　Eiji. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {
    
    var webView: WKWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var goBackButton: UIBarButtonItem!
    @IBOutlet weak var goForwordButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        loadFirstPage()
    }
    
    private func setup() {
        
        let conf = WKWebViewConfiguration()
        conf.setURLSchemeHandler(URLSchemeHandler(), forURLScheme: Constants.customURLSchemeA)
        
        webView = WKWebView(frame:CGRect.zero, configuration: conf)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsBackForwardNavigationGestures = true
        
        goBackButton.isEnabled = false
        goForwordButton.isEnabled = false
    }
    
    private func layout() {
        self.view.addSubview(webView)
        
        webView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20.0)
            .isActive = true
        webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -44.0)
            .isActive = true
        webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)
            .isActive = true
        webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0)
            .isActive = true
    }
    
    private func loadFirstPage() {
        if let htmlData = Bundle.main.path(forResource: "index", ofType: "html") {
            webView.load(URLRequest(url: URL(fileURLWithPath: htmlData)))
            self.view.addSubview(webView)
        } else {
            print("file not found")
        }
    }

    @IBAction func goBackButton(_ sender: UIBarButtonItem) {
        if webView.canGoBack { webView.goBack() }
    }
    
    @IBAction func goForwordButton(_ sender: UIBarButtonItem) {
        if webView.canGoForward { webView.goForward() }
    }
}

extension ViewController: WKNavigationDelegate {
    
    /// ページ読み込み完了時、呼ばれるメソッド
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        goBackButton.isEnabled = webView.canGoBack
        goForwordButton.isEnabled = webView.canGoForward
    }
    
    /// target="_blank"を開けるようにする
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        // target="_blank"の場合
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            if navigationAction.targetFrame == nil || !(navigationAction.targetFrame!.isMainFrame) {
                webView.load(NSURLRequest.init(url: url) as URLRequest)
                decisionHandler(.cancel)
                return
            }
        }
        
        let action = url.description
        if action.hasPrefix(Constants.customURLSchemeB) {
            URLMatcher.match(url).action()
            decisionHandler(.cancel)
            return
        }        
        decisionHandler(.allow)
    }
    
}
