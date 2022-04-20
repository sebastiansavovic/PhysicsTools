//
//  MenuBuilder.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/23/21.
//

import SwiftUI

enum MenuType: String {
    case WorldSettings
    case SelectionType
    case ItemType
    case Peer
    case File
    case Glossary
}
struct MenuItem: Identifiable {
    let id: String
    let menuType: MenuType
    
    init(id: String, menuType: MenuType) {
        self.id = id
        self.menuType = menuType
    }
}

struct MenuBuilder {
    
    @ViewBuilder
    func getDestination(menu: MenuItem) -> some View {
        switch(menu.menuType) {
        case MenuType.WorldSettings:
            WorldSettingsMenuView(title: menu.id)
        case MenuType.SelectionType:
            SelectionMenuItemView(title: menu.id)
        case MenuType.ItemType:
            ItemTypeMenuItemView(title: menu.id)
        case MenuType.Peer:
            PeerMenuItemView(title: menu.id)
        case MenuType.File:
            FileSystemMenuItemView(title: menu.id)
        case MenuType.Glossary:
            GlossaryMenuItemView(title: "Glossary")
        }
    }
    
    
}
