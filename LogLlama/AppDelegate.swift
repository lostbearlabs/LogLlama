//
//  AppDelegate.swift
//  LogLlama
//
//  Created by Eric Johnson on 9/16/19.
//  Copyright © 2019 Lost Bear Labs. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var currentFile : String?
    var textChanged = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onTextChanged(_:)), name: .TextChanged, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func openFile(_ sender: Any) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                NotificationCenter.default.post(name: .FileLoaded, object: path)
                NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: path))
                currentFile = path
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        NotificationCenter.default.post(name: .FileLoaded, object: filename)
        self.currentFile = filename
        self.textChanged = false
        return true
    }

    @IBAction func newFile(_ sender: Any) {
        if( self.checkSave() ) {
            NotificationCenter.default.post(name: .NewFile, object: nil)
            self.textChanged = false
            self.currentFile = nil
        }
    }
    
    @IBAction func closeFile(_ sender: Any) {
        
    }
    
    @IBAction func saveFile(_ sender: Any) {
        if( self.currentFile == nil ) {
            self.saveFileAs(sender)
        } else {
            NotificationCenter.default.post(name: .SaveFile, object: self.currentFile)
        }
    }
    
    @IBAction func saveFileAs(_ sender: Any) {
        let dialog = NSSavePanel()
        
        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canCreateDirectories    = true;
        dialog.allowedFileTypes        = ["txt"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path
                NotificationCenter.default.post(name: .SaveFile, object: path)
                NSDocumentController.shared.noteNewRecentDocumentURL(URL(fileURLWithPath: path))
                self.currentFile = path
                self.textChanged = false
            }
        }
    }
 
    
    @objc private func onTextChanged(_ notification: Notification) {
        if( !self.textChanged ) {
            self.textChanged = true
        }
    }
    
    func checkSave() -> Bool {
        if( self.textChanged ) {
            // TODO: how to prompt for save?
        }
        
        return true
    }
    
    @IBAction func onRunClicked(_ sender: Any) {
        NotificationCenter.default.post(name: .RunClicked, object: nil)
    }
}

