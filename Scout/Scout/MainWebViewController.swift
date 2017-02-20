//
//  MainWebViewController.swift
//  Scout
//
//  Created by Brown, Rik on 2017-02-07.
//  Copyright © 2017 Scout. All rights reserved.
//

import UIKit
import Foundation

class MainWebViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    private let scoutRequester = ScoutRequester()
    
    @IBOutlet weak var webView: UIWebView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        webView.scrollView.delegate = self
    
        webView.scalesPageToFit = true
        webView.autoresizesSubviews = true
        
        // Load our web app
        if let path = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "Scout-UI") {
            webView.loadRequest(URLRequest(url: URL(fileURLWithPath: path)) )
        }
    
    }
    
    // disable zooming
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destNav = segue.destination
        
        destNav.preferredContentSize = CGSize(width: self.view.bounds.width, height: 100)
        
        let controller = destNav.popoverPresentationController!
        controller.sourceView = self.view
        controller.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        controller.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        controller.delegate = self
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
    
    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        
        if let url = request.url {
            print("Webview should start load " + url.absoluteString)
            
            // If URL should trigger voice recognition, then segue to the voice input view
            if (request.url!.absoluteString == "scout://talkToScout") {
                print("Voice!")
                self.performSegue(withIdentifier: "VoiceSegue", sender: self)
                return false
            }
            
            else if (request.url!.absoluteString == "scout://takeoff") {
                print("Takeoff!")
                scoutRequester.takeoff()
                return false
            }
        
        }
        
        return true
    }
    
}
