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

// IN PROGRESS

struct multipartHTTPUpload {
    var params: [String: String]
    
    func makeBoundary() -> String {
        // write me
        
        return " "
    }
    
    func authHeader() -> [String: String]? {
        guard let token = accessToken.get() else {
            print("no access token")
            return nil
        }
        return ["Authorization": "Bearer " + token]
    }

}
