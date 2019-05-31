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
    
    
    @IBAction func lastFileButtonPressed(_ sender: Any) {
        getLastFileHeader()
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

