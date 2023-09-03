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
                
                self.handlerWebsocketMessage(message: text, ws: ws)
            
                
//                let message = WSMessage(senderID: userID, messageType: messageType, timestamp: timestamp, content: messageContent)
 
//                if self.userHasPendingMessage(userID: userID) {
//                    for pendingMessage in self.pendingMessages {
//                        guard pendingMessage.userID == userID else { continue }
//                        self.sendMessage(message: pendingMessage.message)
//                        self.pendingMessages.remove(pendingMessage)
//                    }
//                } else {
//                    self.sendMessage(message: message)
//                }
            }
        }
    }
    
    private func handlerWebsocketMessage(message: String, ws: WebSocket) {
        let messageSplied = message.components(separatedBy: "*|")
        
        guard messageSplied.count >= 3 else {
            print("Mensagem Invalida")
            return
        }
        

        guard let messageTypeCode = Int(messageSplied[0]),
              let messageType = NewMessageType(rawValue: messageTypeCode),
              let subMessageTypeCode = Int(messageSplied[1])
        else {
            return
        }
        
        let payload = messageSplied[2]

        
        switch messageType {
            
        case .Chat:
            guard let chatMessageType = ChatMessageType(rawValue: subMessageTypeCode) else {
                return
            }
            handlerChatMessage(type: chatMessageType, message: payload)
        case .Status:
            
            guard let statusMessageType = StatusMessageType(rawValue: subMessageTypeCode) else {
                print("Invalid status code: \(subMessageTypeCode)")
                      return
            }
            handlerStatusMessage(message: payload, type: statusMessageType, ws: ws)
        }

    }
    
    private func handlerStatusMessage(message: String, type: StatusMessageType, ws: WebSocket) {
        switch type {
        case .Alive:
            handlerAliveMessage(message: message, ws: ws)
        case .Disconnect:
            print("a")
        }
    }
    
    private func handlerAliveMessage(message: String, ws: WebSocket) {
        let messageSplited = message.components(separatedBy: "|")
        
        guard messageSplited.count >= 2 else {
            print("Message not enough fields - Expected fiedls: \(2) but received: \(messageSplited.count) - message: \(message)")
            return
        }
        
        let userName = messageSplited[0]
        connections[userName] = ws
    }
    
    private func handlerChatMessage(type: ChatMessageType, message: String) {
        switch type {
            
        case .ContentString:
            handlerChatContentStringMessage(message: message)
        case .ContentData:
            print("contentData")
        case .Reaction:
            print("reaction")
        case .Reply:
            print("reply")
        case .TypingStatus:
            print("typing")
        }
    }
    
    private func handlerChatContentStringMessage(message: String) {
        let messageSplited = message.components(separatedBy: "|")
        
        guard messageSplited.count >= 3 else {
            print("Message not enough fields - Expected fiedls: \(3) but received: \(messageSplited.count) - message: \(message)")
            return
        }
        
        guard let timeInterval = Double(messageSplited[1]) else {
            print("Erro ao converter timestamp: \(messageSplited[1])")
            return
        }
        
        let sendID = messageSplited[0]
        let timestamp = Date(timeIntervalSince1970: timeInterval)
        let content = messageSplited[2]
        
        let wsMessage = WSMessage(senderID: sendID, timestamp: timestamp, content: content)
        sendMessage(message: wsMessage, payload: message)
    }
    
    private func userHasPendingMessage(userID: String) -> Bool{
        return pendingMessages.map {$0.userID}.contains(userID)
    }
    
    func sendMessage(message: WSMessage, payload: String) {
        
        let header = WSMessageHeader(messageType: .Chat, subMessageType: ChatMessageType.ContentString)
        let socketMsg = "\(header.wsEncode)\(payload)"
        for (userID, ws) in connections {
            guard message.senderID != userID else { continue }
            
            guard !ws.isClosed else {
                self.addPendingMessage(message, to: userID)
                continue
            }
            
            ws.send(socketMsg)
        }
    }
    
    
    func addPendingMessage(_ message: WSMessage, to userID: String) {
        let pendingMessage = PendingMessage(message: message, userID: userID)
        pendingMessages.insert(pendingMessage)
    }
}
