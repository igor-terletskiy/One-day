//
//  PulseAnimationo.swift
//  InstNews
//
//  Created by Igor on 1/31/19.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class PulseAnimation {
    
    var pulseLayers = [CAShapeLayer]()
    let circularPath = UIBezierPath(arcCenter: .zero , radius: 65  , startAngle: 0, endAngle: 2 * .pi, clockwise: true)

    func createPulse(position: CGPoint) {

        for _ in 0...2 {
            
            let pulseLayer = CAShapeLayer()
            pulseLayer.name = "Pulselayers"
            pulseLayer.path = circularPath.cgPath
            pulseLayer.lineWidth = 2.0
            pulseLayer.fillColor = UIColor.white.cgColor
            pulseLayer.lineCap = CAShapeLayerLineCap.round
            pulseLayer.position = position
            pulseLayers.append(pulseLayer)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.animatePulse(index: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.025) {
                self.animatePulse(index: 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    self.animatePulse(index: 2)
                }
            }
        }
    }
    
    
    func animatePulse(index: Int) {
        
        pulseLayers[index].strokeColor = UIColor.black.cgColor
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1.25
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 0.9
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        scaleAnimation.repeatCount = .greatestFiniteMagnitude
        pulseLayers[index].add(scaleAnimation, forKey: "scale")
        
        let opacityAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        opacityAnimation.duration = 1.25
        opacityAnimation.fromValue = 0.9
        opacityAnimation.toValue = 0.0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        opacityAnimation.repeatCount = .greatestFiniteMagnitude
        pulseLayers[index].add(opacityAnimation, forKey: "opacity")
    }
}
