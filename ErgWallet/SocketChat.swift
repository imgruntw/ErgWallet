import SwiftPhoenixClient
import Foundation

class SocketChat {

    static let shared = SocketChat()

    private init() {}

    private let socket = Socket("wss://ergfi.xyz:4004/socket")

    func connect() {
        print("start connecting ...")

        let topic: String = "mempool:transactions"

        // Setup the socket to receive open/close events
        socket.delegateOnOpen(to: self) { (self) in
            print("CHAT ROOM: Socket Opened")
        }
        
        socket.delegateOnClose(to: self) { (self) in
            print("CHAT ROOM: Socket Closed")
        }
        
        socket.delegateOnError(to: self) { (self, error) in
            let (error, response) = error

            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 400 {
                print("CHAT ROOM: Socket error \(statusCode)")
                self.socket.disconnect()
            } else {
                print("CHAT ROOM: Socket error \(error)")
            }
        }
            
        self.socket.logger = { msg in print("LOG:", msg) }
        
        // Setup the Channel to receive and send messages
        let channel = self.socket.channel(topic, params: ["status": "joining"])
        channel.delegateOn("shout", to: self) { (self, message) in
            let payload = message.payload
            guard let name = payload["name"] as? String, let message = payload["message"] as? String else { return }
            print(name)
            print(message)
        }

        // Now connect the socket and join the channel
        channel.join()
            .delegateReceive("ok", to: self, callback: { (self, _) in
                print("CHANNEL: joined")
            })
            .delegateReceive("error", to: self, callback: { (self, message) in
                print("CHANNEL: failed to join \(message.payload)")
            })
        
        self.socket.connect()
    }
}
