//
//  ConnectivityProvider.swift
//  WatchLuvYou Watch App
//
//  Created by Jeewoo Yim on 6/17/24.
//

import Foundation
import WatchConnectivity

class ConnectivityProvider: NSObject, WCSessionDelegate {
    static let shared = ConnectivityProvider()

    private override init() {
        super.init()
    }

    func startSession() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let text = message["text"] as? String {
            CommunicationManager().saveMessage(text)
        }
    }
}
