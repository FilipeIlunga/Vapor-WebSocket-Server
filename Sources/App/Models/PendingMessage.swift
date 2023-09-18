//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 03/09/23.
//

import Foundation

struct PendingMessage: Hashable, Equatable {
    
    var message: WSMessageHeader
    var userID: String
    var fromUserID: String
    var timeStamp: Date
    
    static func == (lhs: PendingMessage, rhs: PendingMessage) -> Bool {
        return lhs.message.payload == rhs.message.payload && lhs.userID == rhs.userID
    }
}
