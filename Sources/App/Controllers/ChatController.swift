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
            }
        }
    }
    
    private func handlerWebsocketMessage(message: String, ws: WebSocket) {
        do {
            let messageReceived = try decodeWebsocketMessage(message: message)

            switch messageReceived.messageType {
            case .Chat:
                handleChatMessageReceived(messageReceived: messageReceived)
            case .Status:
                handleStatusMessagReceivede(messageReceived: messageReceived, ws: ws)
            }

        } catch {
            print("Error on \(error.localizedDescription)")
        }
    }
    
    private func handleChatMessageReceived(messageReceived: WSMessageReceived) {
        guard let chatMessageType = ChatMessageType(rawValue: messageReceived.subMessageTypeCode) else {
            print("Invalid chatMesage code: \(messageReceived.subMessageTypeCode)")

            return
        }
        handlerChatMessage(type: chatMessageType, message: messageReceived.payload)
    }

    private func handleStatusMessagReceivede(messageReceived: WSMessageReceived, ws: WebSocket) {
        guard let statusMessageType = StatusMessageType(rawValue: messageReceived.subMessageTypeCode) else {
            print("Invalid status code: \(messageReceived.subMessageTypeCode)")
            return
        }
        handlerStatusMessage(message: messageReceived.payload, type: statusMessageType, ws: ws)
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
            handlerTypingStatus(message: message)
        }
    }
    
    private func handlerTypingStatus(message: String) {
        let messageSplited = message.components(separatedBy: "|")

        guard messageSplited.count >= 2 else {
            return
        }
        
        let userID = messageSplited[0]
        
        //isTyping
        let _ = messageSplited[1]
        let header = WSMessageHeader(messageType: .Chat, subMessageType: ChatMessageType.TypingStatus)
        
        let socketMsg = "\(header.wsEncode)\(message)"
        sendMessage(fromUser: userID, message: socketMsg)
        
    }
    
    private func handlerChatContentStringMessage(message: String) {
        
        do {
             let wsMessage = try decodeChatContentStringMessage(message: message)
            sendMessage(message: wsMessage, payload: message)

        } catch {
            print("Error on \(#function): \(error.localizedDescription)")
        }
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
    
    func sendMessage(fromUser: String, message: String) {
        for (userID, ws) in connections {
            guard userID != fromUser else {
                continue
            }
            ws.send(message)
        }
    }
    
    
    func addPendingMessage(_ message: WSMessage, to userID: String) {
        let pendingMessage = PendingMessage(message: message, userID: userID)
        pendingMessages.insert(pendingMessage)
    }
}


extension ChatController {
    func decodeChatContentStringMessage(message: String) throws -> WSMessage {
        let messageSplited = message.components(separatedBy: "|")
        
        guard messageSplited.count >= 3 else {
           let errorDescription = "Message not enough fields - Expected fiedls: \(3) but received: \(messageSplited.count) - message: \(message)"
            throw NSError(domain: errorDescription, code: 0)
        }
        
        guard let timeInterval = Double(messageSplited[2]) else {
            let errorDescription = "Erro ao converter timestamp: \(messageSplited[1])"
            throw NSError(domain: errorDescription, code: 0)
        }
        
        let messageID = messageSplited[0]
        let sendID = messageSplited[1]
        let timestamp = Date(timeIntervalSince1970: timeInterval)
        let content = messageSplited[3]
        
        let wsMessage = WSMessage(messageID: messageID, senderID: sendID, timestamp: timestamp, content: content)
        return wsMessage
    }
    
    
    func decodeWebsocketMessage(message: String) throws -> WSMessageReceived {
        let messageSplited = message.components(separatedBy: "*|")
        
        guard messageSplited.count >= 3 else {
            print("Mensagem Invalida")
            let errorDescription = "Message not enough fields - Expected fiedls: \(3) but received: \(messageSplited.count) - message: \(message)"
            
            throw NSError(domain: errorDescription, code: 0)

        }
        

        guard let messageTypeCode = Int(messageSplited[0]),
              let messageType = NewMessageType(rawValue: messageTypeCode),
              let subMessageTypeCode = Int(messageSplited[1])
        else {
            throw NSError(domain: "Error on \(#function)", code: 0)
        }
        
        let payload = messageSplited[2]
        let messageReceived = WSMessageReceived(messageType: messageType, subMessageTypeCode: subMessageTypeCode, payload: payload)
        
        return messageReceived
    }
}

struct WSMessageReceived {
    let messageType: NewMessageType
    let subMessageTypeCode: Int
    let payload: String
}
