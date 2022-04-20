//
//  ContentView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import SwiftUI
import SpriteKit
import CoreMotion


struct ContentView: View {
    @Dependency(PhysicsManager.self) var physicsManager: PhysicsManager
    let mainSizeDefinitions = MainSizeDefinitions()
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: mainSizeDefinitions.sceneWidth, height: mainSizeDefinitions.fullHeight)
        scene.scaleMode = .fill
        return scene
    }
    var body: some View {
        HStack {
            MenuView(mainSizeDefinitions: mainSizeDefinitions).frame(width: mainSizeDefinitions.menuWidth, height: mainSizeDefinitions.fullHeight, alignment: .top)
            SpriteView(scene: scene)
                .frame(width: mainSizeDefinitions.sceneWidth, height:  mainSizeDefinitions.fullHeight)
                .ignoresSafeArea()
        
        }.onAppear(perform: {
            physicsManager.setupMotion()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
