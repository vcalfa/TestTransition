//
//  PageViewController.swift
//  TestTransition
//
//  Created by Vladimír Čalfa on 7/11/2016.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

typealias Direction = PageSwipeInteractionController.Direction

class PageViewController: UIViewController {
    
    let swipeInteractionController = PageSwipeInteractionController()
    
    private(set) weak var currentViewController: UIViewController?
    private weak var progressViewController: UIViewController?
    
    weak var pageDelegate: PageViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeInteractionController.wireTo(viewController: self)
    }
    
    func setCurrentViewController(currentViewController: UIViewController) {
        
    }
    
    func beginTransition(direction: Direction) {
        
        var toVC:UIViewController? = nil
            
        switch direction {
        case .after:
            toVC = pageDelegate?.pageViewController(self, viewControllerAfter: currentViewController)
    
        case .before:
            toVC = pageDelegate?.pageViewController(self, viewControllerBefore: currentViewController)
        default:
            break
        }
        
        transition(fromViewController: currentViewController, toViewController: toVC, direction: direction)
    }
    
    private func transition(fromViewController: UIViewController?, toViewController: UIViewController?, direction: Direction) {
        
        currentViewController?.willMove(toParentViewController: nil)
        
        if let to = toViewController {
            addChildViewController(to)
        }
        
        let animator = animatorFor(direction: direction)
        
        
        let transitionContext = PrivateTransitionContext(fromViewController: fromViewController, toViewController: toViewController, container: view, direction: direction)
        
        transitionContext.completionBlock = { didComplete in
            
        }
        
//        transitionContext.completionBlock = ^(BOOL didComplete) {
//            [fromViewController.view removeFromSuperview];
//            [fromViewController removeFromParentViewController];
//            [toViewController didMoveToParentViewController:self];
//        };
        
        
        animator.animateTransition(using: transitionContext)
        
    }
    
    
    private func animatorFor(direction: Direction) -> UIViewControllerAnimatedTransitioning {
        switch direction {
        case .after:
            return Animator(animation: .presenting)
        case .before:
            return Animator(animation: .dismiss)
        default:
            return Animator(animation: .presenting)
        }
    }
}

class PrivateTransitionContext : NSObject, UIViewControllerContextTransitioning {

    public var containerView: UIView
    
    
    // Most of the time this is YES. For custom transitions that use the new UIModalPresentationCustom
    // presentation type we will invoke the animateTransition: even though the transition should not be
    // animated. This allows the custom transition to add or remove subviews to the container view.
    
    private(set) var isAnimated: Bool
    
    
    private(set) var isInteractive: Bool  // This indicates whether the transition is currently interactive.
    
    
    private(set) var transitionWasCancelled: Bool
    
    
    private(set) var presentationStyle: UIModalPresentationStyle
    
    private(set) var viewControllers = [UITransitionContextViewControllerKey: UIViewController?]()
    
    init(fromViewController: UIViewController?, toViewController: UIViewController?, container: UIView, direction: Direction) {
        super.init()
        
        containerView = container
    
        isAnimated = true
        isInteractive = true
        transitionWasCancelled = false
        presentationStyle = .custom
    
        viewControllers = [
            UITransitionContextViewControllerKey.from: fromViewController,
            UITransitionContextViewControllerKey.to: toViewController,
        ]
    
        
        
    }
}


extension PageViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(animation: .presenting)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(animation: .dismiss)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil  //swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
}

protocol PageViewControllerDelegate: class {
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerBefore viewController: UIViewController?) -> UIViewController?
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerAfter viewController: UIViewController?) -> UIViewController?
    
    func pageViewController(_ pageViewController: PageViewController, shouldNavigateBefore viewController: UIViewController?) -> Bool
    
    func pageViewController(_ pageViewController: PageViewController, shouldNavigateAfter viewController: UIViewController?) -> Bool
}
