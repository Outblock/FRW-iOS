//
//  Websocket.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation
import Starscream
import WalletConnectRelay


class FlowWebSocket: WebSocket, WebSocketConnecting {
    var isConnected: Bool = false
    
    var onConnect: (() -> Void)?
    
    var onDisconnect: (((any Error)?) -> Void)?
    
    var onText: ((String) -> Void)?
    
    
}


class SocketFactory: WebSocketFactory, WebSocketDelegate {
    
    var socket: FlowWebSocket?
    
    func create(with url: URL) -> WebSocketConnecting {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let socket = FlowWebSocket(request: request)
        socket.delegate = self
        self.socket = socket
        return socket
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
            case .connected(let headers):
            socket?.isConnected = true
            socket?.onConnect?()
            
            case .disconnected(let reason, let code):
            socket?.isConnected = false
            socket?.onDisconnect?(nil)
            log.info("[SocketFactory] websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
            socket?.onText?(string)
            log.info("[SocketFactory] Received text: \(string)")
            case .binary(let data):
                print("Received data: \(data.count)")
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
            socket?.isConnected = false
            case .error(let error):
            socket?.isConnected = false
                
                case .peerClosed:
                       break
            }
    }
}
