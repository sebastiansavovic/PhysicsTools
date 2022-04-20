//
//  Application.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/22/21.
//

import Foundation
import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      
        let assetManager = AssetManager()
        let physicsManager = PhysicsManager()
        let physicsSharingService = PhysicsSharingManager(globalOptions: physicsManager.globalOptions)
        let fileSystemManager = FileSystemManager()
        fileSystemManager.firstRun()
        Resolver.register(AssetManager.self, value: assetManager)
        Resolver.register(PhysicsManager.self, value: physicsManager)
        Resolver.register(PhysicsSharingManager.self, value: physicsSharingService)
        Resolver.register(FileSystemManager.self, value: fileSystemManager)
        
        return true
    }
}


typealias Dismissed = () -> Bool

///
/// from https://github.com/ivlevAstef/DITranquillity but taken appart, so likely applying differently than original
/// eliminated the code that I did not need, eliminated the need to be a package as all I needed are these 2 classes, eliminated the inject to particular view, as it seemed it defeated the purpose
@propertyWrapper
public struct Dependency<Target, Value> {
    public init(_ type: Target.Type) {}
    
    public var wrappedValue: Value {
        Resolver.resolve(Target.self)!
    }
}

public struct Resolver {
    public typealias Factory<Value> = () -> Value
    
    private static var factories: [ObjectIdentifier: [ObjectIdentifier: Factory<Any>]] = [:]
    public static func resolve<Target, Value>(
        _ target: Target.Type = Target.self,
        value: Value.Type = Value.self) -> Value? {
        factories[.init(target)]?[.init(value)]?() as? Value
    }
    
    public static func register<Target>(
        _ target: Target.Type = Target.self,
        value: @autoclosure @escaping Factory<Target>) {
        let targetKey = ObjectIdentifier(target)
        register(targetKey: targetKey, value: value)
    }
    
    private static func register(
        targetKey: ObjectIdentifier,
        value: @escaping Factory<Any>) {
        if factories[targetKey] == nil {
            factories[targetKey] = [targetKey: value]
        } else {
            factories[targetKey]![targetKey] = value
        }
    }
    
    public static func clear() {
        factories = [:]
    }
}

class MyLog {
    static func debug(_ message: String, file: String = #file, line: Int = #line, function: String = #function)  {
        NSLog("\(file):\(line) : \(function) (\(message))")
    }
}

extension UIScreen{
    //From stack overflow, the 10.0 bellow did not seem to make a difference in the simulator I do not have a physical device with a notch
    //5.0 had no padding, 10,15 and 20 had the same padding
    static var hasNotch: Bool {
          guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
          if UIDevice.current.orientation.isPortrait {
              return window.safeAreaInsets.top >= 44
          } else {
              return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
          }
      }
    static var screenWidth:CGFloat {
        get {
            let bottom: CGFloat = UIScreen.hasNotch ? 10.0 : 0.0
            return UIScreen.main.bounds.size.width - bottom
        }
    }
    static var screenHeight:CGFloat {
        get {
            return UIScreen.main.bounds.size.height
        }
    }

    static var screenSize: CGSize {
        get {
            return UIScreen.main.bounds.size
        }
    }
}


extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(get: {self.wrappedValue},
                set: { newValue in
                    self.wrappedValue = newValue
                    handler(newValue)
                })
    }
}



extension CGFloat {
    func toString() -> String {
        return String(format: "%.2f", self)
    }
}


extension UIWindow {

    override open var canBecomeFirstResponder: Bool {
        return true
    }

    override open func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            print("motion shake")
        }
    }
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        NSLog("motionEnded")
    
    }
}
