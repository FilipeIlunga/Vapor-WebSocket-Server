//
//  File.swift
//  
//
//  Created by Filipe Ilunga on 03/09/23.
//

import Vapor


class ChatController {
    @Atomic private var pendingMessages: Set<PendingMessage> = []
    @Atomic private var sessions: [UserSession] = []
    
    func handleWebSocket(_ app: Application) throws {
        app.webSocket("chatWS") { request, ws in
            ws.onText { ws, text in
                self.handlerWebsocketMessage(message: text, ws: ws)
            }
        }
    }
    
    private func handlerWebsocketMessage(message: String, ws: WebSocket) {
        do {
            let wsMessage: WSMessageHeader = try WSCoder.shared.decode(type: WSMessageHeader.self, from: message)
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
            handleChatReactionMessafe(payload: payload)
        case .Reply:
            print("Reply")
        case .TypingStatus:
            handlerTypingStatus(payload: payload)
        }
    }
    
    private func handleChatReactionMessafe(payload: String) {
        do {
            let reactionMessage = try WSCoder.shared.decode(type: ReactionMessage.self, from: payload)
            
            let wsMessageCodable = WSMessageHeader(messageType: .Chat, subMessageTypeCode: ChatMessageType.Reaction.code, payload: payload)

            guard let wsMessage = try? WSCoder.shared.encode(data: wsMessageCodable) else {
                print("Error on encode WSMessage: \(wsMessageCodable)")
                return
            }
            
            sendMessage(fromUserID: reactionMessage.userID, message: wsMessage)
            
        } catch {
            print("Error on decode reaction message")
        }
    }
    
    private func handleChatContentString(payload: String) {
        do {
            var wsChatMessage = try  WSCoder.shared.decode(type: WSChatMessage.self, from: payload)
            wsChatMessage.isSendByUser = false
            
            let wsMessageCodable = WSMessageHeader(messageType: .Chat, subMessageTypeCode: ChatMessageType.ContentString.code, payload: payload)

            guard let wsMessage = try?  WSCoder.shared.encode(data: wsMessageCodable) else {
                print("Error on encode WSMessage: \(wsMessageCodable)")
                return
            }
            
            
            sendChatMessage(fromUserID:  wsChatMessage.senderID, message: wsMessageCodable)
            
        } catch {
            print("Error on decode data: \(payload)")
        }
    }
    
    private func sendChatMessage(fromUserID: String, message: WSMessageHeader) {
        
        guard let wsMessage = try?  WSCoder.shared.encode(data: message) else {
            print("Error on encode WSMessage: \(message)")
            return
        }
        
        for session in sessions {
            guard session.user.id != fromUserID else {
                continue
            }
            
            if !session.user.isConnected {
                addPendingMessage(message, from: fromUserID, to: session.user.id)
                print("Mensagem add e não enviada para \(session.user.id)")
                continue
            }
                
           sendMessage(fromUserID: fromUserID, message: wsMessage)
            
        }
    }
    
    private func handlerTypingStatus(payload: String) {
        
        do {
            let typingMessage: TypingMessage = try WSCoder.shared.decode(type: TypingMessage.self, from: payload)
            let wsMessageCodable = WSMessageHeader(messageType: .Chat, subMessageTypeCode: ChatMessageType.TypingStatus.code, payload: payload)
            
            guard let wsMessage = try?  WSCoder.shared.encode(data: wsMessageCodable) else {
                print("Error on encode WSMessage: \(wsMessageCodable)")
                return
            }
            
            sendMessage(fromUserID: typingMessage.userID, message: wsMessage)
            
        } catch {
            print("Error on \(#function): \(error.localizedDescription)")
        }
    }
    
    private func handleStatusMessagReceivede(type: StatusMessageType, payload: String, ws: WebSocket) {
        do {
            let statusMessage: StatusMessage = try WSCoder.shared.decode(type: StatusMessage.self, from: payload)
            let userID = statusMessage.userID
            
            if sessions.map({$0.user.id}).contains(userID) {
             
                guard let userSession = sessions.first(where: { $0.user.id == userID }),
                      let index = sessions.firstIndex(of: userSession) else {
                    print("Error on get user index ")
                    return
                }
                
                switch type {
                case .Alive:
                    sessions[index].user.isConnected = true
                    sessions[index].websocket = ws
                    sendPendingMessageIfNeeded(userID: userSession.user.id)
                    print("User: \(userSession.user.id) is connected")

                case .Disconnect:
                    sessions[index].user.isConnected = false
                    print("User: \(userSession.user.id) was disconnected")
                }
            } else {
                createNewUser(userID: userID, ws: ws)
            }
        } catch {
            print("Error handling status message: \(error)")
        }
    }

    
    private func userHasPendingMessage(userID: String) -> Bool{
        return pendingMessages.map {$0.userID}.contains(userID)
    }

    
    func sendMessage(fromUserID: String, message: String) {
        for session in sessions {
            guard session.user.id != fromUserID, session.user.isConnected else {
                continue
            }
            session.websocket.send(message)
        }
    }
    
    func addPendingMessage(_ message: WSMessageHeader, from senderUserID: String,to userID: String) {
        let pendingMessage = PendingMessage(message: message, userID: userID, fromUserID: senderUserID)
        pendingMessages.insert(pendingMessage)
    }
    
    func sendPendingMessageIfNeeded(userID: String) {
        
        let tempPendingMessages = pendingMessages
        
        var pendingMessageSent: Set<PendingMessage> = []
        tempPendingMessages.forEach { pendingMessage in
            if pendingMessage.userID == userID {
                guard let wsMessage = try?  WSCoder.shared.encode(data: pendingMessage.message) else {
                    print("Error on encode WSMessage: \(pendingMessage.message)")
                    return
                }
                sendMessage(fromUserID: pendingMessage.fromUserID, message: wsMessage)
                pendingMessageSent.insert(pendingMessage)
            }
        }
        pendingMessages.subtract(pendingMessageSent)
    }
    
    func createNewUser(userID: String, ws: WebSocket) {
                
        guard !sessions.map({ $0.user.id }).contains(userID) else {
            print("User \(userID) exist")
            return
        }
        
        let newUser = User(id: userID, isConnected: true)
        let newUserSession = UserSession(user: newUser, websocket: ws)
        sessions.append(newUserSession)
        print("User: \(newUser.id) was created")
    }
}

