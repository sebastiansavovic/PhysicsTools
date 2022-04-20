//
//  FileSystemMenuItemView.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 6/4/21.
//

import SwiftUI

struct FileSystemMenuItemView: View, MenuItemTemplate {
    var title: String
    @State var fileName: String
    @State private var isEditing = false
    @State private var isAlert = false
    @State private var validationFailed = false
    @ObservedObject var filesHolder: FilesHolder
    @State var overWrite = false
    @State var message = ""
    
    @Dependency(FileSystemManager.self) var fileSystemManager:FileSystemManager
    
    init(title: String) {
        self.title = title
        self.fileName = ""
        self.filesHolder = FilesHolder()
        self.filesHolder = self.fileSystemManager.filesHolder
    }
    fileprivate func SaveFile(_ fileName: String, _ overWrite: Bool) {
        MyLog.debug("Saving... \(overWrite)")
        let name =  fileName != "" ? fileName : self.fileName
        
        if name == ""  {
            self.message = "File name is required"
            self.validationFailed = true
        }
        else if !self.fileSystemManager.validateName(name: name)
        {
            self.message = "Invalid Name"
            self.validationFailed = true
        }
        else if !overWrite &&
                    self.fileSystemManager.fileExists(name: name) {
            self.message = "File name already exists"
            self.validationFailed = true
        }
        else if !self.fileSystemManager.saveFile(name: name){
            self.message = "File could not be saved"
            self.validationFailed = true
        }
        else {
            self.message = "File saved"
        }
        self.isAlert = true
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Form {
                Section(header: Text("Load"), content: {
                    List(self.filesHolder.files) { item in
                        Button(action: {
                            let _ = self.fileSystemManager.loadFile(url: item)
                        }, label: {
                            Text(item.id)
                        })
                    }
                })
                Section(header: Text("Demos"), content: {
                    List(self.filesHolder.demos) { item in
                        Button(action: {
                            let _ = self.fileSystemManager.loadFile(url: item)
                        }, label: {
                            Text(item.id)
                        })
                    }
                })
                if let selected = self.filesHolder.selectedFile {
                    Section(header: Text("Update File"), content: {
                        Text(selected.id)
                        Button(action: {
                            self.SaveFile(selected.id, true)
                        }, label: {
                            Text("Save")
                        })
                    })
                }
                Section(header: Text("Save"), content: {
                    TextField("File Name", text: $fileName)
                    { isEditing in
                        self.isEditing = isEditing
                    }
                    CheckView(isChecked: overWrite, title: "Overwrite", action: {
                        newValue in
                        self.overWrite = newValue
                    })
                    Button(action: {
                        SaveFile("", self.overWrite)
                    }) {
                        HStack {
                            Image(systemName: "doc")
                            Text("Save")
                        }
                    }
                    .cornerRadius(8)
                    .alert(isPresented: $isAlert) { () -> Alert in
                        MyLog.debug("Showing alert")
                        if self.validationFailed {
                            return Alert(title: Text("Files"), message: Text(message))
                        }
                        
                        return Alert(title: Text("Files"), message: Text(message), primaryButton: .default(Text("Okay"), action: {
                            print("Okay Click")
                        }), secondaryButton: .default(Text("Dismiss")))
                    }
                    
                })
            }
        }.navigationBarTitle(title, displayMode: .inline)
    }
}

struct FileSystemMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        FileSystemMenuItemView(title: "File")
    }
}
