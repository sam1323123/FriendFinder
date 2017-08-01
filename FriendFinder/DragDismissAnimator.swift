//
//  DragDismissAnimator.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/31/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class DragDismissAnimator: NSObject {

}

extension DragDismissAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let destVC = transitionContext.viewController(forKey: .to),
            let srcVC = transitionContext.viewController(forKey: .from)
            else {
                return
        }
        let containerView = transitionContext.containerView
        containerView.insertSubview(destVC.view, belowSubview: srcVC.view)
        let topRight: CGPoint = CGPoint(x: UIScreen.main.bounds.width, y: 0.0)
        let finalFrame = CGRect(origin: topRight, size: UIScreen.main.bounds.size)
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {srcVC.view.frame = finalFrame},
                       completion:{ _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
        
    }
}
