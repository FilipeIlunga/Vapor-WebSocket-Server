//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 04/09/23.
//

import Foundation

struct TypingMessage: WSCodable {
    let userID: String
    let isTyping: Bool
}
