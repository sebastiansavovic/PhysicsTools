//
//  ViewModels.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import SwiftUI


class MainSizeDefinitions {
    let sceneWidthRatio:CGFloat = 0.7
    var  menuWidthRatio: CGFloat {
        get {
            1.0 - sceneWidthRatio
        }
    }
    var sceneWidth: CGFloat {
        get {
            UIScreen.screenWidth * sceneWidthRatio
        }
    }
    var menuWidth: CGFloat {
        get {
            UIScreen.screenWidth * menuWidthRatio
        }
    }
    var fullHeight: CGFloat {
        get {
            UIScreen.screenHeight * 0.9
        }
    }
}
