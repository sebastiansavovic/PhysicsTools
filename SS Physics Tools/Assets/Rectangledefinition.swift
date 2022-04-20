//
//  Rectangledefinition.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let rectangledefinition = try? newJSONDecoder().decode(Rectangledefinition.self, from: jsonData)

import Foundation
import SwiftUI

enum ImageName : String, Codable {
    case None
    case Wood_Square_1
    case Wood_Circle_1
    case Wood_Triangle_1
    case Wood_Triangle_2
    case Stone_Square_1
    case Stone_Circle_1
    case Stone_Triangle_1
    case Stone_Triangle_2
    case Wood_Rectangle_1
    case Stone_Rectangle_1
    case Glass_Square_1
    case Glass_Rectangle_1
    case Glass_Circle_1
    case Glass_Triangle_1
    case Glass_Triangle_2
    case SlingShot_1
    case WhiteBird
    case Seed
    
    func toString() -> String {
        switch(self) {
        case .None:
            return "None"
        case .Wood_Square_1:
            return "Wood Square"
        case .Wood_Circle_1:
            return  "Wood Circle"
        case .Wood_Triangle_1:
            return "Wood Triangle"
        case .Wood_Triangle_2:
            return "Wood Triangle"
        case .Stone_Square_1:
            return "Stone Square"
        case .Stone_Circle_1:
            return  "Stone Circle"
        case .Stone_Triangle_1:
            return  "Stone Triangle"
        case .Stone_Triangle_2: 
            return  "Stone Triangle"
        case .Wood_Rectangle_1:
            return "Wood Rectangle"
        case .Stone_Rectangle_1:
            return "Stone Rectangle"
        case .Glass_Square_1:
            return "Glass Square"
        case .Glass_Rectangle_1:
            return "Glass Rectangle"
        case .Glass_Circle_1:
            return "Glass Circle"
        case .Glass_Triangle_1:
            return "Glass Triangle"
        case .Glass_Triangle_2:
            return "Glass Triangle"
        case .SlingShot_1:
            return "SlingShot"
        case .WhiteBird:
            return "White Bird"
        case .Seed:
            return "Seed"
        }
    }
}

enum TextName : String, Codable {
    case None
    case Birds
    case GlassBlocks
    case WoodBlocks
    case StoneBlocks
    func toString() -> String {
        switch(self) {
        case .None:
            return "None"
        case .Birds:
            return ""
        case .GlassBlocks:
            return "Glass"
        case .WoodBlocks:
            return "Wood"
        case .StoneBlocks:
            return "Stone"
        }
    }
}
enum Shape : String, Codable {
    case Rectangle
    case Circle
    case TriangleUp
    case TriangleDown
    case Triangle45
}

// MARK: - Rectangledefinition
struct Rectangledefinition: Codable {
    let name: ImageName
    let textName: TextName
    let shape: Shape
    let rectangle: Rectangle

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case textName = "TextName"
        case shape = "Shape"
        case rectangle = "Rectangle"
    }
}

// MARK: - Rectangle
struct Rectangle: Codable {
    let x, y, width, height: CGFloat

    enum CodingKeys: String, CodingKey {
        case x = "X"
        case y = "Y"
        case width = "Width"
        case height = "Height"
    }
}

