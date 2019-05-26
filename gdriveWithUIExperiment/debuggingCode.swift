//
//  debuggingCode.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/25/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Cocoa

func basicLocalhostCall() {
    fetch(url: "http://localhost:8888/", queries: ["Foo": "Bar"], callback: {print($0)})
}

func testUploadFormat() {
    let testRequest = MultipartRelatedUpload(testString: "this is a test string body").composeRequest()
    print("\n\nHEADERS: \n\n")
    print(testRequest.allHTTPHeaderFields!)
    print("\n\nBODY: \n\n")
    print(String(decoding: testRequest.httpBody!, as: UTF8.self))
    print("\n\nURL: \n\n")
    print(testRequest.url!)
    print("\n\nmethod: \n\n")
    print(testRequest.httpMethod!)
}

func testInLocalEchoServer(){
    let dialog = NSOpenPanel()
    dialog.title = "choose file"
    dialog.showsResizeIndicator = true
    dialog.showsHiddenFiles = true
    dialog.canChooseDirectories = false
    dialog.canCreateDirectories = false
    dialog.allowsMultipleSelection = false
    dialog.allowedFileTypes = ["docx"]
    
    if (dialog.runModal() == NSApplication.ModalResponse.OK) {
        
        let result = dialog.url!
        // NOW UPLOAD IT HERE.
        let request = MultipartRelatedUpload(result)
        request.post(callback: {print(String(data: $0, encoding: .utf8)!)}, testing: true)
        
    } else {
        // User clicked on "Cancel"
        return
    }
}
