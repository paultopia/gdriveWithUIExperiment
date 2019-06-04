//
//  downloadPDF.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/26/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

// if you send a second file before the first is done, they both get converted but they end up with the name of the second---need coordination for this.

import Foundation

func makeDestinationURL() -> URL {
    let fileManager = FileManager.default
    let inURL = hackishGlobalState.chosenFile!
    let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    var filename = inURL.deletingPathExtension().appendingPathExtension("pdf").lastPathComponent
    print(filename)
    var outURL = downloadsDirectory.appendingPathComponent(filename, isDirectory: false)
    if fileManager.fileExists(atPath: outURL.path) {
        print("file exists!  adding UUID.")
        filename = outURL.deletingPathExtension().lastPathComponent + "-\(UUID().uuidString).pdf"
        outURL = downloadsDirectory.appendingPathComponent(filename, isDirectory: false)
    }
    return outURL
}

func copyTempPDF(tempFile: URL, destination: URL){
    let fileManager = FileManager.default
    do {
    try fileManager.copyItem(at: tempFile, to: destination)
    } catch {
        print("file error: \(error)")
    }
}

public func createTempPDFFile(contents: Data) -> URL {
    let fileManager = FileManager.default
    let dest = fileManager.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("pdf")
    try! contents.write(to: dest)
    return dest
}

func downloadCurrentFile(deleteOnServer: Bool = true){
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
        if deleteOnServer {
            print("deleting file on server")
            deleteFile(fileID: fileID)
        }
        
    })
    task.resume()
}
