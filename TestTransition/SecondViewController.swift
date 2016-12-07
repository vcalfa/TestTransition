//
//  SecondViewController.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var index: Int!
    
    static func instance(index: Int = 0) -> SecondViewController {
        let sc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        sc.index = index
        return sc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let index = index {
            imageView.image = UIImage(named: "\(index)")
            print("image: \(index)")
        }
    }
}
