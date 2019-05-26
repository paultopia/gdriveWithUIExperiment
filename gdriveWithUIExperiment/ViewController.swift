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
    
    @IBAction func refreshAuthPressed(_ sender: Any) {
        refreshAccess()
    }
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        uploadWordDocument()
        //testInLocalEchoServer()
        //basicLocalhostCall()
    }
    
    @IBAction func downloadButtonPressed(_ sender: Any) {
        downloadCurrentFile()
    }
    
    
    @IBAction func lastFileButtonPressed(_ sender: Any) {
        getLastFileHeader()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        deleteCurrentFile()
    }
    
    // THIS IS THE GENERAL BUTTON TO TEST WHATEVER DISCRETE THING I'M WORKING ON
    @IBAction func testBot(_ sender: Any) {
        //testInLocalEchoServer()
        
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

