//
//  SwipeInteractionController.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

class SwipeInteractionController : UIPercentDrivenInteractiveTransition {

    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!

    enum Interaction {
        case presenting
        case dismiss
    }
    
    let interaction: Interaction
    
    init(interaction: Interaction) {
        self.interaction = interaction
    }
    
    
    func wireToViewController(viewController: UIViewController!) {
        self.viewController = viewController
        prepareGestureRecognizerInView(view: viewController.view)
    }
    
    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(SwipeInteractionController.handleGesture(gestureRecognizer:)))
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        // 1
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 150)
        
        switch interaction {
        case .presenting:
            progress = -1*progress
        case .dismiss:
            break
        }
        
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        switch gestureRecognizer.state {
            
        case .began:
            // 2
            interactionInProgress = true
            switch interaction {
            case .presenting:
                
                let sc = SecondViewController()
                sc.transitioningDelegate = self.viewController as? UIViewControllerTransitioningDelegate
                viewController.present(sc, animated: true, completion: nil)
            case .dismiss:
                viewController.dismiss(animated: true, completion: nil)
            }
            
        case .changed:
            // 3
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        case .cancelled:
            // 4
            interactionInProgress = false
            cancel()
            
        case .ended:
            // 5
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
            
        default:
            print("Unsupported")
        }
    }
}
