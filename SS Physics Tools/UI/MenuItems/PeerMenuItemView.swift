//
//  PeerMenuItemView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/23/21.
//
import SwiftUI
import Foundation
import MultipeerConnectivity



struct PeerMenuItemView: View, MenuItemTemplate {
 
    
  
    
    var title: String
   
    @State var backgroundColor: Color
    @ObservedObject var peerHolder: PeersHolder
    
    @Dependency(PhysicsSharingManager.self) var physicsSharingManager: PhysicsSharingManager
 
    func change(color : Color) {
        backgroundColor = color
        
    }
    init(title: String) {
        self.title = title
        self.peerHolder = PeersHolder()
        backgroundColor = .gray
        self.peerHolder = self.physicsSharingManager.peersHolder
    }
    var body: some View {
        ZStack {
           backgroundColor.edgesIgnoringSafeArea(.all)
        
        VStack{
           
            List(peerHolder.peerIds){ item in
                Text(item.id)
            }
           
         
        }.onAppear(perform: {
           
            
        })
        }.navigationBarTitle(title, displayMode: .inline)
    }
}

struct PeerMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        PeerMenuItemView(title: "Peer")
    }
}
