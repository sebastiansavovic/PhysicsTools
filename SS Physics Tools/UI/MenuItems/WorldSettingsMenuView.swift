//
//  WorldSettingsMenuView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/23/21.
//

import SwiftUI

struct WorldSettingsMenuView: View, MenuItemTemplate {
    var title: String
    @ObservedObject var dampening:DampeningOptions
    @ObservedObject var gravity: Gravity
    @ObservedObject var globalOptions: GlobalOptions
    init(title: String) {
        self.title = title
        
        dampening = DampeningOptions()
        globalOptions = GlobalOptions()
        gravity = Gravity()
        self.isGravityManual = false
        self.dampening = physicsManager.dampening
        self.gravity = physicsManager.gravity
        self.globalOptions = physicsManager.globalOptions
        self.isGravityManual = self.gravity.isGravityManual
    }
    @State var isGravityManual:Bool
  
    @Dependency(PhysicsManager.self) var physicsManager: PhysicsManager
    
    
    
    var body: some View {
        VStack (alignment: .leading) {
            Form {
                Section(header: Text("Gravity"), content: {
                    HStack {
                        Text("Modifier \(self.gravity.gravityModifier.toString())")
                        Slider(value: $gravity.gravityModifier.onChange(physicsManager.setGravityModifier), in: 0...20).padding()
                    }
                })
                Section(header: Text("Gravity Direction"), content: {
                    VStack {
                        Toggle(isOn: $isGravityManual.onChange(self.toggleManualGravity), label: {
                            Text("Manual")
                        })
                        Divider()
                        CircleMenuItem().padding(.leading, 50)
                    }
                    
                })
                Section(header: Text("Global Settings"), content: {
                    Toggle(isOn: $globalOptions.boundaryDestroys, label: {
                        Text("Despawn on boundary")
                    })
                    Toggle(isOn: $globalOptions.publishToPeers, label: {
                        Text("Enable Peer")
                    })
                    Toggle(isOn: $globalOptions.showPhysics, label: {
                        Text("Show Physics")
                    })
                   
                    HStack {
                        Text("Size: \(self.globalOptions.fontSize.toString())")
                        Slider(value: $globalOptions.fontSize, in: 8...16)
                    }
                })
                Section(header: Text("Linear Dampening"), content: {
                    HStack{
                        Text("\(self.dampening.linearDampening.toString())")
                        Slider(value: $dampening.linearDampening)
                    }
                })
                Section(header: Text("Angular Dampening"), content: {
                    HStack{
                        Text("\(self.dampening.angularDampening.toString())")
                        Slider(value: $dampening.angularDampening)
                    }
                })
            }
        }.navigationBarTitle(title, displayMode: .inline)
        .onDisappear(perform: {
            self.toggleManualGravity(false)
        })
    }
    func toggleManualGravity(_ newValue: Bool) {
        self.physicsManager.setMotion(disabled: newValue)
    }
}

struct WorldSettingsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{ WorldSettingsMenuView(title: "World Settings") }
    }
}
