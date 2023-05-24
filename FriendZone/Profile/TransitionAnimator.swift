//
//  TransitionAnimator.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 24.05.2023.
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let presentationStartItem: UICollectionViewCell
    let isPresenting: Bool
    init(presentationStartItem: UICollectionViewCell, isPresenting: Bool) {
        self.presentationStartItem = presentationStartItem
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
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
        let startCellFrame = presentationStartItem.convert(presentationStartItem.bounds, to: containerView)
        let startCellCenter = CGPoint(x: startCellFrame.midX, y: startCellFrame.midY)
        
        containerView.addSubview(presentedView)
        presentedView.center = startCellCenter
        presentedView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            presentedView.transform = CGAffineTransform(scaleX: 2, y: 2)
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
        let startCellFrame = presentationStartItem.convert(presentationStartItem.bounds, to: containerView)
        let startCellCenter = CGPoint(x: startCellFrame.midX, y: startCellFrame.midY)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
//            dismissedView.backgroundColor = .clear
            dismissedView.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
            dismissedView.center = startCellCenter
            
        } completion: { finished in
            transitionContext.completeTransition(finished)
        }

    }
}
