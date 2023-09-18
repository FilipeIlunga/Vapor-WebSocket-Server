# Real-Time Chat Built with Vapor using Websocket

## Server-side description of the chat system:

This Vapor server is used to create a real-time chat application. It uses WebSockets to allow users to exchange messages in an instant and bidirectional way. 

The client's codebase can be found in this repository: [Client repository](https://github.com/FilipeIlunga/Vapor-WebSocket-Client).

# Key Features:

## 1 -  Message persistence: 
Messages are stored locally on the user's device, ensuring that conversations are preserved even if the user is offline or if the server is unavailable.
The server should not be aware of how messages are stored on the user's device. It should simply be responsible for propagating messages between users.

## 2-  Communication channel persistence: 
Users don't miss any important messages, the server  maintains a list of pending messages for each client. If a user is offline, messages sent to them will be re-sent when they reconnect.

## 3 - Heartbeat protocol:
The server checks if clients are responding. If a client fails to respond, the server will automatically attempt a new connection, ensuring an uninterrupted connection.

## 4 - Typing indicators: 

When a user starts typing in the chat box, the client sends a message to the server indicating that the user is typing. The server receives the message and broadcasts it to all other connected clients. Each client then updates its UI to indicate that the user is typing.
When the user stops typing, the client sends another message to the server indicating that the user has stopped typing. The server then broadcasts this message to all other connected clients, so that they can update their UIs to remove the typing indicator.

## 5 - Message reactions: 
when a user reacts to a message, the client tells the server about the reaction. The server then updates the message with the new reaction and tells all other clients about the updated message. Each client then updates its UI to show the new reaction.
