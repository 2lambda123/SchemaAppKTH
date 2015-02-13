//
//  ContainerViewController.swift
//  SchemaAppKTH
//
//  Created by Kj Drougge on 2015-01-24.
//  Copyright (c) 2015 kj. All rights reserved.
//
import UIKit
import QuartzCore

enum SlideOutState{
    case Collapsed
    case LeftPanelExpanded
}

class ContainerViewController: UIViewController, SchemaViewControllerDelegate {
    
    var schemaNavigationController: UINavigationController!
    var schemaViewController: SchemaViewController!
    
    var leftViewController: LeftViewController?
    let schemaPanelExpandedOffset: CGFloat = 60
    
    var currentState: SlideOutState = .Collapsed {
        didSet {
            let shouldShowShadow = currentState != .Collapsed
            showShadowForSchemaViewController(shouldShowShadow)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        schemaViewController = UIStoryboard.viewController()
        schemaViewController.delegate = self
        
        schemaNavigationController = UINavigationController(rootViewController: schemaViewController)
        schemaNavigationController.navigationBar.translucent = true
        
        view.addSubview(schemaNavigationController.view)
        
        schemaNavigationController.didMoveToParentViewController(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        if leftViewController == nil {
            leftViewController = UIStoryboard.leftViewController()
            
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(leftPanelController: LeftViewController) {
        leftPanelController.delegate = schemaViewController
        
        view.insertSubview(leftPanelController.view, atIndex: 0)
        
        addChildViewController(leftPanelController)
        leftPanelController.didMoveToParentViewController(self)
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func animateLeftPanel(#shouldExpand: Bool) {
        if shouldExpand.boolValue {
            currentState = .LeftPanelExpanded
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(schemaNavigationController.view.frame) - schemaPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil
            }
        }
    }

    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.schemaNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForSchemaViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            schemaNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            schemaNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func viewController() -> SchemaViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("SchemaViewController") as? SchemaViewController
    }
    
    class func leftViewController() -> LeftViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? LeftViewController
    }
}