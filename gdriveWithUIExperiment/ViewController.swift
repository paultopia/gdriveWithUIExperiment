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
        clientKey.set(clientID.stringValue)
        print(clientKey.get()!)

    }
    @IBAction func makeAuthRequest(_ sender: Any) {
        askForAuthorization() // this returns a full html page from google, so need to put it in a temp file an open it...
    }
    
    // THIS IS THE GENERAL BUTTON TO TEST WHATEVER DISCRETE THING I'M WORKING ON
    @IBAction func testBot(_ sender: Any) {
        // test something here.
        
        let tempHTMLFileURL = createTempHTMLFile(contents: "<html><body>TEST!</body></html>")
        openTempHTMLFile(tempHTMLFileURL)
        deleteTempHTMLFile(tempHTMLFileURL)
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

