//
//  FloatExtension.swift
//  TestTransition
//
//  Created by Vladimír Čalfa on 8/12/2016.
//  Copyright © 2016 Vladimir Calfa. All rights reserved.
//

import Foundation

extension Float {
    
    func border(min:Float, max: Float) -> Float {
        return fminf(fmaxf(Float(self), min), max)
    }
}
