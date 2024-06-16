//
//  ContentView.swift
//  WatchLuvYou Watch App
//
//  Created by Jeewoo Yim on 5/15/24.
//

import Foundation
import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @AppStorage("themeColor") private var themeColorString: String = "pink"
    @AppStorage("selectedMessage") private var selectedMessage: String = "보고싶어🩷"

    var body: some View {
        VStack(spacing: 20) {
            Text("마음 전송")
                .font(.title2)
                .fontWeight(.bold)

            Button(action: {
                let message = selectedMessage
                if WCSession.default.isReachable {
                    WCSession.default.sendMessage(["text": message], replyHandler: nil) { error in
                        print("Error sending message: \(error.localizedDescription)")
                    }
                }
            }) {
                Text(selectedMessage)
                    .fontWeight(.bold)
            }
            .background(Color(uiColor: themeColor))
            .foregroundColor(.white)
            .cornerRadius(25)
            .fontWeight(.bold)
        }
        .padding()
    }

    private var themeColor: UIColor {
        switch themeColorString {
        case "pink":
            return UIColor(red: 244/255.0, green: 185/255.0, blue: 211/255.0, alpha: 1)
        case "blue":
            return UIColor(red: 160/255.0, green: 200/255.0, blue: 255/255.0, alpha: 1)
        default:
            return UIColor(red: 34/255.0, green: 35/255.0, blue: 35/255.0, alpha: 1)
        }
    }
}
