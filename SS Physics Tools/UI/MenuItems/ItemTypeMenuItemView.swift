//
//  ItemTypeMenuItemView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/23/21.
//

import SwiftUI

class SpriteType: Identifiable {
    init(id: ImageName) {
        self.id = id
    }
    let id: ImageName
}

struct ItemTypeMenuItemView: View, MenuItemTemplate {
    @Dependency(AssetManager.self) var assetManager: AssetManager
    var title: String
    init(title: String) {
        self.title = title

        availableItems = [
            SpriteType(id: .WhiteBird),
            SpriteType(id: .Wood_Rectangle_1),
            SpriteType(id: .Wood_Square_1),
            SpriteType(id: .Wood_Circle_1),
            SpriteType(id: .Wood_Triangle_1),
            SpriteType(id: .Wood_Triangle_2),
            SpriteType(id: .Stone_Rectangle_1),
            SpriteType(id: .Stone_Square_1),
            SpriteType(id: .Stone_Circle_1),
            SpriteType(id: .Stone_Triangle_1),
            SpriteType(id: .Stone_Triangle_2),
            SpriteType(id: .Glass_Rectangle_1),
            SpriteType(id: .Glass_Square_1),
            SpriteType(id: .Glass_Circle_1),
            SpriteType(id: .Glass_Triangle_1),
            SpriteType(id: .Glass_Triangle_2),
            SpriteType(id: .SlingShot_1),             
        ]
        
    }

    let availableItems: [SpriteType]
    @State var bodyType: BodyType = BodyType.DynamicBody
    @State var restitution: CGFloat = 0.5
    @State var density: CGFloat = 5.0
    @State var friction: CGFloat = 0.5
    @State var Scale: CGFloat = 1.0
    @State var angle: CGFloat = 0.0
    @State var selectedItem:ImageName = ImageName.None
    var body: some View {
        VStack{
            Form {
                Section(header: Text("Physics"), content: {
                    HStack {
                        Menu {
                            Button {
                                bodyType = .DynamicBody
                                self.updateDefinition()
                            } label: {
                                Text("Dynamic")
                                Image(systemName: "lock.open")
                            }
                            Button {
                                bodyType = .StaticBody
                                self.updateDefinition()
                            } label: {
                                Text("Static")
                                Image(systemName: "lock")
                            }
                        } label: {
                            Text("Body Type").padding(.trailing, 10)
                            
                        }
                        Text("\(self.bodyType.toString())")
                    }
                    HStack {
                        Text("Restitution (\(restitution.toString()))").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $restitution.onChange(self.valueChanged))
                        
                        
                    }
                    HStack {
                        Text("Density \(density.toString())").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $density.onChange(self.valueChanged), in: 0...30)
                    }
                    HStack {
                        Text("Friction \(friction.toString())").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $friction.onChange(self.valueChanged))
                    }
                    HStack {
                        Text("Scale \(Scale.toString())").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $Scale.onChange(self.valueChanged), in: 0.1...5)
                    }
                    HStack {
                        Text("Angle (\(angle.toString()))").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $angle.onChange(self.valueChanged), in: 0...CGFloat.pi*2.0)
                    }
                    
                    
                })
                Section(header: Text("Sprite"), content: {
                    List(availableItems) {
                        item in
                        Image(uiImage: assetManager.getImageByName(name: item.id)!)
                            .resizable().aspectRatio(contentMode: .fit)
                        Button(action: {
                            selectedItem = item.id
                            self.updateDefinition()
                        }, label: {
                            Text(item.id.toString())
                        })
                        if selectedItem == item.id {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                })
            }
        }.navigationBarTitle(title, displayMode: .inline) 
    }
    func updateDefinition() {
        let physicsData = PhysicsData(restition: self.restitution, density: self.density, friction: self.friction, bodyType: self.bodyType, scale: self.Scale, angle: self.angle)
        let itemDefinition = ItemDefinition(imageName: self.selectedItem, physicsData: physicsData)
        self.assetManager.setItemDefinition(itemDefinition: itemDefinition)
    }
    func valueChanged(_ newValue: CGFloat) {
        self.updateDefinition()
    }
}

struct ItemTypeMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemTypeMenuItemView(title: "Item Type")
    }
}
