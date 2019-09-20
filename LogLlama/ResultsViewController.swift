//
//  ResultsViewController.swift
//  LogLlama
//
//  Created by Eric Johnson on 9/18/19.
//  Copyright © 2019 Lost Bear Labs. All rights reserved.
//

import Cocoa

class ResultsViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var textCell: NSTextFieldCell!
    
    var lines : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self as? NSTableViewDelegate
        self.tableView.dataSource = self
        self.tableView.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.firstColumnOnlyAutoresizingStyle
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLogLinesUpdated(_:)), name: .LogLinesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onFontSizeUpdated(_:)), name: .FontSizeUpdated, object: nil)
    }
    
    @objc private func onLogLinesUpdated(_ notification: Notification) {
        
        if let update = notification.object as? LogLinesUpdate
        {
            self.lines = []
            for line in update.lines {
                if line.visible {
                    self.lines.append(line.text)
                }
            }
            self.tableView.noteNumberOfRowsChanged()
        }
        
    }
    
    @objc private func onFontSizeUpdated(_ notification: Notification) {
        if let update = notification.object as? FontSizeUpdate
        {
            if let origFont = self.textCell?.font {
                let newFont = NSFont(descriptor: origFont.fontDescriptor, size: CGFloat(update.size))
                self.textCell?.font = newFont
                self.tableView.rowHeight = CGFloat(update.size + 4)
                self.tableView.noteNumberOfRowsChanged()
            }
        }
    }
    
}

extension ResultsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return lines[row]
    }
    
    func tableView(_: NSTableView, shouldEdit: NSTableColumn?, row: Int) -> Bool {
        // TODO: this is not being honored/checked and I don't know why.
        return false
    }
}
