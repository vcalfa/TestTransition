//
//  ViewController.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let swipeInteractionController = SwipeInteractionController(interaction: .dismiss)
    let swipeInteractionControllerO = SwipeInteractionController(interaction: .presenting)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeInteractionControllerO.wireToViewController(viewController: self)
    }

    @IBAction func button(_ sender: UIButton) {
     
        let sc = SecondViewController()
        sc.transitioningDelegate = self
        present(sc, animated: true, completion: {
            self.swipeInteractionController.wireToViewController(viewController: sc)
        })
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let a = Animator(animation: .presenting)
        return a
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(animation: .dismiss)
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeInteractionControllerO.interactionInProgress ? swipeInteractionControllerO : nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return swipeInteractionController.interactionInProgress ? swipeInteractionController : nil
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
}
