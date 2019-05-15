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
    @IBOutlet var clientSecret: NSTextField!
    @IBAction func saveCreds(_ sender: Any) {
        setDefaults(client: clientID.stringValue, secret: clientSecret.stringValue)
        print(getClient()!)
        fetch(url: "https://gowder.io", callback: {print($0)})
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

