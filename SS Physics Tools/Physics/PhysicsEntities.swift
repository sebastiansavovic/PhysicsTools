//
//  PhysicsEntities.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 6/4/21.
//

import Foundation
import SpriteKit

class Gravity: ObservableObject {
    func updateGravity(_ newAngle: CGFloat, _ modifier: CGFloat) {
        let radians = newAngle * (CGFloat.pi / 180.0)
       
        self.gravityVector = CGVector(dx: CGFloat(sinf(Float(radians))) * modifier  , dy: CGFloat(cosf(Float(radians))) * modifier)
        self.angle = newAngle
    }
    var gravityVector: CGVector = CGVector(dx: 0.0, dy: 0.0)
    var motionAvailable: Bool = true
    @Published var angle: CGFloat = 0.0
    @Published var gravityModifier: CGFloat = 10.0
    @Published var isGravityManual: Bool = false
}
class DampeningOptions: ObservableObject {
    @Published var linearDampening: CGFloat = 0.1
    @Published var angularDampening: CGFloat = 0.1
}
class GlobalOptions: ObservableObject {
    @Published var showPhysics: Bool = false
    @Published var fontSize: CGFloat = 8
    @Published var boundaryDestroys: Bool = true
    @Published var publishToPeers: Bool = false
}
