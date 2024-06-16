//
//  CommunicationManager.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/17/24.
//

import Foundation
import WatchConnectivity

class CommunicationManager {
    static let shared = CommunicationManager()
    
    // iOS 앱에 값 전달
    func sendMessageToiOSApp(timestamp: TimeInterval, message: String) {
        // WatchConnectivity를 사용하여 iOS 앱으로 데이터를 전송합니다.
        if WCSession.default.isReachable {
            let message = ["timestamp": timestamp, "message": message] as [String : Any]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: { error in
                print("Error sending message to iOS app: \(error.localizedDescription)")
            })
        } else {
            print("iOS app is not reachable.")
        }
    }
}
