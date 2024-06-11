//
//  SettingsView.swift
//  WatchLuvYou Watch App
//
//  Created by Jeewoo Yim on 5/15/24.
//

// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @AppStorage("themeColor") private var themeColorString: String = "pink"
    @AppStorage("selectedMessage") private var selectedMessage: String = "보고싶어🩷"
    @State private var newMessage: String = ""
    @State private var messages = ["보고싶어🩷","사랑해🩷", "항상 고마워🩷", "보고싶어🥲"]
    
    let themeColors = ["blue", "pink", "default"]
    let themeColorNames = ["블루", "핑크", "그레이"]
    
    var body: some View {
        List {
            Picker("버튼 색상", selection: $themeColorString) {
                ForEach(Array(zip(themeColors, themeColorNames)), id: \.0) { value in
                    Text(value.1).tag(value.0)             }
            }
            
            Picker("메시지 선택", selection: $selectedMessage) {
                ForEach(messages, id: \.self) { message in
                    Text(message).tag(message)                }
            }
            
            HStack {
                TextField("메시지 추가(8글자 이내)", text: $newMessage)
                // SwiftUI에서는 아래와 같이 입력 값 변경을 감지할 수 있습니다.
                    .onReceive(newMessage.publisher.collect()) {
                        self.newMessage = String($0.prefix(8))
                    }
                Button(action: {
                    if !newMessage.isEmpty {
                        messages.append(newMessage)
                        newMessage = ""
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }
}
