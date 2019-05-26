//
//  downloadPDF.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/26/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

func makeDestinationURL() -> URL {
    let inURL = hackishGlobalState.chosenFile!
    let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    let filename = inURL.deletingPathExtension().appendingPathExtension("pdf").lastPathComponent
    print(filename)
    let outURL = downloadsDirectory.appendingPathComponent(filename, isDirectory: false)
    return outURL
}

func copyTempPDF(tempFile: URL, destination: URL){
    let fileManager = FileManager.default
    try! fileManager.copyItem(at: tempFile, to: destination)
}

public func createTempPDFFile(contents: Data) -> URL {
    let fileManager = FileManager.default
    let dest = fileManager.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("pdf")
    
    try! contents.write(to: dest)
    return dest
}

func downloadCurrentFile(){
    let fileID = hackishGlobalState.uploadedFileID!
    let endpoint = "https://www.googleapis.com/drive/v3/files/\(fileID)/export"
    let token = accessToken.get()!
    let authQuery = URLQueryItem(name: "access_token", value: token)
    let mimeQuery = URLQueryItem(name: "mimeType", value: "application/pdf")
    var urlComponents = URLComponents(string: endpoint)!
    urlComponents.queryItems = [authQuery, mimeQuery]
    let address = urlComponents.url!
    let session = URLSession.shared
    let task = session.dataTask(with: address, completionHandler: {data, response, error in
        if error != nil || data == nil {
            print("Client error!")
            return
        }
        
        let resp = response as! HTTPURLResponse
        guard (200...299).contains(resp.statusCode) else {
            print("Server error: \(resp.statusCode)")
            print(String(data: data!, encoding: .utf8)!)
            print(response)
            return
        }
        print("success!")
        print("ABOUT TO PRINT DATA FILE")
        let temp = createTempPDFFile(contents: data!)
        let dest = makeDestinationURL()
        copyTempPDF(tempFile: temp, destination: dest)
        print(dest.absoluteString)
    })
    task.resume()
}
