//
//  AvatarYtansitionAnimator.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 30.05.2023.
//

import UIKit

class AvatarTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let presentationStartView: UIImageView
    let isPresenting: Bool
    init(presentationStartView: UIImageView, isPresenting: Bool) {
        self.presentationStartView = presentationStartView
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            present(using: transitionContext)
        } else {
            dismiss(using: transitionContext)
        }
    }
    
    func present(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
       guard let presentedViewController = transitionContext.viewController(forKey: .to),
             let presentedView = transitionContext.view(forKey: .to) else {
           transitionContext.completeTransition(false)
           return
       }
        let finalFrame = transitionContext.finalFrame(for: presentedViewController)
        let startCellFrame = presentationStartView.convert(presentationStartView.bounds, to: containerView)
        let startCellCenter = CGPoint(x: startCellFrame.midX, y: startCellFrame.midY)
        
        containerView.addSubview(presentedView)
        presentedView.center = startCellCenter
        presentedView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            presentedView.transform = CGAffineTransform(scaleX: 1, y: 1)
            presentedView.frame = finalFrame
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }
    }
    
    func dismiss(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
       guard let dismissedView = transitionContext.view(forKey: .from),
             let presentedView = transitionContext.view(forKey: .to) else {
           transitionContext.completeTransition(false)
           return
       }
        containerView.insertSubview(presentedView, belowSubview: dismissedView)
        let startCellFrame = presentationStartView.convert(presentationStartView.bounds, to: containerView)
        let startCellCenter = CGPoint(x: startCellFrame.midX, y: startCellFrame.midY)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            dismissedView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            dismissedView.center = startCellCenter
            
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }

    }
}

