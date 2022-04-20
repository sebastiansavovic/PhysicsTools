//
//  FileSystemManager.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 5/26/21.
//

import Foundation
import UIKit
import Zip

class FileSystemManager {
    let demo = "Demos"
    @Dependency(PhysicsSharingManager.self) var physicsSharingManager: PhysicsSharingManager
    @Dependency(AssetManager.self) var assetManager: AssetManager
    private func removeExtension(_ fileName: String) -> String {
        var components = fileName.components(separatedBy: ".")
        if components.count > 1 { // If there is a file extension
            components.removeLast()
            return components.joined(separator: ".")
        } else {
            return fileName
        }
    }
    fileprivate func ReloadFiles() {
        
        if let urls = FileManager.default.urls(for: .documentDirectory) {
            self.filesHolder.files = urls.filter({
                return !$0.hasDirectoryPath
            }).sorted(by: {
                return self.removeExtension($0.lastPathComponent) < self.removeExtension($1.lastPathComponent)
            }).map({
                return UrlHolder(id: self.removeExtension($0.lastPathComponent), url: $0)
            })
        }
        let demoDir = self.getDocumentsDirectory().appendingPathComponent(demo)
        if let urls = try? FileManager.default.contentsOfDirectory(at: demoDir, includingPropertiesForKeys: nil) {
            self.filesHolder.demos = urls.sorted(by: {
                return self.removeExtension($0.lastPathComponent) < self.removeExtension($1.lastPathComponent)
            }).map({
                return UrlHolder(id: self.removeExtension($0.lastPathComponent), url: $0)
            })
        }
        
    }
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    func firstRun() {
        
        if self.directoryExistsAtPath(self.getDocumentsDirectory().appendingPathComponent(demo).path) {
            return
        }
        let fileName = self.getDocumentsDirectory().appendingPathComponent("\(demo).zip")
        
        do {
            let data =  NSDataAsset(name: demo, bundle: Bundle.main)!.data
            try data.write(to: fileName)
            try Zip.unzipFile(fileName, destination: self.getDocumentsDirectory(), overwrite: false, password: nil)
            try FileManager.default.removeItem(at: fileName)
        } catch {
            MyLog.debug("Could not decompress Files \(error.localizedDescription)")
        }
        self.ReloadFiles()
    }
    init() {
        self.filesHolder = FilesHolder()
        ReloadFiles()
    }
    let filesHolder: FilesHolder
    private func getUserPath(name: String) -> String {
        let path = self.getDocumentsDirectory()
        return path.appendingPathComponent(name).path
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func getTemporaryDirectory() -> URL {
        let paths = NSTemporaryDirectory()
        return URL(string: paths)!
    }
    func fileExists(name: String) -> Bool {
        let path = self.getUserPath(name: name)
        do {
            var _ = try Data(contentsOf: URL(fileURLWithPath: path))
            return true
        }
        catch {
            return false
        }
    }
    func loadFile(url: UrlHolder) -> Bool {
        guard let data = try? Data(contentsOf: url.url) else {return false}
        guard let assets = try? JSONDecoder().decode([AssetDefinition].self, from: data) else {
            return false
        }
        self.filesHolder.selectedFile = url
        self.physicsSharingManager.loadDefinitions(definition: assets)
        self.assetManager.loadDefinitions(definitions: assets)
        return true
    }
    func validateName(name: String) -> Bool {
        let fileName = self.getDocumentsDirectory().appendingPathComponent(name)
        
        let dir = fileName.deletingLastPathComponent()
        
        if dir != self.getDocumentsDirectory() {
            return false
        }
        
        return true
    }
    func saveFile(name: String) -> Bool {
        
        let staticObjects = self.assetManager.getStaticDefinitions()
        if staticObjects.isEmpty {
            return false
        }
        guard let payload: Data = try? JSONEncoder().encode(staticObjects) else {
            return false
        }
        let fileName = self.getDocumentsDirectory().appendingPathComponent("\(name).json")
        
        
        do {
            try payload.write(to: fileName)
        } catch {
            return false
        }
        ReloadFiles()
        return true
    }
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
