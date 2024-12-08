//
//  EventTrack+Dev.swift
//  FRW
//
//  Created by cat on 12/9/24.
//

import Foundation

extension EventTrack.Dev {
    static func restoreLogin(userId: String) {
        EventTrack.send(event: EventTrack.Dev.restoreLogin, properties: ["user_id": userId])
    }
}
