//  ConnectInstagramViewController.swift
//  Shishka
//
//  Created by Daria Tsenter on 10/18/18.
//  Copyright © 2018 DariaTsenter. All rights reserved.
//
import UIKit
import WebKit

class ConnectInstagramViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    
    override func loadView() {
        //configure web view
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        self.view = webView
    }
    
    override func viewDidLoad() {
        //this clears the user from the cache for testing instagram connection
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                if record.displayName.contains("instagram") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
                        print("Deleted: " + record.displayName);
                    })
                }
            }
        }
        
        super.viewDidLoad()
        
        let stringURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [API.INSTAGRAM_AUTHURL, API.INSTAGRAM_CLIENT_ID, API.INSTAGRAM_REDIRECT_URI, API.INSTAGRAM_SCOPE])
        let myURL = URL(string: stringURL)
        let myRequest = URLRequest(url: myURL!)
        print("request \(myRequest)")
        webView.load(myRequest)
        // Do any additional setup after loading the view.
    }
}

extension ConnectInstagramViewController {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //if everything is ok with the request, print it and pass it for other controllers to use
        if (handleInstagramRequest(request: navigationAction.request)){
            //dismiss controller
            _ = navigationController?.popViewController(animated: true)
            let previousViewController = self.navigationController?.viewControllers.last as! RegisterViewController
            //set instagram button to connected
            previousViewController.instagramConnected = true
            decisionHandler(.cancel)
        }else {
            decisionHandler(.allow)
        }
    }
    
    func handleInstagramRequest(request: URLRequest) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.contains("access_token"){
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            let authToken = String(requestURLString[range.upperBound...])
            print("Auth Token from ConnectInstagramController is \(authToken)")
            UserDefaults.standard.set(authToken, forKey: "instagramAccessToken")
            return true
        } else {
            return false
        }
    }
}

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
