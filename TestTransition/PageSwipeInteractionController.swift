//
//  SwipeInteractionController.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

class PageSwipeInteractionController : UIPercentDrivenInteractiveTransition {
    
    enum Direction {
        case before
        case after
        case unknown
    }
    
    var interactionInProgress = false
    var direction: Direction = .unknown
    
    var swipeLength: CGFloat = 175.0
    
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
        var progress = translation.x / swipeLength
        
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

            shouldCompleteTransition = progress > 0.5
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
            return pageViewController.pageDelegate?.pageViewController(pageViewController, shouldNavigateBefore: pageViewController.currentViewController) ?? true
        case .after:
            return pageViewController.pageDelegate?.pageViewController(pageViewController, shouldNavigateAfter: pageViewController.currentViewController) ?? true
        default:
            return false
        }
    }
    
    func directionFor(translation:CGPoint) -> Direction {

        switch translation {
            case let t where t.x >= 0:
                return .after
            case let t where t.x < 0:
                return .before
            default:
                return .unknown
        }
    }
}
