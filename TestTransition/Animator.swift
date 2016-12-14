//
//  Animator.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit


class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animation: Direction
    weak var transitionContext: UIViewControllerContextTransitioning?
    
    init(animation: Direction) {
        self.animation = animation
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    private func originToFrame(rect: CGRect, direction:Direction) -> CGRect {
        switch direction {
        case .before:
            return rect.applying(CGAffineTransform.init(translationX: -(rect.width + 4.0), y: 0))
        case .after:
            return rect.applying(CGAffineTransform.init(translationX: rect.width*(1.0/4.0), y: 0))
        default:
            return CGRect.zero
        }
    }
    
    private func finalFromFrame(rect: CGRect, direction:Direction) -> CGRect {
        switch direction {
        case .before:
            return rect.applying(CGAffineTransform.init(translationX: rect.width*(1.0/4.0), y: 0))
        case .after:
            return rect.applying(CGAffineTransform.init(translationX: -(rect.width + 4.0), y: 0))
        default:
            return CGRect.zero
        }
    }
    
    private(set) var originToFrame: CGRect = .zero
    private(set) var originFromFrame: CGRect = .zero
    
    
    private func setShadow(viewController:UIViewController)
    {
        viewController.view.layer.shadowRadius = 4.0
        viewController.view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        viewController.view.layer.shadowOpacity = 0.5
        viewController.view.layer.shadowPath = CGPath(rect: viewController.view.bounds, transform: nil)
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        self.transitionContext = transitionContext
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        var finalFrameTo : CGRect = .zero
        var finalFrameFrom : CGRect = .zero
        
        switch animation {
        case .before:

            originToFrame = originToFrame(rect: containerView.frame, direction: animation)
            toVC.view.frame = originToFrame
            
            originFromFrame = containerView.frame
            finalFrameTo = originFromFrame
            finalFrameFrom = finalFromFrame(rect: containerView.frame, direction: animation)
            
            setShadow(viewController: toVC)
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)

        case .after:
            
            originToFrame = originToFrame(rect: containerView.frame, direction: animation)
            toVC.view.frame = originToFrame
            
            originFromFrame = containerView.frame
            finalFrameTo = originFromFrame
            finalFrameFrom = finalFromFrame(rect: containerView.frame, direction: animation)
            
            setShadow(viewController: fromVC)
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            
        case .unknown:
            break
        }
        
        let duration = transitionDuration(using: transitionContext)
        
        
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            fromVC.view.frame = finalFrameFrom
            toVC.view.frame = finalFrameTo
        }, completion: { _ in
            
            fromVC.view.layer.shadowRadius = 0
            fromVC.view.layer.shadowOpacity = 0
            toVC.view.layer.shadowRadius = 0
            toVC.view.layer.shadowOpacity = 0
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func animationEnded(_ transitionCompleted: Bool)
    {
    
//        if !transitionCompleted {
//        
//            guard let fromVC = transitionContext?.viewController(forKey: .from),
//                let toVC = transitionContext?.viewController(forKey: .to) else {
//                    return
//            }
//            
//            UIView.animate(withDuration: 0, delay: 0, options: [.beginFromCurrentState], animations: {
//                fromVC.view.frame = self.originFromFrame
//                toVC.view.frame = self.originToFrame
//            }, completion: nil)
//        }
    }
}

