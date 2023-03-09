//
//  Websocket.swift
//  Lilico
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation
import Starscream
import WalletConnectRelay

extension WebSocket: WebSocketConnecting { }

class SocketFactory: WebSocketFactory {
    var socket: WebSocket?
    func create(with url: URL) -> WebSocketConnecting {
        let socket = WebSocket(url: url)
        self.socket = socket
        return socket
    }
}
