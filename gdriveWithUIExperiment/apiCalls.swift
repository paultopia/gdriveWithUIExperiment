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

func saveRefreshedToken(_ tokenJSON: String) {
    let token = parseRefreshTokenJson(json: tokenJSON.data(using: .utf8)!)
    print("old: \(accessToken.get()!)")
    accessToken.set(token.accessToken)
    print("new: \(accessToken.get()!)")
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

func refreshAccess(callback:@escaping (String) -> Void){
    let endpoint = "https://www.googleapis.com/oauth2/v4/token"
    let queries = ["refresh_token": refreshToken.get()!,
                   "client_id": clientKey.get()!,
                   "grant_type": "refresh_token"]
    post(url: endpoint, queries: queries, callback: callback)
}

func refreshAccess(){
    refreshAccess(callback: saveRefreshedToken)
}

public func refresherCallbackFactory(request: URLRequest, callback:@escaping (Data) -> Void) -> (String) -> Void {
    func tokenTaker(_ tokenJSON: String) {
        let tjParsed = parseRefreshTokenJson(json: tokenJSON.data(using: .utf8)!)
        let token = tjParsed.accessToken
        print("old: \(accessToken.get()!)")
        accessToken.set(token)
        print("new: \(accessToken.get()!)")
        var url = request.url!
        var newRequest = request
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        // just redo the query items from scratch rather than searching through to change it. 
        // this is lazy but I should test it before trying anything fancier. 
        components.queryItems = [
            URLQueryItem(name: "uploadType", value: "multipart"),
            URLQueryItem(name: "access_token", value: token)
        ]
        url = components.url!
        newRequest.url = url
        
        let session = URLSession.shared
        let task = session.dataTask(with: newRequest, completionHandler: {data, response, error in
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
    return tokenTaker
}  

// should refresh the token and try the original call again.
public func retryCall(request: URLRequest, callback:@escaping (Data) -> Void){
    let newPostFunction = refresherCallbackFactory(request: request, callback: callback)
    refreshAccess(callback: newPostFunction)
}


