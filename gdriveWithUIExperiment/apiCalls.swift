//
//  apiCalls.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation



public func askForAuthorization(key: String){ // returns the entire freaking web page as a string infruratingly.
    let endpoint = "https://accounts.google.com/o/oauth2/v2/auth"
    let queries = ["client_id": key,
                   "redirect_uri": "io.gowder.experiment:/oauth",
                   "response_type": "code",
                   "scope": "https://www.googleapis.com/auth/drive.metadata.readonly https://www.googleapis.com/auth/drive.appdata"]
    fetch(url: endpoint, queries: queries, callback: displayReceivedPage)
}

func saveTokens(_ tokenJSON: String) {
    let tokens = parseJson(json: tokenJSON.data(using: .utf8)!)
    accessToken.set(tokens.accessToken)
    refreshToken.set(tokens.refreshToken)
    print("got access token:")
    print(accessToken.get())
}

public func tradeAuthCodeForAccessToken(authCode: String){ 
    let endpoint = "https://www.googleapis.com/oauth2/v4/token"
    let queries = ["code": authCode,
                   "client_id": clientKey.get()!,
                   "redirect_uri": "io.gowder.experiment:/oauth",
                   "grant_type": "authorization_code"]
    post(url: endpoint, queries: queries, callback: saveTokens)
    
}

func getLastFileHeader() {
    guard let token = accessToken.get() else {
        print("no access token")
        return
    }
    
    let endpoint = "https://www.googleapis.com/drive/v3/files"
    let queries = ["access_token": token,
                   "orderBy": "createdTime desc",
                   "pageSize": "1"]
    fetch(url: endpoint, queries: queries, callback: {print($0)})
}
