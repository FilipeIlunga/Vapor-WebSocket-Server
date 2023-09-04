//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 02/09/23.
//

import Foundation

struct WSChatMessage: Hashable {
    let messageID: String
    let senderID: String
    let timestamp: Date
    let content: String
    
    var description: String {
        return "\(messageID)|\(senderID)|\(timestamp.timeIntervalSince1970)|\(content)"
    }
}
