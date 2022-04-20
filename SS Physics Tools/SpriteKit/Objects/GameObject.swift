//
//  GameObject.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SwiftUI
import SpriteKit

class ExtendedPropertiesHolder: ObservableObject {
    @Published var extendedProperties: [String: CGFloat] = [:]
    @Published var extendedPropertyRanges: [String: (CGFloat, CGFloat)] = [:]
}

class GameObject : SKSpriteNode {
    @Dependency(AssetManager.self) var assetManager: AssetManager
    @Dependency(PhysicsManager.self) var physicsManager: PhysicsManager
    let rectangleDefinition: Rectangledefinition
    let assetName:String
    let id: UUID
    var spawnTime: TimeInterval
    var holder: Any
    var optionsHolder: Any
    var angularDampeningHolder: Any
    var extendedProperties: [String: CGFloat] = [:]
    var extendedPropertyRanges: [String: (CGFloat, CGFloat)] = [:]
    var angularDampening: CGFloat
    var linearDampening: CGFloat
    var sceneSizeMultiplier: CGFloat = 1.0
    @ObservedObject var extendedPropertiesCurrent: ExtendedPropertiesHolder
    @ObservedObject var dampening: DampeningOptions
    @ObservedObject var globalOptions: GlobalOptions
    let definition: ItemDefinition
    let meta: AssetMeta
    init(texture: SKTexture?, size: CGSize, rectangleDefinition: Rectangledefinition, definition: ItemDefinition, meta: AssetMeta) {
        self.meta = meta
        self.id = meta.id
        self.assetName = self.id.uuidString
        self.rectangleDefinition = rectangleDefinition
        self.definition = definition
        self.spawnTime = 0
        angularDampeningHolder = 0
        holder = 0
        optionsHolder = 0
        angularDampening = 0.1
        linearDampening = 0.1
        self.extendedProperties = [:]
        self.extendedPropertiesCurrent = ExtendedPropertiesHolder()
        self.globalOptions = GlobalOptions()
        self.isBeingKilled = false
        self.dampening = DampeningOptions()
        super.init(texture: texture, color: .red, size: size)
        self.extendedPropertiesCurrent = assetManager.selectedObject.extendedProperties
        holder = self.extendedPropertiesCurrent.objectWillChange.sink(receiveValue: {
            self.setUpdatedProperties()
        })
        self.globalOptions = self.physicsManager.globalOptions
        self.dampening = self.physicsManager.dampening
        angularDampeningHolder = self.dampening.objectWillChange.sink(receiveValue: {
            self.updateGravityItems()
        })
        self.optionsHolder = self.globalOptions.objectWillChange.sink(receiveValue: {
            self.updateGlobalOptions()
        })
        self.initialize()
        
    }
    func updateGlobalOptions() {
        
    }
    func updateGravityItems() {
        if !(self.physicsBody?.isDynamic ?? false) {
            return
        }
        if angularDampening != self.dampening.angularDampening {
            angularDampening = self.dampening.angularDampening
            self.physicsBody?.angularDamping = angularDampening
        }
        if linearDampening != self.dampening.linearDampening {
            linearDampening = self.dampening.linearDampening
            self.physicsBody?.linearDamping = linearDampening
        }
    }
    private func setUpdatedProperties() {
        if let obj = self.assetManager.selectedObject.gameObject {
            if self == obj {
                self.extendedProperties = self.extendedPropertiesCurrent.extendedProperties
            }
        }
    }
    func getAssetDefinition() -> AssetDefinition {
        return AssetDefinition(definition: self.definition, meta: self.meta, position: Position(x: self.position.x, y: self.position.y), screenSource: self.assetManager.scene?.frame.size ?? CGSize(width: 812, height: 738))
    }
    func getExtendedProperty(_ forKey: String, defaultValue: CGFloat) -> CGFloat {
        if let obj = self.assetManager.selectedObject.gameObject {
            if self == obj {
                if let value = self.extendedPropertiesCurrent.extendedProperties[forKey] {
                    return value
                }
            }
        }
        return self.extendedProperties[forKey, default: defaultValue]
    }
    func initialize() {
        
    }
    func setSpawnTime(_ currentTime: TimeInterval) {
        spawnTime = currentTime
    }
    func update(_ currentTime: TimeInterval) {
      
    }
    override func removeFromParent() {
        super.removeFromParent()
        self.assetManager.removeObject(gameObject: self)
    }
    var isBeingKilled:Bool
    func setKillTimer() {
        if self.isBeingKilled {
            return
        }
        self.isBeingKilled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.removeFromParent()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func CollideAccept(other: GameObject, contact: SKPhysicsContact, isend: Bool) {
     
    }
  
    func CollisionVisit(other: WoodBlock, contact: SKPhysicsContact, isend: Bool) {
      
    }
    func CollisionVisit(other: GlassBlock, contact: SKPhysicsContact, isend: Bool) {
  
    }
    func CollisionVisit(other: StoneBlock, contact: SKPhysicsContact, isend: Bool) {

    }
    func CollisionVisit(other: WhiteBird, contact: SKPhysicsContact, isend: Bool) {
       
    }
    func CollisionVisit(other: Seed, contact: SKPhysicsContact, isend: Bool) {
      
    }
    func CollisionVisit(other: Boundary, contact: SKPhysicsContact, isend: Bool) {
       
    }
    func CollisionVisit(other: Block, contact: SKPhysicsContact, isend: Bool) {
       
    }
}
