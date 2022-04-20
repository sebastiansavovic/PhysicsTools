//
//  CheckView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 6/4/21.
// https://makeapppie.com/2019/10/16/checkboxes-in-swiftui/
//

import SwiftUI

struct CheckView: View {
    @State var isChecked:Bool = false
    var title:String
    func toggle(){
        isChecked = !isChecked
        if let action = self.action {
            action(isChecked)
        }
    }
    var action: ((Bool) -> Void)?
    var body: some View {
        Button(action: toggle){
            HStack{
                Image(systemName: isChecked ? "checkmark.square": "square")
                Text(title)
            }
            
        }
        
    }
}

struct CheckView_Previews: PreviewProvider {
    static var previews: some View {
        CheckView(title: "Checked")
    }
}
