//
//  StoneBlock.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SpriteKit

class StoneBlock : Block {
    override func CollideAccept(other: GameObject, contact: SKPhysicsContact, isend: Bool) {
        other.CollisionVisit(other: self, contact: contact, isend: isend)
    }
   
    override func CollisionVisit(other: WoodBlock, contact: SKPhysicsContact, isend: Bool) {
        ColliderManager.Collide(left: other, right: self, contact: contact, isend: isend)
    }
    override func CollisionVisit(other: GlassBlock, contact: SKPhysicsContact, isend: Bool) {
       
    }
    override func CollisionVisit(other: StoneBlock, contact: SKPhysicsContact, isend: Bool) {
        ColliderManager.Collide(left: self, right: other, contact: contact, isend: isend)
    }
    
}
