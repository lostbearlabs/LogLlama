//
//  ResultsViewController.swift
//  LogLlama
//
//  Created by Eric Johnson on 9/18/19.
//  Copyright © 2019 Lost Bear Labs. All rights reserved.
//

import Cocoa

class ResultsViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLogLinesUpdated(_:)), name: .LogLinesUpdated, object: nil)
    }
    
    @objc private func onLogLinesUpdated(_ notification: Notification) {
        if let update = notification.object as? LogLinesUpdate
        {
            print("LOG LINES UPDATE")
        }
    }
    
}
