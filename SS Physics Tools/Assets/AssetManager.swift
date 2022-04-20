//
//  AssetManager.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SwiftUI
import SpriteKit



class AssetManager {
    @Dependency(PhysicsManager.self) var physicsManager: PhysicsManager
    let spriteMapName = "SpriteMap"
    let GlossaryName = "Glossary"
    let glossaryItems: [GlossaryItem]
    let spriteFinder:[ImageName: Rectangledefinition]
    let sheetFinder:[TextName: SpriteSheet]
    var itemDefinition: DefinitionHolder
    var selectedObject: SelectionHolder
    var existingAssets:[String: GameObject]
    let currentSelectionType: CurrentSelectionType
    var scene: SKScene? = nil
    init() {
        let data =  NSDataAsset(name: spriteMapName, bundle: Bundle.main)!.data
        let decoder = JSONDecoder()
        let images = try! decoder.decode([Rectangledefinition].self, from: data)
        let map = images.lazy.map({($0.name, $0) })
        spriteFinder = Dictionary(map, uniquingKeysWith: { _, latest in latest })
        
        let mapImage = images.lazy.map({($0.textName, SpriteSheet(texture: SKTexture(imageNamed: $0.textName.rawValue))) })
        
        sheetFinder = Dictionary(mapImage, uniquingKeysWith: { _, latest in latest })
        existingAssets = [:]
        selectedObject = SelectionHolder()
        self.currentSelectionType = CurrentSelectionType()
        self.itemDefinition = DefinitionHolder()
        
        let glossData = NSDataAsset(name: GlossaryName, bundle: Bundle.main)!.data
       
        let items = try! decoder.decode([GlossaryItem].self, from: glossData)
            .sorted(by: {
                return $0.title < $1.title
            })
        self.glossaryItems = items
    }
    var previousTime:Double = 0
    private var touchTypes:TouchTypes = .None
    
    func removeObject(gameObject: GameObject) {
        self.existingAssets.removeValue(forKey: gameObject.assetName)
        if gameObject == self.selectedObject.gameObject {
            self.selectedObject.gameObject = nil
        }
    }
    func getGlossary() -> [GlossaryItem] {
        return glossaryItems
    }
    
    func update(_ currentTime: TimeInterval) {
        for item in self.existingAssets {
            item.value.update(currentTime)
        }
        
        if let obj = self.selectedObject.gameObject {
            if currentTime - previousTime > 1 {
                if let physicsBody = obj.physicsBody {
                    self.selectedObject.physicsData.angularVelocity = physicsBody.angularVelocity
                    
                    self.selectedObject.physicsData.velocity = physicsBody.velocity
                    
                    previousTime = currentTime
                }
            }
        }
        
        
    }
    
    func setItemDefinition(itemDefinition: ItemDefinition) {
        self.itemDefinition.definition = itemDefinition
    }
    func getItemDefinition() -> DefinitionHolder? {
        return self.itemDefinition
    }
    
    func setSelectMode(_ newValue: SelectionType) {
        self.currentSelectionType.type = newValue
    }
    func getSelectMode() -> SelectionType {
        return self.currentSelectionType.type
    }
    
    func clearWorld() {
        for item in self.existingAssets {
            item.value.removeFromParent()
        }
        self.selectedObject.gameObject = nil
        
    }
    
