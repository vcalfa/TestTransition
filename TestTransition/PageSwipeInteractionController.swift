//
//  SwipeInteractionController.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

class PageSwipeInteractionController : PercentDrivenInteractiveTransition {
    
    enum Direction {
        case before
        case after
        case unknown
    }
    
    var interactionInProgress = false
    var direction: Direction = .unknown
    
    var swipeLength: CGFloat = 175.0
    var swipeBoost: CGFloat = 1.0
    
    private var shouldCompleteTransition = false
    private weak var pageViewController: PageViewController!
    
    func wireTo(viewController: PageViewController!) {
        pageViewController = viewController
        prepareGestureRecognizerInView(view: pageViewController.view)
    }
    
    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(SwipeInteractionController.handleGesture(gestureRecognizer:)))
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view!.superview!)
        var progress = translation.x / (CGFloat(gestureRecognizer.view!.superview!.frame.width) * swipeBoost )
        progress = progress < 0 ? -1*progress : progress
        
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
            
        case .began:
            
            direction = directionFor(translation: translation)
            print("Begin at direction: \(direction)")
            
            //guard let viewController = viewControllerFor(direction: direction) else {
            //    cancelTransition()
            //    return
            //}
            
            guard shouldNavigate(direction: direction) else {
                cancelTransition()
                return
            }
            
            interactionInProgress = true
            pageViewController.beginTransition(direction: direction)
            
            //viewController.transitioningDelegate = pageViewController
            //pageViewController.present(viewController, animated: true, completion: nil)
            
        case .changed:
            //print("Velocity: \(velocity)")
            shouldCompleteTransition = progress > 0.45 || abs(velocity.x) > 600
            update(progress)
            
        case .cancelled:

            interactionInProgress = false
            direction = .unknown
            cancel()
            
        case .ended:

            interactionInProgress = false
            direction = .unknown
            
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
            
        default:
            print("Unsupported")
        }
    }
    
    func cancelTransition() {
        interactionInProgress = false
        direction = .unknown
        cancel()
    }
    
    func viewControllerFor(direction:Direction) -> UIViewController? {
        
        switch direction {
        case .before:
            return pageViewController.pageDelegate?.pageViewController(pageViewController, viewControllerBefore: pageViewController.currentViewController)
        case .after:
            return pageViewController.pageDelegate?.pageViewController(pageViewController, viewControllerAfter: pageViewController.currentViewController)
        default:
            return nil
        }
    }
    
    func shouldNavigate(direction:Direction) -> Bool {
        
        switch direction {
        case .before:
            return pageViewController.pageDelegate?.pageViewController?(pageViewController, shouldNavigateBefore: pageViewController.currentViewController) ?? true
        case .after:
            return pageViewController.pageDelegate?.pageViewController?(pageViewController, shouldNavigateAfter: pageViewController.currentViewController) ?? true
        default:
            return false
        }
    }
    
    func directionFor(translation:CGPoint) -> Direction {

        switch translation {
            case let t where t.x > 0:
                return .before
            case let t where t.x <= 0:
                return .after
            default:
                return .unknown
        }
    }
}
