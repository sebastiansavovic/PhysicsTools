//
//  MenuView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import SwiftUI





struct MenuView: View {
    let menuBuilder = MenuBuilder()
    @Dependency(AssetManager.self) var assetManager: AssetManager
    @Dependency(PhysicsManager.self) var physicsManager: PhysicsManager
    
    
    var menuItems: [MenuItem] {
        get {
            [MenuItem(id: "World Settings", menuType: .WorldSettings),
             MenuItem(id: "Creation Mode", menuType: .SelectionType),
             MenuItem(id: "Peer Sharing", menuType: .Peer),
             MenuItem(id: "File", menuType: .File),
             MenuItem(id: "Glossary", menuType: .Glossary)]
        }
    }
    
    
    let mainSizeDefinitions: MainSizeDefinitions
    var body: some View {
  
            VStack {
                Text("Physics Tools").font(.title)
               
                NavigationView {
                    List(menuItems) { item in
                        NavigationLink(
                            destination: menuBuilder.getDestination(menu: item),
                            label: {
                                Text(item.id)
                            })
                    }.navigationBarTitle("")
                    .navigationBarHidden(true)
                
                    
                }.navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarHidden(true)
            }
        
    }
}


struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(mainSizeDefinitions: MainSizeDefinitions())
    }
}