    func getPhysicsBody(sprite: SKSpriteNode, definition: Rectangledefinition, physicsData: PhysicsData?) {
        
        switch(definition.shape) {
        
        case .Rectangle:
            sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width, height: sprite.size.height))
        case .Circle:
            sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2.0, center: CGPoint(x: 0, y: 0))
        case .TriangleUp:
            let trianglePath:CGMutablePath = CGMutablePath()
            
            trianglePath.addLines(between: [CGPoint(x: -sprite.size.width / 2, y: -sprite.size.height / 2),
                                            CGPoint(x:  sprite.size.width / 2, y: -sprite.size.height / 2),
                                            CGPoint(x:  0.0 / 2, y: sprite.size.height / 2)])
            sprite.physicsBody = SKPhysicsBody(polygonFrom: trianglePath)
        case .Triangle45:
            let trianglePath:CGMutablePath = CGMutablePath()
            
            trianglePath.addLines(between: [CGPoint(x: -sprite.size.width / 2, y: -sprite.size.height / 2),
                                            CGPoint(x:  sprite.size.width / 2, y: -sprite.size.height / 2),
                                            CGPoint(x:  -sprite.size.width / 2, y: sprite.size.height / 2)])
            sprite.physicsBody = SKPhysicsBody(polygonFrom: trianglePath)
        case .TriangleDown:
            let trianglePath:CGMutablePath = CGMutablePath()
            
            trianglePath.addLines(between: [CGPoint(x: -sprite.size.width / 2, y: sprite.size.height / 2),
                                            CGPoint(x:  sprite.size.width / 2, y: sprite.size.height / 2),
                                            CGPoint(x:  0.0 / 2, y: -sprite.size.height / 2)])
            sprite.physicsBody = SKPhysicsBody(polygonFrom: trianglePath)
        }
        if let physicsData = physicsData {
            sprite.physicsBody?.restitution = physicsData.restition
            sprite.physicsBody?.friction = physicsData.friction
            sprite.physicsBody?.density = physicsData.density
            if physicsData.bodyType == .StaticBody {
                sprite.physicsBody?.isDynamic = false
            }
            sprite.zRotation = physicsData.angle
        }
        
    }
    func getImageByName(name: ImageName) -> UIImage? {
        
        if let sprite = self.getSpriteForName(name: name) {
            return UIImage(cgImage: sprite.cgImage())
        }
        return nil
    }
    func getSpriteForName(name: ImageName) -> SKTexture? {
        if let imageDefinition = self.spriteFinder[name] {
            let sheet = self.sheetFinder[imageDefinition.textName]!
            let rectangle = imageDefinition.rectangle
            return sheet.textureForColumn(x: rectangle.x, y: rectangle.y, width: rectangle.width, height: rectangle.height)!
        }
        return nil
    }
    func getBirdObjectType(name: ImageName, texture: SKTexture, localSize: CGSize, itemDefinition: ItemDefinition, meta: AssetMeta, definition: Rectangledefinition) -> GameObject {
        switch(name) {
        case .SlingShot_1:
            return GameObject(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        case .WhiteBird:
            return WhiteBird(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        case .Seed:
            return Seed(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        default:
            return GameObject(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        }
    }
    func getObjectType(name: ImageName, texture: SKTexture, size: CGSize, itemDefinition: ItemDefinition, meta: AssetMeta) -> GameObject {
        let scale = itemDefinition.physicsData.scale
        let localSize = CGSize(width: size.width * scale, height: size.height * scale)
        let definition = self.spriteFinder[name]!
        
        switch definition.textName {
        case .None:
            return GameObject(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        case .Birds:
            return self.getBirdObjectType(name: name, texture: texture, localSize: localSize, itemDefinition: itemDefinition, meta: meta, definition: definition)
        case .GlassBlocks:
            return GlassBlock(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        case .WoodBlocks:
            return WoodBlock(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        case .StoneBlocks:
            return StoneBlock(texture: texture, size: localSize, rectangleDefinition: definition, definition: itemDefinition, meta: meta)
        }
    }
    func getAssetByDefinition(definition: ItemDefinition, meta: AssetMeta) -> GameObject? {
        if let sprite = self.getSpriteForName(name: definition.imageName) {
            let width = sprite.size().width
            let height = sprite.size().height
            let updatedSize = CGSize(width: width, height: height)
            let obj = self.getObjectType(name: definition.imageName, texture: sprite, size: updatedSize, itemDefinition: definition, meta: meta)
            self.getPhysicsBody(sprite: obj, definition: obj.rectangleDefinition, physicsData: definition.physicsData)
            existingAssets[obj.assetName] = obj
            return obj
        }
        return nil
    }
    func findObjectById(id: UUID) -> GameObject? {
        if let obj = existingAssets[id.uuidString] {
            return obj
        }
        return nil
    }
    
    func getAssetByDefinition() -> GameObject? {
        if let definition = self.itemDefinition.definition {
            let meta = AssetMeta(id: UUID())
            return self.getAssetByDefinition(definition: definition, meta: meta)
        }
        return nil
    }
    func getStaticDefinitions() -> [AssetDefinition] {
        return self.existingAssets.filter({
            return !($0.value.physicsBody?.isDynamic ?? false)
        }).map({
            $0.value.getAssetDefinition()
        })
    }
    func getBoundary(body: SKPhysicsBody) -> Boundary {
        return Boundary(texture: nil, size: CGSize(width: 0,height: 0), rectangleDefinition: Rectangledefinition(name: .None, textName: .None, shape: .Rectangle, rectangle: Rectangle(x: 0, y: 0, width: 0, height: 0)), definition: ItemDefinition(imageName: .None, physicsData: PhysicsData(restition: 0, density: 0, friction: 0, bodyType: .StaticBody, scale: 0, angle: 0)), meta: AssetMeta(id: UUID()))
    }
    
    func loadDefinitions(definitions: [AssetDefinition]) {
        guard let scene = self.scene else { return }
        self.clearWorld()
        for definition in definitions {
            let ratioWidth = scene.frame.size.width / definition.screenSource.width
            let rationHeigth =  scene.frame.size.height / definition.screenSource.height

            if definition.screenSource != scene.frame.size {

                let oldScale = definition.definition.physicsData.scale
                definition.definition.physicsData = definition.definition.physicsData.with(restition: nil, density: nil, friction: nil, bodyType: nil, scale: ratioWidth * oldScale, angle: nil)
            }
            if let asset = self.getAssetByDefinition(definition: definition.definition, meta: definition.meta) {
                scene.addChild(asset)
              
                asset.sceneSizeMultiplier = ratioWidth
                asset.position = CGPoint(x: definition.position.x * ratioWidth, y: definition.position.y * rationHeigth)
                asset.physicsBody?.contactTestBitMask = asset.physicsBody?.collisionBitMask ?? 0
                
            }
        }
    }
}



