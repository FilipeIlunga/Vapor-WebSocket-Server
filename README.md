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

# How to run the server on your machine.

## 1  - Vapor Installation
To run the server on your machine, you need to install Vapor first.

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

## 2 - Clone This Repository

To clone this repository, run the following command:

```bash
git clone git@github.com:FilipeIlunga/Vapor-WebSocket-Server.git
```

## 3 - Open the Project with Xcode

To open this project in Xcode, navigate to the folder where you cloned the repository and double-click on `Package.swift`. This action will open Xcode and initiate the download of all required dependencies. 

## 4 - Build and run the project

Once all dependencies are installed, you can build and run the Xcode project just like any other Xcode project. You will see the following message in your Xcode console:

<img src="https://github.com/FilipeIlunga/Vapor-WebSocket-Server/assets/45888235/a9109826-63a8-42f0-9a30-b67fb88ecff7" alt="image" width="400">

## 5 - Wait for new client connections.
With the server running, you can connect to the client in [this repository](https://github.com/FilipeIlunga/Vapor-WebSocket-Client).and start chat communication.

## EXTRA: Make server accesible from the internet
So far, your Vapor chat server is only accessible locally, on port 8080. To make it accessible from the Internet, you can use ngrok. Ngrok is a tool that creates a secure tunnel between your local server and the Internet.

Ngrok is already integrated into the project; to run it, simply open the project folder in the terminal and execute the command below.

```bash
 ./ngrok http 8080
```
If everything goes as expected, you will see this screen shortly, and the underlined part is where we can access our server from the internet.

<img width="684" alt="image" src="https://github.com/FilipeIlunga/Vapor-WebSocket-Server/assets/45888235/33e61394-9f65-45b6-970c-d548174bf963">

In the client's project, within the APIKeys file, replace the websocketAddress value with the new address provided by ngrok.
```swift
enum APIKeys: String {
    case websocketAddress = "http://127.0.0.1:8080"
}
```



```swift
enum APIKeys: String {
    case websocketAddress = "https://ecd0-138-122-73-139.ngrok.io)https://ecd0-138-122-73-139.ngrok.io"
}
```
> [!NOTE]
> A address generated by Ngrok is valid for 2 hours. After this time, a new address must be generated manually by following the steps above.

After changing the `websocketAddress`, you can rebuild the client's project on a physical device, and all compiled devices will be communicating through the same WebSocket.
