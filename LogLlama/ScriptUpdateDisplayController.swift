//
//  FilterViewController.swift
//  LogLlama
//
//  Created by Eric Johnson on 9/17/19.
//  Copyright © 2019 Lost Bear Labs. All rights reserved.
//

import Cocoa

class ScriptUpdateDisplayController: NSViewController {
    
    fileprivate enum CellIdentifiers {
        static let TextCell = "TextCellID"
    }
    
    @IBOutlet weak var textCell: NSTextFieldCell!
    @IBOutlet weak var tableView: NSTableView!
    var lines: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self as? NSTableViewDelegate
        self.tableView.dataSource = self
        self.tableView.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.firstColumnOnlyAutoresizingStyle
        
        NotificationCenter.default.addObserver(self, selector: #selector(onScriptProcessingUpdate(_:)), name: .ScriptProcessingUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onFontSizeUpdated(_:)), name: .FontSizeUpdated, object: nil)
    }
    
    @objc private func onFontSizeUpdated(_ notification: Notification) {
        if let update = notification.object as? FontSizeUpdate
        {
            if let origFont = self.textCell?.font {
                let newFont = NSFont(descriptor: origFont.fontDescriptor, size: CGFloat(update.size))
                self.textCell?.font = newFont
                self.tableView.rowHeight = CGFloat(update.size + 2)
                self.tableView.noteNumberOfRowsChanged()
        }
    }
}
    
    @objc private func onScriptProcessingUpdate(_ notification: Notification) {
        if let update = notification.object as? ScriptProcessingUpdate
        {
            if (update.clear) {
                lines.removeAll()
            } else {
                lines.append(update.text)
            }
            
            self.tableView.noteNumberOfRowsChanged()
        }
    }
    
}

extension ScriptUpdateDisplayController: NSTableViewDataSource {
    
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

