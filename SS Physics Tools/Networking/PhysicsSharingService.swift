//
//  PhysicsSharingService.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/24/21.
//

import SwiftUI
import Foundation
import MultipeerConnectivity


class PhysicsSharingManager: PhysicsSharingServiceDelegate {
    
    @ObservedObject var globalOptions: GlobalOptions
    let peerHolder:PeerHolder
    var messageAcknowledgement: [UUID: Bool]
    let peersHolder:PeersHolder
    func connectedDevicesChanged(manager: PhysicsSharingService, connectedDevices: [MCPeerID]) {
        OperationQueue.main.addOperation{
            
            var newItems = [Peer]()
            for device in connectedDevices {
                newItems.append(Peer(id: device.displayName, peer: device))
            }
            self.peersHolder.peerIds = newItems
        }
    }
    func clearMessage() {
        self.peerHolder.placementMessage = nil
        self.peerHolder.moveMessage = nil
        self.peerHolder.physicsData = nil
        self.peerHolder.levelData = nil
    }
  
    func levelReceived(manager: PhysicsSharingService, peerMessage: String) {
        OperationQueue.main.addOperation {
           
            if !self.globalOptions.publishToPeers {
                MyLog.debug("Peer functionality disabled")
                return
            }
            if let payload = try? JSONDecoder().decode(PeerMessageWrapper.self, from: Data(peerMessage.utf8)) {
                
                if let _ = self.messageAcknowledgement[payload.id] {
                    MyLog.debug("Message was already processed")
                    return
                }
                self.messageAcknowledgement[payload.id] = true
                switch(payload.message) {
                case .PlaceObject:
                    if let message = try? JSONDecoder().decode(PeerMessage.self, from: Data(payload.json.utf8)) {
                        self.peerHolder.placementMessage = message
                    }
                case .MoveObject:
                    if let message = try? JSONDecoder().decode(MoveMessageType.self, from: Data(payload.json.utf8)) {
                        self.peerHolder.moveMessage = message
                    }
                case .UpdatePhysics:
                    if let message = try? JSONDecoder().decode(PhysicsDataWrapper.self, from: Data(payload.json.utf8)) {
                        self.peerHolder.physicsData = message
                    }
                case .LoadMessage:
                    if let message = try? JSONDecoder().decode(LoadMessageType.self, from: Data(payload.json.utf8)){
                        self.peerHolder.levelData = message
                    }
                case .None:
                    MyLog.debug("Message undefined")
                }
                self.peerHolder.lastMessagePlacement = payload.message
               
            }
        }
    }
    private func sendMessage(_ payload: Data, message: MessageType) {
        if !self.globalOptions.publishToPeers {
            MyLog.debug("Peer sending disabled")
            return
        }
        let wrapper = PeerMessageWrapper(id: UUID(), json: String(data: payload, encoding: .utf8)!, message: message)
            if let wrapperPayload = try? JSONEncoder().encode(wrapper) {
                self.service.send(peerMessage: wrapperPayload)
            }
        
    }
    func loadDefinitions(definition: [AssetDefinition]) {
        let message = LoadMessageType(levelData: definition)
        if let payload: Data = try? JSONEncoder().encode(message) {
            sendMessage(payload, message: .LoadMessage)
        }
    }
    func sendPhysicsData(physicsData: PhysicsData, size: CGSize, id: UUID) {
        let message = PhysicsDataWrapper(physicsData: physicsData, id: id, size: size)
        if let payload: Data = try? JSONEncoder().encode(message) {
            sendMessage(payload, message: .UpdatePhysics)
        }
    }
    
    func sendMoveCommand(location: CGPoint, size: CGSize, id: UUID) {
        let moveMessage = MoveMessageType(location: location, id: id, size: size)
        if let payload: Data = try? JSONEncoder().encode(moveMessage) {
            sendMessage(payload, message: .MoveObject)
        }
    }
    
    func sendDefinition(definition: ItemDefinition, location: CGPoint, size: CGSize, id: UUID) {
        let message = PeerMessage(definition: definition, location: location, size: size, id: id)

        if let payload: Data = try? JSONEncoder().encode(message) {
            sendMessage(payload, message: .PlaceObject)
        }
    }
   
    let service:PhysicsSharingService
    init(globalOptions: GlobalOptions) {
        service = PhysicsSharingService()
        peerHolder = PeerHolder()
        peersHolder = PeersHolder()
        self.globalOptions = globalOptions
        self.messageAcknowledgement = [:]
        service.delegate = self

    }
    
}


class PhysicsSharingService : NSObject {
    private let ColorServiceType = "tictactoe"
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    private let serviceBrowser : MCNearbyServiceBrowser
    var delegate : PhysicsSharingServiceDelegate?
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
        
        
    }()
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: ColorServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: ColorServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
    }
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
        
    }
    func send(peerMessage : Data) {
    
        NSLog("%@", "sendPeerMessage: \(peerMessage) to \(session.connectedPeers.count) peers,\(session.connectedPeers.self)")
        if session.connectedPeers.count > 0 {
            do {
                try self.session.send(peerMessage, toPeers: session.connectedPeers, with: .reliable)
                
            }catch
                let error
            {
                NSLog("%@", "Error for sending: \(error)")
                
            }
        }
    }
}
extension PhysicsSharingService : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
        
    }
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
        
    }
    
}

extension PhysicsSharingService : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
        
    }
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        
    }
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        
    }
}

extension PhysicsSharingService : MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices:session.connectedPeers)
        
    }
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let str = String(data: data, encoding: .utf8)!
        self.delegate?.levelReceived(manager: self, peerMessage: str)
        
    }
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
        
    }
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
        
    }
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
        
    }
    
}

