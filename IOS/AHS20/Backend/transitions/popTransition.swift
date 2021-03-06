//
//  popTransition.swift
//  AHS20
//
//  Created by Richard Wei on 12/10/20.
//  Copyright © 2020 AHS. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

open class popTransition: NSObject, UIViewControllerAnimatedTransitioning{
    
    private let duration: TimeInterval;
    
    public init(duration: TimeInterval = 0.25) {
        self.duration = duration;
        super.init();
    }
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration;
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            return;
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred();
        

        let duration = self.transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: {
            fromViewController.view.frame = CGRect(x: UIScreen.main.bounds.width, y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height);
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    static public func handlePan(_ gestureRecognizer: UIPanGestureRecognizer, fromViewController: UIViewController){
        if (gestureRecognizer.state == .began || gestureRecognizer.state == .changed){
            let translation = gestureRecognizer.translation(in: fromViewController.view);
            
            fromViewController.view.frame = CGRect(x: max(fromViewController.view.frame.minX + translation.x, 0), y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height);
            
            gestureRecognizer.setTranslation(.zero, in: fromViewController.view);
        }
        else if (gestureRecognizer.state == .ended){
            let thresholdPercent : CGFloat = 0.25; // if minx > thresholdPercent * uiscreen.main.bounds.width
            if (fromViewController.view.frame.minX >= thresholdPercent * UIScreen.main.bounds.width){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "savedpage_reloadSavedArticles"), object: nil, userInfo: nil);
                fromViewController.dismiss(animated: true);
            }
            else{
                UIView.animate(withDuration: 0.2, animations: {
                    fromViewController.view.frame = CGRect(x: 0, y: 0, width: fromViewController.view.frame.width, height: fromViewController.view.frame.height);
                });
            }
        }
    }
}
