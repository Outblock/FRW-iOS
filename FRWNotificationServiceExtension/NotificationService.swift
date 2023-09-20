//
//  NotificationService.swift
//  Flow Reference WalletNotificationServiceExtension
//
//  Created by Selina on 18/7/2023.
//

import UserNotifications
import CryptoKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            guard let fcmOptions = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
                  let imageURLString = fcmOptions["image"] as? String else {
                contentHandler(bestAttemptContent)
                return
            }
            
            Task {
                do {
                    if let localImageURL = try await downloadAndSaveImage(imageURLString) {
                        let attach = try UNNotificationAttachment(identifier: "", url: localImageURL)
                        bestAttemptContent.attachments = [attach]
                    }
                    
                    contentHandler(bestAttemptContent)
                } catch {
                    print("download and save image failed: \(error.localizedDescription)")
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadAndSaveImage(_ urlString: String) async throws -> URL? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let result = try await URLSession.shared.data(from: url)
        let format = url.pathExtension
        
        let savePath = cacheFolder().appendingPathComponent(urlString.md5).appendingPathExtension(format)
        try result.0.write(to: savePath)
        return savePath
    }
    
    private func cacheFolder() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

extension String {
    var md5: String {
        return Insecure.MD5.hash(data: self.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
    }
}
