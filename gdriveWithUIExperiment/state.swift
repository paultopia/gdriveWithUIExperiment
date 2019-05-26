//
//  state.swift
//  gdriveWithUIExperiment
//
//  Created by Paul Gowder on 5/15/19.
//  Copyright © 2019 Paul Gowder. All rights reserved.
//

// this is a horrendous hack because I don't want to have multiple arity for network requests hence can't pass this functionality into the original authorization call.

import Foundation

public class HackishGlobalState {
    public var tempFile: URL? = nil
    public var uploadedFileID: String? = nil
    public var chosenFile: URL? = nil
}

public var hackishGlobalState = HackishGlobalState()
