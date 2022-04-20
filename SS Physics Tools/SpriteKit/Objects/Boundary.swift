//
//  Boundary.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 6/4/21.
//

import Foundation
import SpriteKit

class Boundary : GameObject {
    
    func deSpawnOther() -> Bool {
        return self.globalOptions.boundaryDestroys
    }
    override func CollideAccept(other: GameObject, contact: SKPhysicsContact, isend: Bool) {
        other.CollisionVisit(other: self, contact: contact, isend: isend)
    }
    
    override func CollisionVisit(other: Seed, contact: SKPhysicsContact, isend: Bool) {
        ColliderManager.Collide(left: self, right: other, contact: contact, isend: isend)
    }
    
    override func CollisionVisit(other: Block, contact: SKPhysicsContact, isend: Bool) {
        ColliderManager.Collide(left: self, right: other, contact: contact, isend: isend)
    }
}
