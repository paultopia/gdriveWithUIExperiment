//
//  temporaryHTMLFile.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

public func createTempHTMLFile(contents: String) -> URL {
    let fileManager = FileManager.default
    let dest = fileManager.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("html")
    
    try! contents.write(to: dest, atomically: true, encoding: .utf8)
    
    let contentsOfFile = try! String(contentsOf: dest, encoding: .utf8)
    
    print(contentsOfFile)
    return dest
}
