//
//  SpriteSheet.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SpriteKit

class SpriteSheet {
    let texture: SKTexture

 

    init(texture: SKTexture) {
        self.texture=texture
    }

    

    func textureForColumn(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)->SKTexture? {
       

        var textureRect=CGRect(x: x,
                               y: self.texture.size().height - y - height,
                               width: width,
                               height: height)
        
        textureRect=CGRect(x: textureRect.origin.x/self.texture.size().width, y: textureRect.origin.y/self.texture.size().height,
            width: textureRect.size.width/self.texture.size().width, height: textureRect.size.height/self.texture.size().height)
        return SKTexture(rect: textureRect, in: self.texture)
    }

}
