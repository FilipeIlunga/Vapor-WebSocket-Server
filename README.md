# Real-Time Chat Built with Vapor using WebSocket

## Server-side Description of the Chat System

This Vapor server is designed to create a real-time chat application, leveraging the power of WebSockets to facilitate instant and bidirectional message exchange between users.

For the client-side codebase, please refer to the following repository: [Client repository](https://github.com/FilipeIlunga/Vapor-WebSocket-Client).

# Key Features:

## 1 - Message Persistence

Messages are locally stored on the user's device, ensuring that conversations are preserved, even if the user goes offline or if the server experiences downtime. The server's role is strictly to relay messages between users, without involvement in message storage on the user's device.

## 2 - Communication Channel Persistence

Users never miss important messages as the server maintains a list of pending messages for each client. If a user is offline, any messages sent to them will be re-sent when they reconnect.

## 3 - Heartbeat Protocol

To maintain uninterrupted connections, the server actively monitors client responsiveness. If a client fails to respond, the server automatically initiates a new connection attempt, ensuring seamless communication.

## 4 - Typing Indicators

The chat system provides real-time typing indicators. When a user starts typing in the chat box, the client sends a message to the server indicating the user's typing status. The server broadcasts this message to all connected clients, updating their UI to show that the user is typing. When the user stops typing, another message is sent to the server, indicating the user has stopped typing, and this message is also broadcast to update other clients' UIs.

## 5 - Message Reactions

Users can react to messages, and the client informs the server about these reactions. The server then updates the message with the new reaction and informs all other clients about the updated message. Each client updates its UI to display the new reaction.

## 1 - Vapor Installation

To set up Vapor on your computer, you can use Homebrew. If Homebrew is not already installed, you can visit the [official website](https://brew.sh/) to install it. Once Homebrew is ready, open a terminal and run the following command:

```bash
brew install vapor
```

If you encounter the following error:

<img src="https://github.com/FilipeIlunga/Vapor-WebSocket-Server/assets/45888235/82eeca0f-095b-457d-bced-160bbd31fdaf" alt="image" width="600">

Simply follow the instructions by entering this command in your terminal:

```bash
sudo chown —R $(whoami) /usr/local/share/man/man8
```

After successfully installing Vapor, confirm the installation by running:

```bash
vapor --help
```

If Vapor is correctly installed, you should see the following result:

<img src="https://github.com/FilipeIlunga/Vapor-WebSocket-Server/assets/45888235/d053f99d-9849-40ca-ade4-cce176e32038" alt="image" width="600">

With Vapor installed, you are now ready to build and use this project.

## Clone This Repository

To clone this repository, run the following command:

```bash
git clone git@github.com:FilipeIlunga/Vapor-WebSocket-Server.git
```

## Open the Project with Xcode

To open this project in Xcode, navigate to the folder where you cloned the repository and double-click on `Package.swift`. This action will open Xcode and initiate the download of all required dependencies. Once all dependencies are installed, you can build and run the Xcode project just like any other Xcode project. You will see the following message in your Xcode console:

<img src="https://github.com/FilipeIlunga/Vapor-WebSocket-Server/assets/45888235/a9109826-63a8-42f0-9a30-b67fb88ecff7" alt="image" width="400">

## Wait for new client connections.
With the server running, you can connect to the client in [this repository](https://github.com/FilipeIlunga/Vapor-WebSocket-Client).and start chat communication.
