//
//  WhiteBird.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/28/21.
//

import Foundation
import SpriteKit

class WhiteBird: GameObject {

    var previousTime: TimeInterval = 0
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let interval = self.getExtendedProperty("Seed Timer", defaultValue: 0.1)
        if (currentTime - previousTime) > Double(interval) {
            previousTime = currentTime
            let restitution = self.getExtendedProperty("Seed Resitution", defaultValue: 0.2)
            let friction = self.getExtendedProperty("Seed Friction", defaultValue: 0.2)
            let density = self.getExtendedProperty("Seed Density", defaultValue: 1)
            let scale = self.getExtendedProperty("Seed Scale", defaultValue: 0.3) * 0.3 * self.sceneSizeMultiplier
            let itemDefinition = ItemDefinition(imageName: .Seed, physicsData: PhysicsData(restition: restitution, density: density, friction: friction, bodyType: .DynamicBody, scale: scale, angle: 0.0))
            let meta = AssetMeta(id: UUID())
            if let seed = assetManager.getAssetByDefinition(definition: itemDefinition, meta: meta) {
                seed.setSpawnTime(currentTime)
                if let parent = self.parent {
                    parent.addChild(seed)
                    let x = self.position.x + sin(self.zRotation) * self.size.height / 2.0
                    let y = self.position.y - cos(self.zRotation) * self.size.height / 2.0
                    seed.position = CGPoint(x: x, y: y)
                }
         
            }
        }
    }
    override func initialize() {
        self.extendedProperties["Seed Resitution"] = 0.2
        self.extendedProperties["Seed Friction"] = 0.2
        self.extendedProperties["Seed Timer"] = 0.1
        self.extendedProperties["Seed Density"] = 1.0
        self.extendedProperties["Seed Scale"] = 0.3
        
        
        self.extendedPropertyRanges["Seed Resitution"] = (0.0, 1.0)
        self.extendedPropertyRanges["Seed Friction"] = (0.0, 1.0)
        self.extendedPropertyRanges["Seed Timer"] = (0.0, 1.0)
        self.extendedPropertyRanges["Seed Density"] = (0.0, 30.0)
        self.extendedPropertyRanges["Seed Scale"] = (0.1, 5.0)
    }
}
