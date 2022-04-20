//
//  ColliderManager.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SpriteKit

class ColliderManager {
  
    
    static func Collide(left: WoodBlock, right: WoodBlock, contact: SKPhysicsContact, isend: Bool) {
        print("Collision between wood and wood")
    }
    
    static func Collide(left: StoneBlock, right: StoneBlock, contact: SKPhysicsContact, isend: Bool) {
        print("Collision between stone and stone")
    }
    
    static func Collide(left: WoodBlock, right: StoneBlock, contact: SKPhysicsContact, isend: Bool) {
        print("Collision between wood and stone")
    }
    
    static func Collide(left: GlassBlock, right: GlassBlock, contact: SKPhysicsContact, isend: Bool) {
        print("Collision between glass and glass")
    }
    static func Collide(left: Boundary, right: Seed, contact: SKPhysicsContact, isend: Bool) {
        print("Collision between Boundary and Seed")
        if left.deSpawnOther() {
            right.setKillTimer()
        }
    }

    static func Collide(left: Boundary, right: Block, contact: SKPhysicsContact, isend: Bool) {
        print("Collision between Boundary and Block")
        if left.deSpawnOther() {
            right.setKillTimer()
        }
    }
}
