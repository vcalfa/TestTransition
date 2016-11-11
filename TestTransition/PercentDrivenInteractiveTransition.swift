//
//  PercentDrivenInteractiveTransition.swift
//  TestTransition
//
//  Created by Vladimír Čalfa on 9/11/2016.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit


class PercentDrivenInteractiveTransition : NSObject , UIViewControllerInteractiveTransitioning {
    
    var duration: CGFloat {
        get {
            return CGFloat(animator?.transitionDuration(using: transitionContext) ?? 0)
        }
    }
    
    private(set) var percentComplete: CGFloat = 0.0 {
        didSet {
            setTimeOffset(TimeInterval(percentComplete*duration))
            transitionContext.updateInteractiveTransition(percentComplete)
        }
    }
    
    weak var animator: UIViewControllerAnimatedTransitioning?
    
    var completionSpeed: CGFloat = 1.0
    
    private(set) var animationCurve: UIViewAnimationCurve = .linear
    private(set) var completionCurve: UIViewAnimationCurve = .easeInOut

    
    private var transitionContext: UIViewControllerContextTransitioning!
    private(set) var isInteracting: Bool = false
    private var displayLink: CADisplayLink?
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        if let withAnimator = transitionContext as? PrivateTransitionContextWithAnimator {
            animator = withAnimator.animator
        }
        
        self.transitionContext?.containerView.layer.speed = 0
        isInteracting = true
        animator?.animateTransition(using: self.transitionContext)
    }
    
    func update(_ percentComplete: CGFloat) {
        self.percentComplete = CGFloat(fmaxf(fminf(Float(percentComplete), 1.0), 0.0))
    }
    
    func cancel() {
        isInteracting = false

        if let context = transitionContext {
            context.cancelInteractiveTransition()
            completeTransition()
        }
    }
    
    func finish() {
        isInteracting = false
        transitionContext.finishInteractiveTransition()
        completeTransition()
    }
    
    //MARK: private functions
    private func completeTransition() {
        displayLink = CADisplayLink(target:self, selector: #selector(tickAnimation))
        displayLink!.add(to: RunLoop.main , forMode: .commonModes)
    }
    
    private func setTimeOffset(_ timeOffset:TimeInterval) {
        transitionContext.containerView.layer.timeOffset = timeOffset
    }
    
    @objc private func tickAnimation() {
        
        guard let displayLink = displayLink else {
            return
        }
        
        var timeOffset: TimeInterval = self.timeOffset()

        let tick: TimeInterval = displayLink.duration*Double(completionSpeed)
        timeOffset += transitionContext.transitionWasCancelled ? -tick : tick
    
        if timeOffset < 0 || timeOffset > Double(duration) {
            transitionFinished()
        } else {
           setTimeOffset(timeOffset)
        }
    }
    
    private func timeOffset() -> TimeInterval {
        return transitionContext.containerView.layer.timeOffset
    }
    
    private func transitionFinished() {
        
        displayLink?.invalidate()
        
        let layer = transitionContext.containerView.layer
        layer.speed = 1
        
        if !transitionContext.transitionWasCancelled {
            let pausedTime: CFTimeInterval = layer.timeOffset
            layer.timeOffset = 0.0
            layer.beginTime = 0.0 // Need to reset to 0 to avoid flickering :S
            
            let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from:nil) - pausedTime
            layer.beginTime = timeSincePause
        }
        else {
            UIView.animate(withDuration: 0, delay: 0, options: [.beginFromCurrentState], animations: {
                if let fromVC = self.transitionContext.viewController(forKey: .from) {
                    fromVC.view.frame = self.transitionContext.initialFrame(for: fromVC)
                }
                if let toVC = self.transitionContext.viewController(forKey: .to) {
                    toVC.view.frame = self.transitionContext.initialFrame(for: toVC)
                }
            }, completion: nil)
        }
    }
}
