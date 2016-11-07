//
//  Animator.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit


class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    enum AType {
        case presenting
        case dismiss
    }
    
    private let animation: AType
    
    init(animation: AType) {
        self.animation = animation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.45
    }
    
    private func originFrame(rect: CGRect) -> CGRect {
        return rect.applying(CGAffineTransform.init(translationX: rect.width*(1.0/5.0), y: 0))
    }
    
    private func finalFromFrame(rect: CGRect) -> CGRect {
        return rect.applying(CGAffineTransform.init(translationX: -(rect.width + 4.0), y: 0))
    }
    
    private func setShadow(viewController:UIViewController) {
        viewController.view.layer.shadowRadius = 4.0
        viewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewController.view.layer.shadowOpacity = 0.5
        viewController.view.layer.shadowPath = CGPath(rect: viewController.view.bounds, transform: nil)
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        

        let finalFrame : CGRect
        let fFromFrame : CGRect
        
        switch animation {
        case .presenting:
        
            let initialFrame = originFrame(rect: fromVC.view.frame)
            toVC.view.frame = initialFrame
            
            finalFrame = transitionContext.finalFrame(for: toVC)
            fFromFrame = finalFromFrame(rect: fromVC.view.frame)
            
            setShadow(viewController: fromVC)
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            
        case .dismiss:
            
            let initialFrame = finalFromFrame(rect: fromVC.view.frame)
            toVC.view.frame = initialFrame
            
            finalFrame = transitionContext.finalFrame(for: toVC)
            fFromFrame = originFrame(rect: fromVC.view.frame)
            
            setShadow(viewController: toVC)
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            break
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            fromVC.view.frame = fFromFrame
            toVC.view.frame = finalFrame
            }, completion: { _ in
                // 5
                fromVC.view.layer.shadowRadius = 0
                fromVC.view.layer.shadowOpacity = 0
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
    }
}
