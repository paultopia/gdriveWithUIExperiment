//
//  networkCalls.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

func fetch(url: String, queries: [String: String], callback:@escaping (String) -> Void) {
    let session = URLSession.shared
    var urlComponents = URLComponents(string: url)!
    urlComponents.queryItems = queries.map {(k, v) in URLQueryItem(name: k, value: v)}
    let address = urlComponents.url!
    let task = session.dataTask(with: address, completionHandler: {data, response, error in
        if error != nil || data == nil {
            print("Client error!")
            return
        }
        
        let resp = response as! HTTPURLResponse
        guard (200...299).contains(resp.statusCode) else {
            print("Server error: \(resp.statusCode)")
            return
        }
        callback(String(data: data!, encoding: .utf8)!)
    })
    task.resume()
}



