//
//  credentialStorage.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

public func setDefaults(client: String, secret:String){
    let defaults = UserDefaults.standard
    defaults.set(client, forKey: "client")
    defaults.set(secret, forKey: "secret")
}

public func getClient() -> String? {
    let defaults = UserDefaults.standard
    return defaults.string(forKey: "client")
}

public func getSecret() -> String? {
    let defaults = UserDefaults.standard
    return defaults.string(forKey: "secret")
}
