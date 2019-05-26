//
//  parseIncomingJSON.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

public struct GoogleAuthToken: Codable {
    var accessToken: String
    var expires: Int
    var refreshToken: String
    var scope: String
    var tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expires = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
    }
}

public func parseAuthTokenJson(json: Data) -> GoogleAuthToken {
    let decoder = JSONDecoder()
    let authToken = try! decoder.decode(GoogleAuthToken.self, from: json)
    return authToken
}

//UNTESTED
public struct GoogleRefreshedAuthToken: Codable {
    var accessToken: String
    var expires: Int
    var tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expires = "expires_in"
        case tokenType = "token_type"
    }
}

//UNTESTED
// also this is horrible, but when I try to use a protocol or anything I get a type error that I don't understand.
public func parseRefreshTokenJson(json: Data) -> GoogleRefreshedAuthToken {
    let decoder = JSONDecoder()
    let authToken = try! decoder.decode(GoogleRefreshedAuthToken.self, from: json)
    return authToken
}

public struct UploadResponse: Codable {
    var kind: String
    var id: String
    var name: String
    var mimeType: String
}

public func parseUploadResponse(json: Data) -> UploadResponse {
    let decoder = JSONDecoder()
    let uploadResponse = try! decoder.decode(UploadResponse.self, from: json)
    return uploadResponse
}
