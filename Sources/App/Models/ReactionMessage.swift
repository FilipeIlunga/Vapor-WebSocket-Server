//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 04/09/23.
//

import Foundation


struct Reaction: Hashable, WSCodable {
    var count: Int
    var emoji: String
}


struct ReactionMessage: WSCodable {
    let userID: String
    let id: String
    let messageReactedID: String
    let reactionIcon: Reaction
}
