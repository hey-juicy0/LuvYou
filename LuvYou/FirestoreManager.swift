//
//  File.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/17/24.
//

import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()

    func saveMessage(_ message: String, timestamp: TimeInterval) {
        // Firestore에 메시지와 timestamp를 저장합니다.
        let data: [String: Any] = ["message": message, "timestamp": timestamp]
        db.collection("messages").addDocument(data: data) { error in
            if let error = error {
                print("Error adding document to Firestore: \(error.localizedDescription)")
            } else {
                print("Document added to Firestore: \(data)")
            }
        }
    }
}
