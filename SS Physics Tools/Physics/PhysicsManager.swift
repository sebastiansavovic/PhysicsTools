//
//  PhysicsManager.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SwiftUI
import CoreMotion
import SpriteKit


class PhysicsManager {
    
    init() {
        self.gravity = Gravity()
        self.dampening = DampeningOptions()
        self.globalOptions = GlobalOptions()
    }
    
    @ObservedObject var gravity: Gravity
    @ObservedObject var dampening: DampeningOptions
    @ObservedObject var globalOptions: GlobalOptions
    let motionManager = CMMotionManager() // must be declared as a property
    let updateFrequency = 60.0
   
    func setGravityModifier(_ newValue: CGFloat) {
        self.gravity.gravityModifier = newValue
    }
    func getGravityModifier() -> CGFloat {
        return self.gravity.gravityModifier
    }
    func setMotion(disabled: Bool) {
        if disabled {
            self.motionManager.stopDeviceMotionUpdates()
        }
        else {
            self.setupMotion()
        }
    }
    
    func setupMotion() {
        var gravityset = false
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1/updateFrequency
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                if let gravity = data?.gravity {
                    gravityset = true
                    let modifier = self.gravity.gravityModifier
                    let x = CGFloat(gravity.y) * -1.0
                    let y = CGFloat(gravity.x)
                    self.gravity.gravityVector = CGVector(dx: x * modifier, dy: y * modifier)
                    let radians = atan2(self.gravity.gravityVector.dx, self.gravity.gravityVector.dy) - CGFloat.pi
                    self.gravity.angle = (radians * 180.0  / .pi) + 180.0
                    self.gravity.isGravityManual = false
                }
            }
        }
        if !gravityset {
            let modifier = self.gravity.gravityModifier
            let x = CGFloat(0.0)
            let y = CGFloat(-1.0)
            self.gravity.motionAvailable = false
            self.gravity.gravityVector = CGVector(dx: x * modifier, dy: y * modifier)
            self.gravity.isGravityManual = true
        }
    }
}
