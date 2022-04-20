//
//  SelectionMenuItemView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/23/21.
//

import SwiftUI


struct SelectionMenuItemView: View, MenuItemTemplate {
    
    let title: String
    @ObservedObject var selectedItem: SelectionHolder
    @ObservedObject var physicsData: UpdatedPhysics
    @State private var showingAlertComment = false
    @ObservedObject var itemDefinition: DefinitionHolder
    let selectionTypes: [SelectionTypeHolder] = [SelectionTypeHolder(id: "None", type: .None),
                                                 SelectionTypeHolder(id: "Move", type: .Move),
                                                 SelectionTypeHolder(id: "Manipulate", type: .Manipulate),
                                                 SelectionTypeHolder(id: "Place", type: .Place)]
    @ObservedObject var extendedProperties: ExtendedPropertiesHolder
    
    
    @ObservedObject var selectionType: CurrentSelectionType
    init(title: String) {
        self.title = title
        self.selectedItem = SelectionHolder()
        self.physicsData = UpdatedPhysics()
        self.selectionType = CurrentSelectionType()
        self.itemDefinition = DefinitionHolder()
        self.extendedProperties = ExtendedPropertiesHolder()
        
        self.itemDefinition = assetManager.itemDefinition
        self.selectionType = assetManager.currentSelectionType
        self.physicsData = assetManager.selectedObject.physicsData
        self.selectedItem = assetManager.selectedObject
        
        self.extendedProperties = assetManager.selectedObject.extendedProperties
        
        
        
    }
    
