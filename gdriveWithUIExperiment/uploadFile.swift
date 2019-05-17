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

//protocol Extendable {}
//extension String: Extendable {}

extension Dictionary {
    func and(_ otherDicts: [Dictionary]) -> Dictionary{
        return otherDicts.reduce(self, { x, y in
            x.merging(y) { (current, _) in current }
        })
    }
}

// IN PROGRESS

struct multipartUploadPart {
    var headers = ["Content-Disposition": "form-data"]
    init(metadata: [String: String]) {
        
    }
    init(media: URL){
        
    }
}


struct multipartRelatedUpload {
    var headers: [String: String]
    var params: [String: String]
    var boundary: String
    var metadataPart: multipartUploadPart
    var mediaPart: multipartUploadPart
    
    init(metadata: [String: String],
         media: URL,
         extraParameters: [String: String]? = nil,
         extraHeaders: [String: String]? = nil) {
        let requiredParameter = ["uploadType":"multipart"]
        if let params = extraParameters {
            self.params = requiredParameter.and([params])
        }
        else {
            self.params = requiredParameter
        }
        
        let bdry = "--\(UUID().uuidString)--"
        boundary = bdry
        let requiredHeader = ["Content-Type": "multipart/related; boundary=\(bdry)"]
        
        if let hdrs = extraHeaders {
            self.headers = requiredHeader.and([hdrs])
        }
        else {
            self.headers = requiredHeader
        }
        
        metadataPart = multipartUploadPart(metadata: metadata)
        mediaPart = multipartUploadPart(media: media)
        
    }
    
    
    func authHeader() -> [String: String]? {
        guard let token = accessToken.get() else {
            print("no access token")
            return nil
        }
        return ["Authorization": "Bearer \(token)"]
    }

}
