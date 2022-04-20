//
//  FileModels.swift
//  SS Physics Tools
//
//  Created by Sebastian Savovic on 6/4/21.
//

import Foundation

class UrlHolder: Identifiable {
    let id: String
    let url: URL
    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}
class FilesHolder : ObservableObject {
    @Published var selectedFile: UrlHolder? = nil
    @Published var files: [UrlHolder] = []
    @Published var demos: [UrlHolder] = []
}
