//
//  TextView.swift
//  WatchLuvYou Watch App
//
//  Created by Jeewoo Yim on 5/15/24.
//

import SwiftUI

struct TextView: View {
    @State private var sendMessage: String = ""
    @AppStorage("themeColor") private var themeColorString: String = "pink"

    var body: some View {
        VStack(spacing: 15) {
            Text("메시지 전송")
                .font(.title3)
                .fontWeight(.bold)

            TextField("메시지 입력", text: $sendMessage)
                .padding()
                .cornerRadius(30)
                .background(Color(uiColor: themeColor)) // 변환된 Color 사용
                .foregroundColor(.white)
            Button(action: {
                sendMessageButtonTapped()
            })
            {
                Text("전송")
                    .fontWeight(.bold)
            }
            .padding()
            .foregroundColor(.white)
        }
        .padding()
    }

    private func sendMessageButtonTapped() {
        print("메시지 도착: \(sendMessage)")
    }
    private var themeColor: UIColor {
           switch themeColorString {
           case "pink":
               return UIColor(red: 244/255.0, green: 185/255.0, blue: 211/255.0, alpha: 1) // RGB 값을 0.0에서 1.0 사이의 값으로 변환
           case "blue":
               return UIColor(red: 160/255.0, green: 200/255.0, blue: 255/255.0, alpha: 1)
           default:
               return UIColor(red: 34/255.0, green: 35/255.0, blue: 35/255.0, alpha: 1)
           }
       }
}
