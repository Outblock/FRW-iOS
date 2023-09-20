//
//  FirebaseStorageUtils.swift
//  Flow Reference Wallet
//
//  Created by Selina on 20/6/2022.
//

import Combine
import Firebase
import FirebaseStorage
import SwiftUI
import UIKit

struct FirebaseStorageUtils {
    static func upload(avatar: UIImage, removeQuery: Bool = true) async -> String? {
        await withCheckedContinuation { config in
            guard let username = UserManager.shared.userInfo?.username else {
                config.resume(returning: nil)
                return
            }

            guard let data = avatar.jpegData(compressionQuality: 0.7) else {
                config.resume(returning: nil)
                return
            }

            let ts = Int(Date().timeIntervalSince1970 * 1000)
            let ref = Storage.storage().reference().child("avatar/\(username)-\(ts).jpg")
            ref.putData(data, metadata: nil) { _, error in
                guard error == nil else {
                    config.resume(returning: nil)
                    return
                }

                ref.downloadURL { url, _ in
                    guard let url = url, var comp = URLComponents(string: url.absoluteString) else {
                        config.resume(returning: nil)
                        return
                    }

                    if removeQuery {
                        comp.query = nil
                    }
                    
                    config.resume(returning: comp.url?.absoluteString)
                }
            }
        }
    }
}
