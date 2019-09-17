//
//  Notifications.swift
//  LogLlama
//
//  Created by Eric Johnson on 9/17/19.
//  Copyright © 2019 Lost Bear Labs. All rights reserved.
//

import Foundation

import Foundation

extension Notification.Name {
    static let FileLoaded = Notification.Name("FileLoaded")
    static let SaveFile = Notification.Name("SaveFile")
    static let TextChanged = Notification.Name("TextChanged")
    static let NewFile = Notification.Name("NewFile")
}
