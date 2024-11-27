//
//  NotificationService.swift
//  Flow WalletNotificationServiceExtension
//
//  Created by Selina on 18/7/2023.
//

import CryptoKit
import Intents
import ReownWalletKit
import UserNotifications
import WalletConnectNotify

// MARK: - NotificationService

class NotificationService: UNNotificationServiceExtension {
    // MARK: Internal

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        // handle walletconnect
        handleWalletConnect(request, withContentHandler: contentHandler)

        if let bestAttemptContent = bestAttemptContent {
            guard let fcmOptions = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
                  let imageURLString = fcmOptions["image"] as? String
            else {
                contentHandler(bestAttemptContent)
                return
            }

            Task {
                do {
                    if let localImageURL = try await downloadAndSaveImage(imageURLString) {
                        let attach = try UNNotificationAttachment(
                            identifier: "",
                            url: localImageURL
                        )
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
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: Private

    private func downloadAndSaveImage(_ urlString: String) async throws -> URL? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        let result = try await URLSession.shared.data(from: url)
        let format = url.pathExtension

        let savePath = cacheFolder().appendingPathComponent(urlString.md5)
            .appendingPathExtension(format)
        try result.0.write(to: savePath)
        return savePath
    }

    private func cacheFolder() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}

// MARK: - Handle WalletConnect

extension NotificationService {
    private func handleWalletConnect(
        _: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        if let content = bestAttemptContent,
           let topic = content.userInfo["topic"] as? String,
           let ciphertext = content.userInfo["message"] as? String,
           let tag = content.userInfo["tag"] as? UInt
        {
            if WalletKitDecryptionService.canHandle(tag: tag) {
                let mutableContent = handleWeb3WalletNotification(
                    content: content,
                    topic: topic,
                    tag: tag,
                    ciphertext: ciphertext
                )
                contentHandler(mutableContent)
            } else if NotifyDecryptionService.canHandle(tag: tag) {
                let mutableContent = handleNotifyNotification(
                    content: content,
                    topic: topic,
                    ciphertext: ciphertext
                )
                contentHandler(mutableContent)
            } else {
                let mutableContent = content.mutableCopy() as! UNMutableNotificationContent
                mutableContent.title = "Error: unknown message tag"
            }
        } else {
            if let content = bestAttemptContent {
                contentHandler(content)
            }
        }
    }

    private func handleWeb3WalletNotification(
        content: UNNotificationContent,
        topic: String,
        tag: UInt,
        ciphertext: String
    ) -> UNMutableNotificationContent {
        do {
            let web3WalletDecryptionService =
                try WalletKitDecryptionService(groupIdentifier: "group.com.walletconnect.sdk")

            let decryptedPayload = try web3WalletDecryptionService.decryptMessage(
                topic: topic,
                ciphertext: ciphertext,
                tag: tag
            )

            let mutableContent = content.mutableCopy() as! UNMutableNotificationContent

            guard let metadata = web3WalletDecryptionService.getMetadata(topic: topic) else {
                mutableContent.title = "Error: Cannot get peer's metadata"
                return mutableContent
            }

            switch decryptedPayload.requestMethod {
            case .sessionProposal:
                mutableContent.title = "New session proposal!"
                mutableContent
                    .body =
                    "A new session proposal arrived from \(metadata.name), please check your wallet"
            case .sessionRequest:
                if let payload = decryptedPayload as? RequestPayload {
                    mutableContent.title = "New session request!"
                    mutableContent
                        .body =
                        "A new session request \(payload.request.method) arrived from \(metadata.name), please check your wallet"
                }
            case .authRequest:
                mutableContent.title = "New authentication request!"
                mutableContent
                    .body =
                    "A new authentication request arrived from \(metadata.name), please check your wallet"
            }

            return mutableContent
        } catch {
            let mutableContent = content.mutableCopy() as! UNMutableNotificationContent
            mutableContent.title = "Error"
            mutableContent.body = error.localizedDescription

            return mutableContent
        }
    }

    private func handleNotifyNotification(
        content: UNNotificationContent,
        topic: String,
        ciphertext: String
    ) -> UNMutableNotificationContent {
        do {
            let service = NotifyDecryptionService(groupIdentifier: "group.com.walletconnect.sdk")
            let (pushMessage, subscription, account) = try service.decryptMessage(
                topic: topic,
                ciphertext: ciphertext
            )

            log("message decrypted", account: account, topic: topic, message: pushMessage)

            let updatedContent = handle(
                content: content,
                pushMessage: pushMessage,
                subscription: subscription,
                topic: topic
            )

            let mutableContent = updatedContent.mutableCopy() as! UNMutableNotificationContent
            mutableContent.title = pushMessage.title
            mutableContent.subtitle = pushMessage.url
            mutableContent.body = pushMessage.body

            log("message handled", account: account, topic: topic, message: pushMessage)

            return mutableContent
        } catch {
            log("error: \(error.localizedDescription)")

            let mutableContent = content.mutableCopy() as! UNMutableNotificationContent
            mutableContent.title = "Error"
            mutableContent.body = error.localizedDescription

            return mutableContent
        }
    }

    func handle(
        content: UNNotificationContent,
        pushMessage: NotifyMessage,
        subscription: NotifySubscription,
        topic: String
    ) -> UNNotificationContent {
        var senderAvatar: INImage?

        if let icon = subscription.messageIcons(ofType: pushMessage.type).md {
            do {
                let iconUrl = try icon.asURL()
                let senderThumbnailImageData = try Data(contentsOf: iconUrl)
                let senderThumbnailImageFileUrl = try downloadAttachment(
                    data: senderThumbnailImageData,
                    fileName: iconUrl.lastPathComponent
                )
                let senderThumbnailImageFileData = try Data(contentsOf: senderThumbnailImageFileUrl)
                senderAvatar = INImage(imageData: senderThumbnailImageFileData)
            } catch {
                log(
                    "Fetch icon error: \(error)",
                    account: subscription.account,
                    topic: topic,
                    message: pushMessage
                )
            }
        }

        var personNameComponents = PersonNameComponents()
        personNameComponents.nickname = pushMessage.title

        let senderPerson = INPerson(
            personHandle: INPersonHandle(value: topic, type: .unknown),
            nameComponents: personNameComponents,
            displayName: pushMessage.title,
            image: senderAvatar,
            contactIdentifier: nil,
            customIdentifier: topic,
            isMe: false,
            suggestionType: .none
        )

        let selfPerson = INPerson(
            personHandle: INPersonHandle(value: "0", type: .unknown),
            nameComponents: nil,
            displayName: nil,
            image: nil,
            contactIdentifier: nil,
            customIdentifier: nil,
            isMe: true,
            suggestionType: .none
        )

        let incomingMessagingIntent = INSendMessageIntent(
            recipients: [selfPerson],
            outgoingMessageType: .outgoingMessageText,
            content: pushMessage.body,
            speakableGroupName: nil,
            conversationIdentifier: pushMessage.type,
            serviceName: nil,
            sender: senderPerson,
            attachments: []
        )

        incomingMessagingIntent.setImage(senderAvatar, forParameterNamed: \.sender)

        let interaction = INInteraction(intent: incomingMessagingIntent, response: nil)
        interaction.direction = .incoming
        interaction.donate(completion: nil)

        let updated = try? content.updating(from: incomingMessagingIntent)
        return updated ?? content
    }

    func downloadAttachment(data: Data, fileName: String) throws -> URL {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(
            tmpSubFolderName,
            isDirectory: true
        )

        try fileManager.createDirectory(
            at: tmpSubFolderURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let fileURL = tmpSubFolderURL.appendingPathComponent(fileName)
        try data.write(to: fileURL)

        return fileURL
    }

    func log(
        _: String,
        account _: Account? = nil,
        topic _: String? = nil,
        message _: NotifyMessage? = nil
    ) {
        let keychain = GroupKeychainStorage(serviceIdentifier: "group.com.walletconnect.sdk")

        guard let clientId: String = try? keychain.read(key: "clientId") else {
            return
        }

//        guard let token = InputConfig.mixpanelToken, !token.isEmpty  else { return }
//
//        Mixpanel.initialize(token: token, trackAutomaticEvents: true)
//
//        if let account {
//            let mixpanel = Mixpanel.mainInstance()
//            mixpanel.alias = account.absoluteString
//            mixpanel.identify(distinctId: clientId)
//            mixpanel.people.set(properties: ["$name": account.absoluteString, "account": account.absoluteString])
//        }
//
//        Mixpanel.mainInstance().track(
//            event: "💬 APNS: " + event,
//            properties: [
//                "message_id": message?.id,
//                "title": message?.title,
//                "body": message?.body,
//                "icon": message?.icon,
//                "url": message?.url,
//                "type": message?.type,
//                "topic": topic,
//                "source": "NotificationService"
//            ]
//        )
    }
}

extension String {
    var md5: String {
        Insecure.MD5.hash(data: data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
    }
}
