//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 03/09/23.
//

import Foundation

struct PendingMessage: Hashable {
    var message: WSChatMessage
    var userID: String
}
