//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 03/09/23.
//

import Vapor


class ChatController {
    // ...
    
    // Mantenha uma lista de mensagens pendentes
    private var pendingMessages: Set<PendingMessage> = []
    
    private var connections: [String: WebSocket] = [:]
    
    func handleWebSocket(_ app: Application) throws {
        
        app.webSocket("chatWS") { request, ws in
            ws.onText { ws, text in
                let messageSplied = text.components(separatedBy: "|")
                
                guard messageSplied.count >= 4 else {
                    print("Mensagem Invalida")
                    return
                }
                
                let userID = messageSplied[0]
                let stringTimestamp = messageSplied[2]
                let messageContent = messageSplied[3]
                
                guard let timeInterval = Double(stringTimestamp), let messageTypeRawValue = Int(messageSplied[1]), let messageType = MessageType(rawValue: messageTypeRawValue) else {
                    print("Erro ao converter timestamp")
                    return
                }
                
                
                let timestamp = Date(timeIntervalSince1970: timeInterval)

                self.connections[userID] = ws
                
                
                let message = WSMessage(senderID: userID, messageType: messageType, timestamp: timestamp, content: messageContent)
                if ![MessageType.typingStatus, .alive].contains(messageType) {
                    print("Received: \(message.description)")
                }
                if self.userHasPendingMessage(userID: userID) {
                    for pendingMessage in self.pendingMessages {
                        guard pendingMessage.userID == userID else { continue }
                        self.sendMessage(message: pendingMessage.message)
                        self.pendingMessages.remove(pendingMessage)
                    }
                } else {
                    self.sendMessage(message: message)
                }
            }
        }
        
    }
    
    private func userHasPendingMessage(userID: String) -> Bool{
        return pendingMessages.map {$0.userID}.contains(userID)
    }
    
    func sendMessage(message: WSMessage) {
        
        for (userID, ws) in connections {
            guard message.senderID != userID else { continue }
            
            guard !ws.isClosed else {
                self.addPendingMessage(message, to: userID)
                continue
            }
            
            ws.send(message.description)
        }
    }
    
    func addPendingMessage(_ message: WSMessage, to userID: String) {
        let pendingMessage = PendingMessage(message: message, userID: userID)
        pendingMessages.insert(pendingMessage)
    }
}
