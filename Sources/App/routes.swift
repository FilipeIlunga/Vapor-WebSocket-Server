import Fluent
import Vapor

let room = Room()
let gameRoom = Room()
let semaphore = DispatchSemaphore(value: 1)

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
    
    app.webSocket("spriteKitGame") { request, ws in
                ws.onText { ws, text in
           
            let messageSlipted = text.components(separatedBy: "|")
            
            guard messageSlipted.count > 4 else {
                return
            }
            
            let userName = messageSlipted[0]
            
            semaphore.wait()
            gameRoom.connections[userName] = ws
            semaphore.signal()
            
            gameRoom.sendCoordinates(userName: userName, payload: text)
            print("Message received: \(text)")
        }
    }
    
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
    
    func sendCoordinates(userName: String, payload: String) {
        
        for (user, ws) in connections {
            guard userName != user else { continue }
            
            ws.send(payload)
        }
        
    }
}


