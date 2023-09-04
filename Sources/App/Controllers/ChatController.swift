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
            let wsMessage: WSMessageHeader = try message.decodeWSEncodable(type: WSMessageHeader.self)
            
            switch wsMessage.messageType {
                
            case .Chat:
                guard let chatMessageType: ChatMessageType = ChatMessageType(rawValue: wsMessage.subMessageTypeCode) else {
                    print("Invalid chatMessageType code: \(wsMessage.subMessageTypeCode)")
                    return
                }
                
                handleChatMessageReceived(type: chatMessageType, payload: wsMessage.payload)
                
            case .Status:
                
                guard let statusMessageType: StatusMessageType = StatusMessageType(rawValue: wsMessage.subMessageTypeCode) else {
                    print("Invalid statusMessageType code: \(wsMessage.subMessageTypeCode)")
                    return
                }
                
                handleStatusMessagReceivede(type: statusMessageType, payload: wsMessage.payload, ws: ws)
            }
            
        } catch {
            
        }
    }
    
    private func handleChatMessageReceived(type: ChatMessageType, payload: String) {
        switch type {
        case .ContentString:
            handleChatContentString(payload: payload)
        case .ContentData:
            print("binary")
        case .Reaction:
            print("Reaction")
        case .Reply:
            print("Reply")
        case .TypingStatus:
            handlerTypingStatus(payload: payload)
        }
    }
    
    private func handleChatContentString(payload: String) {
        do {
            var wsChatMessage = try payload.decodeWSEncodable(type: WSChatMessage.self)
            wsChatMessage.isSendByUser = false
            
            let wsMessageCodable = WSMessageHeader(messageType: .Chat, subMessageTypeCode: ChatMessageType.ContentString.code, payload: payload)

            guard let wsMessage = try? wsMessageCodable.encode() else {
                print("Error on encode WSMessage: \(wsMessageCodable)")
                return
            }
            
            for (user, ws) in connections {
                guard user != wsChatMessage.senderID else { continue }
                ws.send(wsMessage)
            }
            
        } catch {
            print("Error on decode data: \(payload)")
        }
    }
    
    private func handlerTypingStatus(payload: String) {
        
        do {
            let typingMessage: TypingMessage = try payload.decodeWSEncodable(type: TypingMessage.self)
            let wsMessageCodable = WSMessageHeader(messageType: .Chat, subMessageTypeCode: ChatMessageType.TypingStatus.code, payload: payload)
            
            guard let wsMessage = try? wsMessageCodable.encode() else {
                print("Error on encode WSMessage: \(wsMessageCodable)")
                return
            }
            
            for (user, ws) in connections {
                guard user != typingMessage.userID else { continue }
                ws.send(wsMessage)
            }
            
        } catch {
            print("Error on \(#function): \(error.localizedDescription)")
        }
    }
    
    

    private func handleStatusMessagReceivede(type: StatusMessageType, payload: String, ws: WebSocket) {
        do {
            let statusMessage: StatusMessage = try payload.decodeWSEncodable(type: StatusMessage.self)
            switch type {
            case .Alive:
                connections[statusMessage.userID] = ws
            case .Disconnect:
                connections[statusMessage.userID] = nil
            }
        } catch {
            
        }
    }
    
    private func userHasPendingMessage(userID: String) -> Bool{
        return pendingMessages.map {$0.userID}.contains(userID)
    }

    
    func sendMessage(fromUser: String, message: String) {
        for (userID, ws) in connections {
            guard userID != fromUser else {
                continue
            }
            ws.send(message)
        }
    }
    
    
    func addPendingMessage(_ message: WSChatMessage, to userID: String) {
        let pendingMessage = PendingMessage(message: message, userID: userID)
        pendingMessages.insert(pendingMessage)
    }
}

