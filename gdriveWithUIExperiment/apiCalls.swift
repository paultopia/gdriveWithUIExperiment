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
                   "scope": "https://www.googleapis.com/auth/drive.metadata.readonly https://www.googleapis.com/auth/drive.appdata https://www.googleapis.com/auth/drive.file"]
    fetch(url: endpoint, queries: queries, callback: displayReceivedPage)
}

func saveTokens(_ tokenJSON: String) {
    let tokens = parseAuthTokenJson(json: tokenJSON.data(using: .utf8)!)
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

//UNTESTED
func saveRefreshedToken(_ tokenJSON: String) {
    let token = parseRefreshTokenJson(json: tokenJSON.data(using: .utf8)!)
    print("old: \(accessToken.get()!)")
    accessToken.set(token.accessToken)
    print("new: \(accessToken.get()!)")
}

// UNTESTED
func refreshAccess(){
    let endpoint = "https://www.googleapis.com/oauth2/v4/token"
    let queries = ["refresh_token": refreshToken.get()!,
                   "client_id": clientKey.get()!,
                   "grant_type": "refresh_token"]
    post(url: endpoint, queries: queries, callback: saveRefreshedToken)
    
}


func deleteFile(fileID: String){
    let endpoint = "https://www.googleapis.com/drive/v3/files/\(fileID)"
    let token = accessToken.get()!
    let query = URLQueryItem(name: "access_token", value: token)
    var urlComponents = URLComponents(string: endpoint)!
    urlComponents.queryItems = [query]
    let address = urlComponents.url!
    var request = URLRequest(url: address)
    request.httpMethod = "DELETE"
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: {data, response, error in
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
        print("successfully deleted file!")
    })
    task.resume()
}

func deleteCurrentFile(){
    deleteFile(fileID: hackishGlobalState.uploadedFileID!)
}

// CURRENTLY THROWING 403 and claiming it can only export google docs.  I'm suspecting this is because it's in the appdata folder?  (no, still isn't working even with nonappdata folder, and upload isn't in fact saying it's a google doc...)



