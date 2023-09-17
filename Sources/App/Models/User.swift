//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 02/09/23.
//

import Vapor

struct User: WSCodable, Hashable {
    let id: String
    var isConnected: Bool
}

struct UserSession: Hashable {
    var user: User
    var websocket: WebSocket
    
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        return lhs.user.id == rhs.user.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(user)
    }
}
