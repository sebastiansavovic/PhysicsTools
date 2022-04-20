//
//  AssetTypes.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/28/21.
//

import Foundation
import SwiftUI
import SpriteKit

class Position: Codable {
    let x: CGFloat
    let y: CGFloat
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

class GlossaryItem : Codable, Identifiable {
    let title: String
    let description: String
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case description = "Description"
    }
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

class AssetDefinition: Codable {
    let definition: ItemDefinition
    let meta: AssetMeta
    let position: Position
    var screenSource: CGSize
    init(definition: ItemDefinition, meta: AssetMeta, position: Position, screenSource: CGSize) {
        self.definition = definition
        self.meta = meta
        self.position = position
        self.screenSource = screenSource
    }
}

class DefinitionHolder: ObservableObject {
    @Published var definition: ItemDefinition? = nil
}

class SelectionHolder: ObservableObject {
    @Published var gameObject:GameObject? = nil
    @Published var physicsData: UpdatedPhysics = UpdatedPhysics()
    @Published var extendedProperties: ExtendedPropertiesHolder = ExtendedPropertiesHolder()
    
    func updatePhysicsData(physicsData: PhysicsData, body: SKPhysicsBody) {
        self.physicsData.bodyType = physicsData.bodyType
        self.physicsData.density = physicsData.density
        self.physicsData.friction = physicsData.friction
        self.physicsData.restition = physicsData.restition
        self.physicsData.scale = physicsData.scale
        self.physicsData.angle = physicsData.angle
        self.physicsData.mass = body.mass
    }
}

class CurrentSelectionType: ObservableObject {
    @Published var type: SelectionType = .None
}
class SelectionTypeHolder: Identifiable {
    let id: String
    let type: SelectionType
    init(id: String, type: SelectionType) {
        self.id  = id
        self.type = type
    }
}
