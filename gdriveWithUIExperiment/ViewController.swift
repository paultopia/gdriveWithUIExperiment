//
//  ViewController.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var clientID: NSTextField!
    @IBAction func saveCreds(_ sender: Any) {
        let key = clientID.stringValue
        clientKey.set(key)
        print("saved client key")
        print(clientKey.get()!)
        // now jumping direct to authorization
        askForAuthorization(key: key)

    }
    @IBAction func makeAuthRequest(_ sender: Any) {
        askForAuthorization(key: clientKey.get()!)
    }
    
    
    @IBAction func codeToToken(_ sender: Any) {
        let code = authCode.get()!
        tradeAuthCodeForAccessToken(authCode: code)
    }
    
    // THIS IS THE GENERAL BUTTON TO TEST WHATEVER DISCRETE THING I'M WORKING ON
    @IBAction func testBot(_ sender: Any) {
        getLastFileHeader()
        //testUploadFormat()
    }
    
    @IBOutlet var authTokenDirect: NSTextField!
    
    @IBAction func authTokenDirectAdder(_ sender: Any) {
        accessToken.set(authTokenDirect.stringValue)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

