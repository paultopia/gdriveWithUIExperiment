//
//  uploadFile.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/17/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

extension URLRequest {
    func getSize() -> Int? {
        guard let body = self.httpBody else {
            return nil
        }
        return body.count
    }
}

extension Dictionary {
    func and(_ otherDicts: [Dictionary]) -> Dictionary{
        return otherDicts.reduce(self, { x, y in
            x.merging(y) { (current, _) in current }
        })
    }
}

// IN PROGRESS

struct gDriveFileProperties: Codable {
    var parents: [String] = ["appDataFolder"]
    var mimetype: String = "application/vnd.google-apps.document"
    var name: String
    
    init(_ file: URL,
         parents: [String]? = nil,
         mimetype: String? = nil,
         name: String? = nil) {
        if let p = parents {
            self.parents = p
        }
        if let m = mimetype {
            self.mimetype = m
        }
        if let n = name {
            self.name = n
        } else {
            self.name = file.lastPathComponent
        }
    }
}


struct multipartUploadPart {
    static var requiredHeaders = ["Content-Disposition": "form-data"]
    var headers: [String: String]
    let body: Data
    init(metadata: gDriveFileProperties) {
        let h = multipartUploadPart.requiredHeaders.and([["Content-Type": "application/json; charset=UTF-8"]])
        headers = h
        let encoder = JSONEncoder()
        body = try! encoder.encode(metadata)
    }
    
    init(media: URL, mimetype: String) {
        let h = multipartUploadPart.requiredHeaders.and([["Content-Type": mimetype]])
        headers = h
        body = try! Data(contentsOf: media)
    }
}


extension Data {
    mutating func append(_ str: String){
        self.append(str.data(using: .utf8)!)
    }
}

struct multipartRelatedUpload {
    static var endpoint = "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
    var headers: [String: String]
    var boundary: String
    var metadataPart: multipartUploadPart
    var mediaPart: multipartUploadPart
    var mimetype: String = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    
    static func lineBreak() -> String {
        return "\r\n"
    }
    static func lineBreak(_ count: Int) -> String {
        return String(repeating: "\r\n", count: count)
    }
    
    init(metadata: gDriveFileProperties,
         media: URL,
         extraHeaders: [String: String]? = nil,
         incomingMimeType: String? = nil,
         gdriveMimeType: String? = nil) {
        let bdry = "--\(UUID().uuidString)"
        boundary = bdry
        let requiredHeader = ["Content-Type": "multipart/related; boundary=\(bdry)"]
        if let hdrs = extraHeaders {
            self.headers = requiredHeader.and([hdrs])
        }
        else {
            self.headers = requiredHeader
        }
        if let m = incomingMimeType {
            self.mimetype = m
        }
        
        metadataPart = multipartUploadPart(metadata: metadata)
        mediaPart = multipartUploadPart(media: media, mimetype: self.mimetype)
    }
    
    func makeEndpoint() -> String {
        return "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&access_token=\(accessToken.get()!)>"
    }
    

    func buildBody() -> Data {
        // implement me: basically take every string, including line breaks per examples
        // here https://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.2 and
        // make them UTF-8 and then append them to data
        
        // LEFT TO DO: headers for parts
        var body = Data()
        body.append(boundary)
        body.append(multipartRelatedUpload.lineBreak())
        // TODO: make partwise-headers here for metadata part, like content-disposition and stuff
        body.append(multipartRelatedUpload.lineBreak(2))
        body.append(metadataPart.body)
        body.append(multipartRelatedUpload.lineBreak())
        // BEGIN PART 2: MEDIA
        body.append(boundary)
        body.append(multipartRelatedUpload.lineBreak())
        // TODO: more partswise headers, for media part.
        // ALSO: do I need a "Content-Transfer-Encoding: binary" line here like the example says?!
        // ALSO: do I need a file name in content-disposition?!
        body.append(multipartRelatedUpload.lineBreak(2))
        body.append(mediaPart.body)
        body.append(multipartRelatedUpload.lineBreak())
        body.append(boundary)
        body.append("--")
        return body
    }
    
    func composeRequest() -> URLRequest {
        var request = URLRequest(url: URL(string: makeEndpoint())!)
        request.httpMethod = "POST"
        headers.forEach({key, value in
            request.setValue(value, forHTTPHeaderField: key)
        })
        // USE  request.setValue to set headers, just loop over header dict
        request.httpBody = buildBody()
        return request
    }
}