    @Dependency(FileSystemManager.self) var fileSystemManager: FileSystemManager
    @Dependency(AssetManager.self) var assetManager: AssetManager
    @Dependency(PhysicsSharingManager.self) var physicsSharingManager: PhysicsSharingManager
    var body: some View {
        Form {
            Section(header: Text("General"), content: {
                Button(action: {
                    self.fileSystemManager.filesHolder.selectedFile = nil
                    self.assetManager.clearWorld()
                    
                }, label: {
                    Text("Clear World")
                })
            })
            Section(header: Text("Selection Type"), content: {
                HStack {
                    Menu {
                        Button {
                            self.selectionType.type = .Move
                        } label: {
                            Text("\("Move")")
                        }
                        Button {
                            self.selectionType.type = .Manipulate
                        } label: {
                            Text("\("Manipulate")")
                        }
                        Button {
                            self.selectionType.type = .Place
                        } label: {
                            Text("\("Place")")
                        }
                        Button {
                            self.selectionType.type = .Pause
                        } label: {
                            Text("\("Pause")")
                        }
                        
                    } label: {
                        Text("Type").padding(.trailing, 20)   
                    }
                    Text("\(self.selectionType.type.rawValue)")
                    
                }
            })
            if self.selectionType.type == .Place {
                Section(header: Text("Switch Selection"), content: {
                    VStack {
                        
                        
                        NavigationLink(
                            destination: ItemTypeMenuItemView(title: "Switch Type"),
                            label: {
                                Text("Switch Type")
                            })
                    }
                    .navigationBarHidden(false)
                    
                })
                
                if let definition = self.itemDefinition.definition {
                    Section(header: Text("Current Selection"), content: {
                        HStack {
                            Button(action: {
                                self.showingAlertComment = true
                            }, label: {
                                Text("Type \(definition.imageName.toString())").padding(.trailing, 20)
                            }).alert(isPresented: $showingAlertComment) {
                                Alert(title: Text("details"), message: Text(definition.getDescription()), dismissButton: .default(Text("ok")))
                            }
                        }
                    })
                }
                
            }
            if let gameobject = self.selectedItem.gameObject {
                Section(header: Text("Remove"), content: {
                    Button(action: {
                        gameobject.removeFromParent()
                    }, label: {
                        Text("Remove selected")
                    })
                })
                Section(header: Text("Selected Item \(gameobject.definition.imageName.toString())"), content: {
                    HStack {
                        Menu {
                            Button {
                                selectedItem.physicsData.bodyType = .DynamicBody
                                self.updateDefinition()
                            } label: {
                                Text("Dynamic")
                                Image(systemName: "lock.open")
                            }
                            Button {
                                selectedItem.physicsData.bodyType = .StaticBody
                                self.updateDefinition()
                            } label: {
                                Text("Static")
                                Image(systemName: "lock")
                            }
                        } label: {
                            Text("Body Type").padding(.trailing, 10)
                        }
                        Text("\(physicsData.bodyType.toString())")
                    }
                    HStack {
                        Text("Density \(selectedItem.physicsData.density.toString())").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $selectedItem.physicsData.density.onChange(self.valueChanged), in: 0...30)
                    }
                    HStack {
                        Text("Friction \(selectedItem.physicsData.friction.toString())").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $selectedItem.physicsData.friction.onChange(self.valueChanged))
                    }
                    HStack {
                        Text("Scale \(selectedItem.physicsData.scale.toString())").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $selectedItem.physicsData.scale.onChange(self.valueChanged), in: 0.1...5)
                    }
                    HStack {
                        Text("Restitution (\(selectedItem.physicsData.restition.toString()))").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $selectedItem.physicsData.restition.onChange(self.valueChanged))
                    }
                    HStack {
                        Text("Angle (\(selectedItem.physicsData.angle.toString()))").frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .leading)
                        Slider(value: $selectedItem.physicsData.angle.onChange(self.valueChanged), in: (-CGFloat.pi)...CGFloat.pi)
                    }
                    HStack {
                        Text("Mass \(physicsData.mass.toString())")
                    }
                    HStack {
                        Text("Angular Velocity \(physicsData.angularVelocity.toString())")
                    }
                    HStack {
                        Text("Velocity \(physicsData.velocity.dx.toString()), \(physicsData.velocity.dy.toString())")
                    }
                    
                })
                if self.extendedProperties.extendedProperties.count > 0 {
                    Section(header: Text("Extended Properties"), content: {
                        ForEach(Array(extendedProperties.extendedProperties.keys), id: \.self) { item in
                            HStack {
                                if let value = self.extendedProperties.extendedProperties[item] {
                                    Text("\(item): \(value.toString())")
                                    Slider(value: self.binding(for: item), in: self.binding(for: item, isStart: true)...self.binding(for: item, isStart: false))
                                }
                            }
                        }
                        
                    })
                }
            }
        }.navigationBarTitle(title, displayMode: .inline)
    }
    private func binding(for key: String) -> Binding<CGFloat> {
        return .init(
            get: { self.extendedProperties.extendedProperties[key, default: 0.0] },
            set: { self.extendedProperties.extendedProperties[key] = $0 })
    }
    private func binding(for key: String, isStart: Bool) -> CGFloat {
        let value = self.extendedProperties.extendedPropertyRanges[key, default: (0.0, 1.0)]
        if isStart {
            return value.0
        }
        return value.1
    }
    func valueChanged(_ newValue: CGFloat) {
        self.updateDefinition()
    }
    func updateDefinition() {
        if let gameObject = self.selectedItem.gameObject {
            let physics = self.selectedItem.physicsData
            gameObject.definition.physicsData = PhysicsData(restition: physics.restition, density: physics.density, friction: physics.friction, bodyType: physics.bodyType, scale: physics.scale, angle: physics.angle)
            gameObject.size.height = gameObject.rectangleDefinition.rectangle.height * physics.scale
            gameObject.size.width = gameObject.rectangleDefinition.rectangle.width * physics.scale
            assetManager.getPhysicsBody(sprite: gameObject, definition: gameObject.rectangleDefinition, physicsData: gameObject.definition.physicsData)
            physicsSharingManager.sendPhysicsData(physicsData: gameObject.definition.physicsData, size: CGSize(width: 0, height: 0), id: gameObject.id)
            selectedItem.physicsData.bodyType = gameObject.physicsBody?.isDynamic ?? false ? .DynamicBody : .StaticBody
            
            selectedItem.physicsData.mass = gameObject.physicsBody?.mass ?? 0
        }
    }
}

struct SelectionMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{ SelectionMenuItemView(title: "Selection Type") }
    }
}
