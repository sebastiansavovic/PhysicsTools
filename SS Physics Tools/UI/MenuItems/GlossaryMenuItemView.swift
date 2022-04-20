//
//  GlossaryMenuItemView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 6/4/21.
//

import SwiftUI

struct GlossaryMenuItemView: View, MenuItemTemplate {
    var title: String
    var items: [GlossaryItem] = []
    
    @Dependency(AssetManager.self) var assetManager: AssetManager
    
    init(title: String) {
        self.title = title
        self.items = assetManager.getGlossary()
        
    }
    var body: some View {
        Form{
            List(items) { item in
                NavigationLink(destination:
                                GlossaryDescriptionView(title: item.title, description: item.description)
                               , label: {
                                Text(item.title)
                               })
            }
        }.navigationBarTitle(title, displayMode: .inline)
    }
}

struct GlossaryDescriptionView: View {
    var title: String
    var description: String
    var body: some View {
        VStack(alignment: .leading ){
            Form {
                Text(description)
            }
        }.navigationBarTitle(title, displayMode: .inline)
       
    }
}

struct GlossaryMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        GlossaryMenuItemView(title: "Glossary")
    }
}
