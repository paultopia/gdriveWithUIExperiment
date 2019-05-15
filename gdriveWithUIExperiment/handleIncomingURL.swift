//
//  handleIncomingURL.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Foundation

func extractCode(_ items: [URLQueryItem]) -> String? {
    if let code = items.filter({$0.name == "code"}).first?.value {
        return code
    }
    return nil
}

func parseIncomingURL(_ incoming: URL?) -> String? {
    if let url = incoming {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let items = components.queryItems{
            return extractCode(items)
        }
    }
    return nil
}

public func handleIncomingURL(_ incoming: URL?){
    if let code = parseIncomingURL(incoming){
        authCode.set(code)
        print(authCode.get())
    }
}
