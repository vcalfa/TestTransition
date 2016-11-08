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
        
        setCurrentViewController(currentViewController: SecondViewController())
    }
}

extension MyPageViewController: PageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerBefore viewController: UIViewController?) -> UIViewController? {
        return SecondViewController()
    }
    
    func pageViewController(_ pageViewController: PageViewController, viewControllerAfter viewController: UIViewController?) -> UIViewController? {
        return SecondViewController()
    }
}

