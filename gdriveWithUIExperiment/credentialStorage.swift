//
//  credentialStorage.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

public struct Credential {
    let defaults = UserDefaults.standard
    var label: String
    
    init(_ l: String) {
        label = l
    }
    
    public func set(_ value: String){
        defaults.set(value, forKey: label)
    }
    
    public func get() -> String? {
        return defaults.string(forKey: label)
    }

}

public let clientKey = Credential("client key")
public let authCode = Credential("authorization code")
public let accessToken = Credential("access token")
public let refreshToken = Credential("refresh token")

