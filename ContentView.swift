//
//  ContentView.swift
//  WatchLuvYou Watch App
//
//  Created by Jeewoo Yim on 5/15/24.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @AppStorage("themeColor") private var themeColorString: String = "pink"
    @AppStorage("selectedMessage") private var selectedMessage: String = "보고싶어🩷"

    var body: some View {
        VStack(spacing: 20) { // VStack을 사용하여 제목과 버튼을 수직으로 정렬
            Text("마음 전송") // 제목 텍스트 추가
                .font(.title2) // 제목의 폰트 사이즈 조정
                .fontWeight(.bold) // 제목의 폰트 두께 조정

            Button(action: {
                 let dateFormatter = DateFormatter()
                 dateFormatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
                 let dateStr = dateFormatter.string(from: Date())
                 print(" \(selectedMessage) (\(dateStr))")
             }) {
                 Text(selectedMessage)
                     .fontWeight(.bold)
             }
            .background(Color(uiColor: themeColor)) // 변환된 Color 사용
            .foregroundColor(.white) // 텍스트 색상을 흰색으로 설정
            .cornerRadius(25) // 버튼 모서리를 둥글게
            .fontWeight(.bold)
        }
        .padding() // VStack에 패딩을 추가하여 내용이 화면 가장자리에 너무 가깝지 않도록 조정
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
