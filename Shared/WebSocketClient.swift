//
//  WebSocketClient.swift
//  lido
//
//  Created by Everett Wilber on 6/24/22.
//

import Foundation

final class WebSocketClient: NSObject {
    
    static let shared = WebSocketClient()
    var webSocket: URLSessionWebSocketTask?
    
    var opened = false
    
    private var urlString = "ws://localhost:4000"
    
    private override init() {
        // no-op
    }
    
    func subscribeToService(with completion: @escaping (Data?) -> Void) {
        if !opened {
            openWebSocket()
        }
        
        guard let webSocket = webSocket else {
            completion(nil)
            return
        }
        
        webSocket.receive(completionHandler: { [weak self] result in
            
            guard let self = self else { return }
            
            print("anything received")
            
            switch result {
            case .failure:
                completion(nil)
            case .success(let webSocketTaskMessage):
                switch webSocketTaskMessage {
                case .string(let string):
                    print(string)
                    print("string received")
                    completion(string.data(using: .utf8))
                case .data(let data):
                    print("data received 1")
                    completion(data)
                default:
                    fatalError("Failed. Received unknown data format. Expected String")
                }
            }
            self.subscribeToService(with: completion)
        })
    }
    
    private func openWebSocket() {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            self.opened = true
            self.webSocket?.resume()
        } else {
            webSocket = nil
        }
    }
    func closeSocket() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        opened = false
        webSocket = nil
    }
    func sendMessage(message: Codable) async throws {
        try await webSocket?.send(.data(JSONEncoder().encode(message)))
    }
    func sendData(data: Data) async throws {
        try await webSocket?.send(URLSessionWebSocketTask.Message.data(data))
    }
    func sendString(string: String) async throws {
        try await webSocket?.send(URLSessionWebSocketTask.Message.string(string))
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        opened = true
    }

    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.webSocket = nil
        self.opened = false
    }
}
