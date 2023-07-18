//
//  PushHandler.swift
//  Lilico
//
//  Created by Selina on 17/7/2023.
//

import UIKit
import FirebaseMessaging
import Combine

class PushHandler: NSObject, ObservableObject {
    static let shared = PushHandler()
    
    @Published var isPushEnabled: Bool = false
    
    private var fcmToken: String?
    private var uploadedHistory: [String: String] = [:]
    private var cancelSets = Set<AnyCancellable>()
    
    private var uploadingAddress: String?
    
    private override init() {
        super.init()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        refreshPushStatus()
        
        WalletManager.shared.$walletInfo
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                log.debug("wallet info refresh triggerd a upload token action")
                self.uploadCurrentToken()
            }.store(in: &cancelSets)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.refreshPushStatus()
            }.store(in: &cancelSets)
    }
    
    func requestPermission() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { result, error in
            DispatchQueue.main.async {
                self.refreshPushStatus()
                
                if result {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

extension PushHandler {
    private func refreshPushStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPushEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func uploadToken(_ token: String) {
        if fcmToken != token {
            uploadedHistory.removeAll()
        }
        
        fcmToken = token
        uploadCurrentToken()
    }
    
    private func uploadCurrentToken() {
        guard let address = WalletManager.shared.getPrimaryWalletAddress(), let fcmToken = fcmToken else {
            return
        }
        
        if uploadedHistory[address] == fcmToken {
            // uploaded
            log.debug("\(address) push token already uploaded")
            return
        }
        
        if uploadingAddress == address {
            return
        }
        
        uploadingAddress = address
        
        Task {
            do {
                let resp: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.Utils.retoken(fcmToken, address))
                log.debug("\(address) upload push token success", context: resp)
                DispatchQueue.main.async {
                    self.uploadedHistory[address] = fcmToken
                    self.uploadingAddress = nil
                }
            } catch {
                log.error("\(address) upload push token failed", context: error)
                DispatchQueue.main.async {
                    self.uploadingAddress = nil
                }
            }
        }
    }
}

extension PushHandler: MessagingDelegate, UNUserNotificationCenterDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        log.debug("fcm token: ", context: fcmToken)
        if let fcmToken = fcmToken, !fcmToken.isEmpty {
            uploadToken(fcmToken)
        }
    }
}
