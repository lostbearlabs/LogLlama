//
//  FilterViewController.swift
//  LogLlama
//
//  Created by Eric Johnson on 9/17/19.
//  Copyright © 2019 Lost Bear Labs. All rights reserved.
//

import Cocoa

class FilterViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onScriptProcessingUpdate(_:)), name: .ScriptProcessingUpdate, object: nil)
    }
    
    @objc private func onScriptProcessingUpdate(_ notification: Notification) {
        if let update = notification.object as? ScriptProcessingUpdate
        {
            print("SCRIPT PROCESSING UPDATE")
        }
    }
    
}
