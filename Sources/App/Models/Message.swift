//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 02/09/23.
//

import Foundation

enum MessageType: Int {
    case alive = 0
    case chatMessage
    case disconnecting
    case typingStatus
}

struct WSMessage: Hashable {
    let senderID: String
    let messageType: MessageType
    let timestamp: Date
    let content: String
    
    var description: String {
        return "\(senderID)|\(messageType.rawValue)|\(timestamp.timeIntervalSince1970)|\(content)"
    }
}
