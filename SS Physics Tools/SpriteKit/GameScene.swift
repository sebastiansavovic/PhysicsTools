//
//  GameScene.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import SwiftUI
import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    @Dependency(AssetManager.self) var assetManager: AssetManager
    @Dependency(PhysicsManager.self) var physicsManager: PhysicsManager
    @Dependency(PhysicsSharingManager.self) var physicsSharingManager: PhysicsSharingManager
    var gravityHolder: Any = 0
    var messageHolder: Any = 0
    var settingsHolder: Any = 0
    var boundary: Boundary? = nil
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        physicsBody?.contactTestBitMask = physicsBody?.collisionBitMask ?? 0
        
        self.physicsWorld.contactDelegate = self
        self.view?.showsFPS = true
        self.view?.showsNodeCount = true
        self.view?.allowsTransparency = true
        self.view?.showsFields = true
        self.backgroundColor = .lightGray
        self.view?.isMultipleTouchEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(pinchGestureAction(_:)))
        self.view?.addGestureRecognizer(pinchGesture)
        let rotateGesture = UIRotationGestureRecognizer()
        rotateGesture.addTarget(self, action: #selector(rotateGestureAction(_:)))
        self.view?.addGestureRecognizer(rotateGesture)
        gravityHolder = self.physicsManager.gravity.objectWillChange.sink(receiveValue: {
            self.physicsWorld.gravity = self.physicsManager.gravity.gravityVector
        })
        messageHolder = self.physicsSharingManager.peerHolder.objectWillChange.sink(receiveValue: {
            self.ProcessMessage()
        })
        settingsHolder = self.physicsManager.globalOptions.objectWillChange.sink(receiveValue: {
            self.view?.showsPhysics = !self.physicsManager.globalOptions.showPhysics
        })
        self.assetManager.scene = self
        self.boundary = self.assetManager.getBoundary(body: self.physicsBody!)
    }
    @objc func rotateGestureAction(_ gestureRecognizer: UIRotationGestureRecognizer) {
        if assetManager.currentSelectionType.type != .Manipulate {
            return
        }
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            if let selectedNode = self.selectedNode {
                selectedNode.zRotation = gestureRecognizer.rotation * -1.0
                self.assetManager.selectedObject.physicsData.angle = selectedNode.zRotation
                self.updatePhysicsOfSelected()
                physicsSharingManager.sendPhysicsData(physicsData: selectedNode.definition.physicsData, size: CGSize(width: 0, height: 0), id: selectedNode.id)
                selectedNode.physicsBody?.isDynamic = selectedNode.definition.physicsData.bodyType == .DynamicBody
            }
        }
    }
    
    @objc func pinchGestureAction(_ gestureRecognizer: UIPinchGestureRecognizer) {
        if assetManager.currentSelectionType.type != .Manipulate {
            return
        }
        guard gestureRecognizer.view != nil else { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            if let selectedNode = self.selectedNode {
                selectedNode.xScale = gestureRecognizer.scale
                selectedNode.yScale = gestureRecognizer.scale
                self.assetManager.selectedObject.physicsData.scale = gestureRecognizer.scale
                self.updatePhysicsOfSelected()
                physicsSharingManager.sendPhysicsData(physicsData: selectedNode.definition.physicsData, size: CGSize(width: 0, height: 0), id: selectedNode.id)
                selectedNode.physicsBody?.isDynamic = selectedNode.definition.physicsData.bodyType == .DynamicBody
            }
        }
    }
    func updatePhysicsOfSelected() {
        if let gameObject = self.assetManager.selectedObject.gameObject {
            let physics = self.assetManager.selectedObject.physicsData
            gameObject.definition.physicsData = PhysicsData(restition: physics.restition, density: physics.density, friction: physics.friction, bodyType: physics.bodyType, scale: physics.scale, angle: physics.angle)
           
        }
    }
    fileprivate func ProcessMessage() {
        let type = self.physicsSharingManager.peerHolder.lastMessagePlacement
        switch(type) {
        case .LoadMessage:
            if let message = self.physicsSharingManager.peerHolder.levelData {
                self.assetManager.loadDefinitions(definitions: message.levelData)
            }
        case .PlaceObject:
            if let message = self.physicsSharingManager.peerHolder.placementMessage {
                
                let ratioWidth = self.frame.size.width / message.size.width
                let rationHeigth =  self.frame.size.height / message.size.height
                if message.size != self.frame.size {
                    
                    let oldScale = message.definition.physicsData.scale
                    message.definition.physicsData = message.definition.physicsData.with(restition: nil, density: nil, friction: nil, bodyType: nil, scale: ratioWidth * oldScale, angle: nil)
                }
                let meta = AssetMeta(id: message.id)
                if let sprite = self.assetManager.getAssetByDefinition(definition: message.definition, meta: meta) {
                    
                    sprite.position = CGPoint(x: message.location.x * ratioWidth, y: message.location.y * rationHeigth)
                    sprite.sceneSizeMultiplier = ratioWidth
                    sprite.physicsBody?.contactTestBitMask = sprite.physicsBody?.collisionBitMask ?? 0
                    addChild(sprite)
                    MyLog.debug("Created new Item from message")
                }
            }
        case .MoveObject:
            if let message = self.physicsSharingManager.peerHolder.moveMessage {
                if let obj = self.assetManager.findObjectById(id: message.id) {
                    let ratioWidth = self.frame.size.width / message.size.width
                    let rationHeigth =  self.frame.size.height / message.size.height
                    obj.position = CGPoint(x: message.location.x * ratioWidth, y: message.location.y * rationHeigth)
                    setSelected(obj)
                    MyLog.debug("Moved Item from message")
                }
            }
        case .UpdatePhysics:
            if let message = self.physicsSharingManager.peerHolder.physicsData {
                if let obj = self.assetManager.findObjectById(id: message.id) {
                    setSelected(obj)
                    obj.definition.physicsData = message.physicsData
                    obj.size.height = obj.rectangleDefinition.rectangle.height * message.physicsData.scale
                    obj.size.width = obj.rectangleDefinition.rectangle.width * message.physicsData.scale
                    assetManager.getPhysicsBody(sprite: obj, definition: obj.rectangleDefinition, physicsData: obj.definition.physicsData)
                    MyLog.debug("Created new physics from message")
                }
            }
        case .None:
            MyLog.debug("Message undefined")
            return
        }
        self.physicsSharingManager.clearMessage()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.assetManager.update(currentTime)
    }
    var selectedNode: GameObject? = nil
    var selectedIsDynamic: Bool = false
    fileprivate func PlaceItem(_ touches: Set<UITouch>) {
        for touch in touches{
            let location = touch.location(in: self)
            
            if let triangle = self.assetManager.getAssetByDefinition() {
                triangle.position = location
                triangle.physicsBody?.contactTestBitMask = triangle.physicsBody?.collisionBitMask ?? 0
                let currentSize = self.frame.size
                self.physicsSharingManager.sendDefinition(definition: triangle.definition, location: location, size: currentSize, id: triangle.id)
                addChild(triangle)
                triangle.updateGravityItems()
                if touches.count == 1 && self.assetManager.selectedObject.gameObject == nil {
                    setSelected(triangle)
                }
            }
        }
    }
    
    fileprivate func setSelected(_ sprite: GameObject) {
        self.assetManager.selectedObject.gameObject = sprite
        self.assetManager.selectedObject.updatePhysicsData(physicsData: sprite.definition.physicsData, body: sprite.physicsBody!)
        self.assetManager.selectedObject.extendedProperties.extendedProperties = sprite.extendedProperties
        self.assetManager.selectedObject.extendedProperties.extendedPropertyRanges = sprite.extendedPropertyRanges
    }
    
    fileprivate func selectFirtTouch(_ touches: Set<UITouch>) {
        for touch in touches{
            
            let location = touch.location(in: self)
            let node:SKNode = self.atPoint(location)
            if let sprite = node as? GameObject {
                print("\(sprite.physicsBody?.mass ?? 0.0)")
                selectedNode = sprite
                self.selectedIsDynamic = sprite.physicsBody?.isDynamic ?? false
                sprite.physicsBody?.isDynamic = false
                setSelected(sprite)
                break
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch self.assetManager.getSelectMode() {
        case .None:
            return
        case .Move:
            if touches.count == 1 {
                selectFirtTouch(touches)
            }
        case .Place:
            PlaceItem(touches)
        case .Manipulate:
            selectFirtTouch(touches)
        case .Pause:
            if let view = self.view {
                view.isPaused = !view.isPaused
            }
        }
    }
    func getContactPair(_ contact: SKPhysicsContact) -> (nodeA: SKNode?, nodeB: SKNode?) {
        if contact.bodyA == self.physicsBody {
            return (self.boundary, contact.bodyB.node)
        }
        if contact.bodyB == self.physicsBody {
            return (contact.bodyA.node, self.boundary)
        }
        return (contact.bodyA.node, contact.bodyB.node)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let nodes = self.getContactPair(contact)
        guard let objectA = nodes.nodeA as? GameObject else { return }
        guard let objectB = nodes.nodeB as? GameObject else { return }
        
        objectA.CollideAccept(other: objectB, contact: contact, isend: false)
        
    }
    func didEnd(_ contact: SKPhysicsContact) {
        let nodes = self.getContactPair(contact)
        guard let objectA = nodes.nodeA as? GameObject else { return }
        guard let objectB = nodes.nodeB as? GameObject else { return }
        
        objectA.CollideAccept(other: objectB, contact: contact, isend: true)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.assetManager.currentSelectionType.type != .Move {
            return
        }
        guard let firstTouch = touches.first else {return}
        if let selected = self.selectedNode {
            let location = firstTouch.location(in: self)
            selected.position = location
            let currentSize = self.frame.size
            self.physicsSharingManager.sendMoveCommand(location: location, size: currentSize, id: selected.id)
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.assetManager.currentSelectionType.type != .Move {
            return
        }
        if let node = self.selectedNode {
            node.physicsBody?.isDynamic = node.definition.physicsData.bodyType == .DynamicBody
        }
        self.selectedNode = nil
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let node = self.selectedNode {
            node.physicsBody?.isDynamic = node.definition.physicsData.bodyType == .DynamicBody
        }
        self.selectedNode = nil
    }
    
}

