//
//  WebBookmark.swift
//  Flow Wallet
//
//  Created by Selina on 10/10/2022.
//

import Foundation

class WebBookmark: Codable {
    var id: Int = 0
    var url: String = ""
    var title: String = ""
    var isFav: Bool = false
    var createTime: TimeInterval = 0
    var updateTime: TimeInterval = 0

    var createTimeDate: Date {
        return Date(timeIntervalSince1970: createTime)
    }

    var updateTimeDate: Date {
        return Date(timeIntervalSince1970: updateTime)
    }

    var host: String {
        if let url = URL(string: url) {
            return url.host ?? ""
        }

        return ""
    }

    var dbValues: [Any] {
        return [url, title, isFav, createTime, updateTime]
    }

    class func build(fromDBMap map: [AnyHashable: Any]) -> WebBookmark? {
        let obj = WebBookmark()

        if let id = map["id"] as? Int {
            obj.id = id
        } else {
            return nil
        }

        if let url = map["url"] as? String {
            obj.url = url
        } else {
            return nil
        }

        if let title = map["title"] as? String {
            obj.title = title
        } else {
            return nil
        }

        if let isFav = map["is_fav"] as? Int {
            obj.isFav = isFav == 0 ? false : true
        } else {
            return nil
        }

        if let createTime = map["create_time"] as? TimeInterval {
            obj.createTime = createTime
        } else {
            return nil
        }

        if let updateTime = map["update_time"] as? TimeInterval {
            obj.updateTime = updateTime
        } else {
            return nil
        }

        return obj
    }
}
