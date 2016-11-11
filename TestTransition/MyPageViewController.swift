//
//  MyPageViewController.swift
//  TestTransition
//
//  Created by Vladimír Čalfa on 7/11/2016.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

class MyPageViewController : PageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageDelegate = self
        
        setCurrentViewController(currentViewController: SecondViewController.instance())
    }
}

extension MyPageViewController: PageViewControllerDelegate {
    
    
    func pageViewController(_ pageViewController: PageViewController, shouldNavigateBefore viewController: UIViewController?) -> Bool {
        
        guard let sc = viewController as? SecondViewController , sc.index > 1 else {
            return false
        }

        return true
    }
    
    func pageViewController(_ pageViewController: PageViewController, shouldNavigateAfter viewController: UIViewController?) -> Bool {
        
        guard let sc = viewController as? SecondViewController , sc.index < 22  else {
            return false
        }
        
        return true
    }
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerBefore viewController: UIViewController?) -> UIViewController? {
        
        guard let sc = viewController as? SecondViewController , sc.index > 1 else {
            return nil
        }
        
        return SecondViewController.instance(index: sc.index-1)
    }
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerAfter viewController: UIViewController?) -> UIViewController? {
        guard let sc = viewController as? SecondViewController , sc.index < 22  else {
            return nil
        }
        
        return SecondViewController.instance(index: sc.index+1)
    }
}

