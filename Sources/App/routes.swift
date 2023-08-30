import Fluent
import Vapor

let room = Room()

func routes(_ app: Application) throws {
    app.webSocket("toki") { request, ws in
        ws.onText { ws, text in
            let messageSplited = text.components(separatedBy: "|")
            
            guard let userName = messageSplited.first else {
                return
            }
            
            let messageToSend = messageSplited[1] + "|" + messageSplited[2]
            print(messageToSend)
            room.connections[userName] = ws
            room.send(userName: userName, newMessage: messageToSend)
        }
    }
    
    app.webSocket("isTappingSocket") { request, ws in
        ws.onText { ws, text in
            let messageSplited = text.components(separatedBy: "|")
            
            guard let userName = messageSplited.first, let message = messageSplited.last else {
                return
            }
            
            room.connections[userName] = ws
            room.send(userName: userName, newMessage: message)
        }
    }
    
    try app.register(collection: SongController())
}

struct User: Codable {
    let userName: String
    let message: String
}

struct Message: Codable {
    let userName: String
    let message: String
    
}

class Room {
    var connections =  [String: WebSocket]()
    
    func send(userName: String, newMessage: String)  {
        let message = userName + "|" + newMessage
        
        for (user, websocket) in connections {
            guard user != userName else { continue }
            websocket.send(message)
        }
    }
}


