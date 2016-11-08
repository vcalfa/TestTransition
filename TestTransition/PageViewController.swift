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
        
        
        self.currentViewController?.willMove(toParentViewController: nil)
        currentViewController.view.frame = view.bounds
        addChildViewController(currentViewController)

        self.currentViewController?.view.removeFromSuperview()
        self.currentViewController?.removeFromParentViewController()
        currentViewController.didMove(toParentViewController: self)
        
        self.currentViewController = currentViewController
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
        
        let transitionContext = PrivateTransitionContext(fromViewController: fromViewController, toViewController: toViewController, container: view, direction: direction)
        
        transitionContext.completionBlock = { didComplete in
            fromViewController?.view.removeFromSuperview()
            fromViewController?.removeFromParentViewController()
            toViewController?.didMove(toParentViewController: self)
            
            self.currentViewController = toViewController
        }

        let animator = animatorFor(direction: direction)
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
    
    private(set) var isAnimated: Bool = true
    
    private(set) var targetTransform: CGAffineTransform = CGAffineTransform.identity
    
    private(set) var isInteractive: Bool = false // This indicates whether the transition is currently interactive.
    
    
    private(set) var transitionWasCancelled: Bool = false
    
    
    private(set) var presentationStyle: UIModalPresentationStyle = .custom
    
    private(set) var privateViewControllers = [UITransitionContextViewControllerKey: UIViewController?]()
    
    private(set) var direction: Direction
    
    var completionBlock: ((Bool) -> Void)?
    
    init(fromViewController: UIViewController?, toViewController: UIViewController?, container: UIView, direction: Direction) {
        
        containerView = container
        self.direction = direction
        
        super.init()
        
        privateViewControllers = [
            UITransitionContextViewControllerKey.from: fromViewController,
            UITransitionContextViewControllerKey.to: toViewController,
        ]
    }
    

    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return privateViewControllers[key] ?? nil
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
            case UITransitionContextViewKey.from:
                return privateViewControllers[UITransitionContextViewControllerKey.from]??.view
            case UITransitionContextViewKey.to:
                return privateViewControllers[UITransitionContextViewControllerKey.to]??.view
            default:
                return nil
        }
    }
    
    func completeTransition(_ didComplete:Bool) -> Void {
        completionBlock?(didComplete)
    }
    
    
    func initialFrame(for vc: UIViewController) -> CGRect {
        return containerView.bounds
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        return containerView.bounds
    }
    
    
    func pauseInteractiveTransition() {
        
    }
    
    // Supress warnings by implementing empty interaction methods for the remainder of the protocol:
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        
    }
    
    func finishInteractiveTransition() {
        
    }
    
    func cancelInteractiveTransition() {
        
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

@objc protocol PageViewControllerDelegate: class {
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerBefore viewController: UIViewController?) -> UIViewController?
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerAfter viewController: UIViewController?) -> UIViewController?
    
    @objc optional func pageViewController(_ pageViewController: PageViewController, shouldNavigateBefore viewController: UIViewController?) -> Bool
    
    @objc optional func pageViewController(_ pageViewController: PageViewController, shouldNavigateAfter viewController: UIViewController?) -> Bool
}
