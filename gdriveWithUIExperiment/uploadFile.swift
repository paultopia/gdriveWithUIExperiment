//
//  uploadFile.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/17/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

// DOES NOT WORK, NOT SURE WHY --- just gets a 400 error from the server.  Probably the request is coming out malformed.

import Cocoa



// IN PROGRESS

struct GDriveFileProperties: Codable {
    //var parents: [String] = ["appDataFolder"]
    var mimetype: String = "application/vnd.google-apps.document"
    var name: String
    
    init(_ file: URL,
         //parents: [String]? = nil,
         mimetype: String? = nil,
         name: String? = nil) {
        //if let p = parents {
        //    self.parents = p
        //}
        if let m = mimetype {
            self.mimetype = m
        }
        if let n = name {
            self.name = n
        } else {
            self.name = file.deletingPathExtension().lastPathComponent
        }
    }
    // FOR CHECKING FORMAT
    init(testString: String){
        name = "This is test filename for gdrive metadata"
    }
    
}


struct MultipartUploadPart {
    static var requiredHeaders = ["Content-Disposition": "form-data"]
    var headers: [String: String]
    let body: Data
    init(metadata: GDriveFileProperties) {
        headers = ["Content-Type": "application/json; charset=UTF-8"]
        //let encoder = JSONEncoder()
        //body = try! encoder.encode(metadata)
        body = "{\"name\":\"testfile\",\"mimeType\":\"application/vnd.google-apps.document\"}".data(using: .utf8)!
    }
    
    init(media: URL, mimetype: String) {
        headers = ["Content-Type": mimetype]
        body = try! Data(contentsOf: media)
    }
    
    // FOR TESTING
    init(fakeMedia: String, testMimetype: String){
        headers = ["Content-Type": testMimetype]
        body = fakeMedia.data(using: .utf8)!
    }
    
    func printHeader() -> String {
        let arr = headers.map({key, value in
            "\(key): \(value)"
        })
        return arr.joined(separator: "\r\n")
    }
}


extension Data {
    mutating func append(_ str: String){
        self.append(str.data(using: .utf8)!)
    }
}

struct MultipartRelatedUpload {
    static var endpoint = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
    var headers: [String: String]
    var boundary: String
    var metadataPart: MultipartUploadPart
    var mediaPart: MultipartUploadPart
    var mimetype: String = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    
    static func lineBreak() -> String {
        return "\r\n"
    }
    static func lineBreak(_ count: Int) -> String {
        return String(repeating: "\r\n", count: count)
    }
    
    static func processUploadedDocument(incoming: Data){
        let response = parseUploadResponse(json: incoming)
        let id = response.id
        print(id)
        print(response.mimeType)
        print(response.name)
        hackishGlobalState.uploadedFileID = id
    }
    
    
    init(_ wordFile: URL){
        let bdry = UUID().uuidString
        boundary = "--\(bdry)"
        self.headers = ["Content-Type": "multipart/related; boundary=\(bdry)"]
        let metadata = GDriveFileProperties(wordFile)
        metadataPart = MultipartUploadPart(metadata: metadata)
        mediaPart = MultipartUploadPart(media: wordFile, mimetype: self.mimetype)
    }
    
    // FOR TESTING
    init(testString: String){
        let bdry = UUID().uuidString
        boundary = "--\(bdry)"
        self.headers = ["Content-Type": "multipart/related; boundary=\(bdry)"]
        let metadata = GDriveFileProperties(testString: "This is test file properties, should not print")
        metadataPart = MultipartUploadPart(metadata: metadata)
        mediaPart = MultipartUploadPart(fakeMedia: testString, testMimetype: "this is a fake mimetype for the file")
    }
    
    func makeEndpoint() -> URL {
        guard let token = accessToken.get() else {
            print("error: can't get access token")
            // HORRIBLE HACK to not propagate optionals everywhere
            return URL(string: "http://does.not.work")!
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.googleapis.com"
        components.path = "/upload/drive/v3/files"
        components.queryItems = [
            URLQueryItem(name: "uploadType", value: "multipart"),
            URLQueryItem(name: "access_token", value: token)
        ]
        guard let url = components.url else {
            print("still could not construct url")
            return URL(string: "http://does.not.work")!
        }
        return url
    }
    

    func buildBody() -> Data {
        var body = Data()
        body.append(boundary)
        body.append(MultipartRelatedUpload.lineBreak())
        body.append(metadataPart.printHeader())
        body.append(MultipartRelatedUpload.lineBreak(2))
        body.append(metadataPart.body)
        body.append(MultipartRelatedUpload.lineBreak())
        // BEGIN PART 2: MEDIA
        body.append(boundary)
        body.append(MultipartRelatedUpload.lineBreak())
        body.append(mediaPart.printHeader())
        body.append(MultipartRelatedUpload.lineBreak(2))
        body.append(mediaPart.body)
        body.append(MultipartRelatedUpload.lineBreak())
        body.append(boundary)
        body.append("--")
        return body
    }
    
    func composeRequest(testing: Bool = false) -> URLRequest {
        
        var request = testing ? URLRequest(url: URL(string: "http://localhost:8888/")!) : URLRequest(url: makeEndpoint())
        request.httpMethod = "POST"
        headers.forEach({key, value in
            request.setValue(value, forHTTPHeaderField: key)
        })
        request.httpBody = buildBody()
        return request
    }
    
    func post(callback:@escaping (Data) -> Void, testing: Bool = false){
        let session = URLSession.shared
        let request = composeRequest(testing: testing)
        let task = session.dataTask(with: request, completionHandler: {data, response, error in
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            let resp = response as! HTTPURLResponse
            guard (200...299).contains(resp.statusCode) else {
                print("Server error: \(resp.statusCode)")
                print(error)
                print(response)
                print(data)
                return
            }
            callback(data!)
        })
        task.resume()
    }
}


func uploadWordDocument(){
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
        request.post(callback: MultipartRelatedUpload.processUploadedDocument)
        
    } else {
        // User clicked on "Cancel"
        return
    }
}

