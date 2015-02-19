//
//  SchemaViewController.swift
//  SchemaAppKTH
//
//  Created by Kj Drougge on 2015-01-24.
//  Copyright (c) 2015 kj. All rights reserved.
//

import UIKit

protocol SchemaViewControllerDelegate{
    func toggleLeftPanel()
    func collapseSidePanels()
}

class SchemaViewController: UIViewController, LeftViewControllerDelegate, UIWebViewDelegate,UIScrollViewDelegate ,  UIGestureRecognizerDelegate {
    
    var delegate: SchemaViewControllerDelegate?
    var isLeftPanelOpen: Bool! = false
    
    @IBOutlet weak var labelContainer: UIView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var myLabel: UILabel!
  
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        start()
    }
    
    func start(){
        if Reachability.isConnectedToNetwork() {
            webView.delegate = self
            webView.hidden = true
            webView.scrollView.delegate = self
            
            myLabel.hidden = false
            labelContainer.layer.shadowOpacity = 0.8
            
            var tap = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
            tap.numberOfTapsRequired = 1
            tap.delegate = self
            
            webView.addGestureRecognizer(tap)
            
            refreshWithNewValues(NSUserDefaults.standardUserDefaults().objectForKey("SavedModule") as String)
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.hidesWhenStopped = true
            
            myLabel.text = "No connection"
        }
    }
    
    func handleTapGesture(tapGesture: UITapGestureRecognizer){
        //println("Tap?")
        if isLeftPanelOpen.boolValue {
            delegate?.toggleLeftPanel()
            isLeftPanelOpen = false
            webView.scrollView.scrollEnabled = true
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return nil
    }
   
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        webView.stringByEvaluatingJavaScriptFromString("var element = document.getElementById(\"showdaysbox\"); element.parentNode.removeChild(element);")
        webView.stringByEvaluatingJavaScriptFromString("var element = document.getElementById(\"searchbox\"); element.parentNode.removeChild(element);")
        webView.stringByEvaluatingJavaScriptFromString("var element = document.getElementById(\"message\"); element.parentNode.removeChild(element);")
        webView.stringByEvaluatingJavaScriptFromString("var element = document.getElementById(\"footer\"); element.parentNode.removeChild(element);")
        webView.stringByEvaluatingJavaScriptFromString("var element = document.getElementById(\"header\"); element.parentNode.removeChild(element);")
        webView.stringByEvaluatingJavaScriptFromString("var element = document.getElementById(\"kth-pmenu\"); element.parentNode.removeChild(element);")
        
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        
        webView.hidden = false
    }

    
    @IBAction func longPressDetected(sender: AnyObject){
        
        if sender.state == UIGestureRecognizerState.Began {
            println("Long press detected")
            
            var webViewCoordinates = sender.locationInView(self.webView)
            //println("Webview coordinates are: \(webViewCoordinates)")
            
            var locatorStr = "document.elementFromPoint(\(webViewCoordinates.x), \(webViewCoordinates.y - 60)).innerHTML"
            var result: String = ""
            result = webView.stringByEvaluatingJavaScriptFromString(locatorStr)!
            //println("Element found: \(result)")
            
            var str = result as String!
            
            let regex:NSRegularExpression  = NSRegularExpression(
                pattern: "<.*?>",
                options: NSRegularExpressionOptions.CaseInsensitive,
                error: nil)!
            
            let range = NSMakeRange(0, countElements(str))
            var htmlLessString: String = ""
            htmlLessString = regex.stringByReplacingMatchesInString(str,
                options: NSMatchingOptions.allZeros,
                range:range ,
                withTemplate: "\n")
            
            
            //println(htmlLessString)
            
            let alertController = UIAlertController(title: nil, message: htmlLessString, preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in // Do nothing
            }
            
            alertController.addAction(cancelAction)
            
            self.view.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func refreshWithNewValues(module: String){
        myLabel.text = module
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var today = NSDate()
        
        var daysToAdd = 14
        var timeInterval = 60 * 60 * 24 * daysToAdd
        var newDate = today.dateByAddingTimeInterval(NSTimeInterval(timeInterval))
        
        var todayStr = dateFormatter.stringFromDate(today)
        var newDateStr = dateFormatter.stringFromDate(newDate)
        
        webView.hidden = true
        
        activityIndicator.startAnimating()
        
        let requesturl = NSURL(string: "http://www.kth.se/schema/?showweekend=false&start=\(todayStr)&end=\(newDateStr)&freetext=&module=\(module)&outputview=oneweek")
        let request = NSURLRequest(URL: requesturl!)
        
        var url: NSURL! = NSURL(string: "https://www.kth.se/social/api/schema/v2/status")
        if url != nil {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: {
                (data, response, error) -> Void in
                if error == nil{
                    var urlContent = NSString(data: data, encoding: NSUTF8StringEncoding)
                    
                    if urlContent as String == "{\"status\": \"ok\"}"{
                        self.webView.loadRequest(request)
                    } else {
                        let alertController = UIAlertController(title: nil, message: "There was a problem getting the schedule.", preferredStyle: .Alert)
                        let retryAction = UIAlertAction(title: "Retry", style: .Cancel) { (action) in
                            self.refreshWithNewValues(NSUserDefaults.standardUserDefaults().objectForKey("SavedModule") as String)
                        }
                        
                        alertController.addAction(retryAction)
                        self.view.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            })
            task.resume()
        }
    }
    
    func scheduleSelected(schedule: String) {
        println("\(schedule)")
        var module = NSUserDefaults.standardUserDefaults().objectForKey("SavedModule") as String
        
        isLeftPanelOpen = false
        webView.scrollView.scrollEnabled = true
        if module != schedule{
            NSUserDefaults.standardUserDefaults().setObject(schedule, forKey: "SavedModule")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if Reachability.isConnectedToNetwork() {
                refreshWithNewValues(schedule)
            } else {
                println("no internet 3")
            }
        }
        delegate?.collapseSidePanels()
    }
    
    @IBAction func refresh_clicked(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            refreshWithNewValues(NSUserDefaults.standardUserDefaults().objectForKey("SavedModule") as String)
        } else {
            
            println("no internet 2 ")
            
            
            let alertController = UIAlertController(title: nil, message: "There was a problem with the connection.", preferredStyle: .Alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in // Do nothing
            }
            
            alertController.addAction(cancelAction)
            
            self.view.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func settings_clicked(sender: AnyObject) {
        if isLeftPanelOpen.boolValue {
            isLeftPanelOpen = false
            webView.scrollView.scrollEnabled = true
        } else {
            isLeftPanelOpen = true
            webView.scrollView.scrollEnabled = false
        }
        
        delegate?.toggleLeftPanel()
    }
}