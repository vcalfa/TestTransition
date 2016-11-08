//
//  SecondViewController.swift
//  TestTransition
//
//  Created by Vladimir Calfa on 06/11/16.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hue = Double(arc4random()).truncatingRemainder(dividingBy: 256.0)  / 256.0   //  0.0 to 1.0
        let saturation =  Double(arc4random()).truncatingRemainder(dividingBy: 128.0) + 0.5  //  0.5 to 1.0, away from white
        let brightness = ( Double(arc4random()).truncatingRemainder(dividingBy: 128.0) / 256.0 ) + 0.5  //  0.5 to 1.0, away from black
        let color = UIColor(hue:CGFloat(hue) ,saturation:CGFloat(saturation), brightness:CGFloat(brightness), alpha:1)
        
        view.backgroundColor = color

        let gesture = UITapGestureRecognizer(target: self, action: #selector(action(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(gesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func action(_ sender: UITapGestureRecognizer) {
       dismiss(animated: true, completion: nil)
    }
}
