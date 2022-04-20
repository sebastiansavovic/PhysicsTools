//
//  MessageEntities.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 6/5/21.
//

import SwiftUI
import Foundation
import MultipeerConnectivity
protocol PhysicsSharingServiceDelegate {
    func connectedDevicesChanged(manager : PhysicsSharingService, connectedDevices: [MCPeerID])
    func levelReceived(manager : PhysicsSharingService, peerMessage: String)
    
}

class Peer : Identifiable {
    let id: String
    let peer: MCPeerID
    init(id: String, peer: MCPeerID) {
        self.id = id
        self.peer = peer
    }
}

class PeerMessage:  Codable {
    let definition: ItemDefinition
    let location: CGPoint
    let size: CGSize
    let id: UUID
    init(definition: ItemDefinition, location: CGPoint, size: CGSize, id: UUID) {
        self.definition = definition
        self.location = location
        self.size = size
        self.id = id
    }
}
class PeersHolder: ObservableObject {
    @Published var peerIds:[Peer] = []
}
class PeerHolder: ObservableObject {
 
    
    var placementMessage: PeerMessage? = nil
    var moveMessage: MoveMessageType? = nil
    var physicsData: PhysicsDataWrapper? = nil
    var levelData: LoadMessageType? = nil
    @Published var lastMessagePlacement: MessageType = MessageType.None
}
enum MessageType: String, Codable {

    case PlaceObject
    case MoveObject
    case UpdatePhysics
    case LoadMessage
    case None
}
class PeerMessageWrapper: Codable {
    let json: String
    let id: UUID
    let message: MessageType
    init(id: UUID, json: String, message: MessageType) {
        self.json = json
        self.message = message
        self.id = id
    }
}
class PhysicsDataWrapper: Codable {
    let id: UUID
    let size: CGSize
    let physicsData: PhysicsData
    init(physicsData: PhysicsData, id: UUID, size: CGSize) {
        self.physicsData = physicsData
        self.id = id
        self.size = size
    }
}
class MoveMessageType: Codable {
    let location: CGPoint
    let id: UUID
    let size: CGSize
    init(location: CGPoint, id: UUID, size: CGSize) {
        self.location = location
        self.id = id
        self.size = size
    }
}
class LoadMessageType: Codable {
    let levelData: [AssetDefinition]
    init(levelData: [AssetDefinition]) {
        self.levelData = levelData
    }
}
