//
//  ItemDefinition.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/23/21.
//

import Foundation
import SpriteKit
import SwiftUI

class AssetMeta: Codable {
    let id: UUID
    init(id: UUID) {
        self.id  = id
    }
}


class ItemDefinition: Codable {
    let imageName: ImageName
    
    var physicsData: PhysicsData

    enum CodingKeys: String, CodingKey {
        case imageName = "ImageName"
       
        case physicsData = "PhysicsData"
    }

    init(imageName: ImageName, physicsData: PhysicsData) {
        self.imageName = imageName
       
        self.physicsData = physicsData
    }
    
    func getDescription() -> String {
        var description = "\(self.imageName.toString())\n"
        description += "\(physicsData.bodyType.toString())\n"
        description += "Density \(physicsData.density.toString())\n"
        description += "Friction \(physicsData.friction.toString())\n"
        description += "Restitution \(physicsData.restition.toString())\n"
        description += "Angle \(physicsData.angle.toString())\n"
        
        return description
    }
    
}

// MARK: - PhysicsData
class PhysicsData: Codable {
    let restition, density, friction: CGFloat
    let bodyType: BodyType
    let scale: CGFloat
    let angle: CGFloat

    enum CodingKeys: String, CodingKey {
        case restition = "Restition"
        case density = "Density"
        case friction = "Friction"
        case bodyType = "BodyType"
        case scale = "Scale"
        case angle = "Angle"
    }

    init(restition: CGFloat, density: CGFloat, friction: CGFloat, bodyType: BodyType, scale: CGFloat, angle: CGFloat) {
        self.restition = restition
        self.density = density
        self.friction = friction
        self.bodyType = bodyType
        self.scale = scale
        self.angle = angle
    }
    func with(restition: CGFloat?, density: CGFloat?, friction: CGFloat?, bodyType: BodyType?, scale: CGFloat?, angle: CGFloat?) -> PhysicsData {
        return PhysicsData(restition: restition ?? self.restition, density: density ?? self.density, friction: friction ?? self.friction, bodyType: bodyType ?? self.bodyType, scale: scale ?? self.scale, angle: angle ?? self.angle)
    }
}
class UpdatedPhysics:ObservableObject {
    @Published var restition: CGFloat
    @Published var density: CGFloat
    @Published var friction: CGFloat
    @Published var bodyType: BodyType
  
    @Published var  scale: CGFloat
    @Published var angle: CGFloat
    @Published var mass: CGFloat
    @Published var angularVelocity: CGFloat
    @Published var velocity: CGVector

    
    init() {
        self.restition = 0.0
        self.density = 0.0
        self.friction = 0.0
        self.bodyType = .DynamicBody
        self.scale = 0.0
        self.angle = 0.0
        
        self.mass = 0.0
        self.angularVelocity = 0.0
        self.velocity = CGVector()
    }
}
