//
//  CirecleMenu.swift
//  SS Physics Tools
// Found some of this code on google: https://kavsoft.dev/SwiftUI_2.0/Circular_Slider/
//
//  Created by Sebastian Savovic on 5/23/21.
//

import SwiftUI

struct CircleMenuItem: View {
    @Dependency(PhysicsManager.self) var physicsManager: PhysicsManager
    @State var size:CGFloat = 100.0
    @State var progress : CGFloat = 0
    //@State var angle : Double = 0
    @ObservedObject var gravity: Gravity
    
    init() {
       
        self.gravity = Gravity()
        self.gravity = physicsManager.gravity
    }
    
    var body: some View {
        VStack(alignment: .center){
            
            ZStack{
                
                Circle()
                    .stroke(Color("stroke"),style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .frame(width: size, height: size)
                
               
                
                // Inner Finish Curve...
                
                Circle()
                    .fill(Color("stroke"))
                    .frame(width: 10, height: 10)
                    .offset(x: size / 2)
                    .rotationEffect(.init(degrees: -90))
                
                // Drag Circle...
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(x: size / 2)
                    .rotationEffect(.init(degrees: Double(gravity.angle)))
                // adding gesture...
                    .gesture(DragGesture().onChanged(onDrag(value:)))
                    .rotationEffect(.init(degrees: -90))
                
              
            }
        }
        
    }
    func onDrag(value: DragGesture.Value){
        
        // calculating radians...
        
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        
        // since atan2 will give from -180 to 180...
        // eliminating drag gesture size
        // size = 55 => Radius = 27.5...
        
        let radians = atan2(vector.dy - 27.5, vector.dx - 27.5)
        
        // converting to angle...
        
        var angle = radians * 180 / .pi
        
        // simple technique for 0 to 360...
        
        // eg = 360 - 176 = 184...
        if angle < 0{angle = 360 + angle}
        
        withAnimation(Animation.linear(duration: 0.15)){

            let progress = angle / 360
            self.progress = progress
            let modifier = self.physicsManager.getGravityModifier()
            self.gravity.updateGravity(angle, modifier)
        }
    }
}

struct CirecleMenu_Previews: PreviewProvider {
    static var previews: some View {
        CircleMenuItem()
    }
}
