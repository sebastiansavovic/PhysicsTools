//
//  Block.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SpriteKit

class Block : GameObject {
    
    var speedLabel: SKLabelNode? = nil
    var oldTime: TimeInterval = 0
    
    override func CollideAccept(other: GameObject, contact: SKPhysicsContact, isend: Bool) {
        other.CollisionVisit(other: self, contact: contact, isend: isend)
    }
    override func updateGlobalOptions() {
        guard let speedLabel = speedLabel else { return }
        speedLabel.fontSize = self.globalOptions.fontSize
    }
    override func CollisionVisit(other: Boundary, contact: SKPhysicsContact, isend: Bool) {
        ColliderManager.Collide(left: other, right: self, contact: contact, isend: isend)
    }
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        guard let speedLabel = speedLabel else { return }
        guard let physicsBody = self.physicsBody else { return }
        if !self.globalOptions.showPhysics {
            speedLabel.isHidden = true
            return
        }
        speedLabel.isHidden = false
        speedLabel.zRotation = -self.zRotation
        if currentTime - oldTime < 2 {
            return
        }
        oldTime = currentTime
        if physicsBody.isDynamic {
            var speedText = "Ang \(physicsBody.angularVelocity.toString())"
            speedText = speedText + "Vel \(physicsBody.velocity.dx.toString()), \(physicsBody.velocity.dy.toString())"
            speedLabel.text = speedText
        }
        else {
            let text = "Res: \(physicsBody.restitution.toString()) Den: \(physicsBody.density.toString()) Fri: \(physicsBody.friction.toString())"
            speedLabel.text = text
        }
    }
    override func initialize() {

            let localLabel = SKLabelNode(fontNamed: "Courier")
            localLabel.fontSize = 8
            localLabel.text = ""
            localLabel.horizontalAlignmentMode = .center
            //localLabel.position.y = self.rectangleDefinition.rectangle.height / 2.0
            addChild(localLabel)
            speedLabel = localLabel
      
    }
    
}
