//
//  PhysicsEnums.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/23/21.
//

import Foundation

enum BodyType: String, Codable {
    case StaticBody
    case DynamicBody
    
    func toString() -> String {
        switch(self) {
        
        case .StaticBody:
            return "Static"
        case .DynamicBody:
            return "Dynamic"
        }
    }
}
