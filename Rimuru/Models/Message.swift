//
//  Message.swift
//  Rimuru
//
//  Created by MACBOOK AIR on 04/03/26.
//

import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var text: String
    var sender: String // "user" atau "rimuru"
    var timestamp: Date
    
    init(text: String, sender: String) {
        self.id = UUID()
        self.text = text
        self.sender = sender
        self.timestamp = Date.now
    }
}
