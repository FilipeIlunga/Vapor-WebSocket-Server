//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 02/09/23.
//

import Foundation

struct WSChatMessage: Hashable, WSCodable {
    let messageID: String
    let imageDate: Data?
    let senderID: String
    let timestamp: Date
    let content: String
    var isSendByUser: Bool
    var reactions: [Reaction]


    var description: String {
        return "\(messageID)|\(senderID)|\(timestamp.timeIntervalSince1970)|\(content)"
    }
}
