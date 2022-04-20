//
//  Seed.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/28/21.
//

import Foundation
import SpriteKit

class Seed : GameObject {

  
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }
    override func CollideAccept(other: GameObject, contact: SKPhysicsContact, isend: Bool) {
        other.CollisionVisit(other: self, contact: contact, isend: isend)
    }
    
    override func CollisionVisit(other: Boundary, contact: SKPhysicsContact, isend: Bool) {
        ColliderManager.Collide(left: other, right: self, contact: contact, isend: isend)
    }
}
