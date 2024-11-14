//
//  Websocket.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation
import Starscream
import WalletConnectRelay

// MARK: - WebSocket + WebSocketConnecting

extension WebSocket: WebSocketConnecting {}

// MARK: - SocketFactory

class SocketFactory: WebSocketFactory {
    var socket: WebSocket?

    func create(with url: URL) -> WebSocketConnecting {
        let socket = WebSocket(url: url)
        self.socket = socket
        return socket
    }
}
