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


public func parseJson(json: Data) ->GoogleAuthToken {
    let decoder = JSONDecoder()
    let authToken = try! decoder.decode(GoogleAuthToken.self, from: json)
    return authToken
}
