//
//  SettingsViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/14/24.
//

import UIKit
import FirebaseFirestore

class SettingsViewController: UIViewController {
    @IBOutlet weak var closeView: UIView!
    override func viewDidLoad() {
        closeView.layer.cornerRadius = 3
        super.viewDidLoad()
    }
    
    func deleteCollection(collectionRef: CollectionReference, completion: @escaping (Error?) -> Void) {
        collectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(nil)
                return
            }
            
            let batch = collectionRef.firestore.batch()
            
            documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { error in
                completion(error)
            }
        }
    }

    // 특정 문서와 모든 하위 컬렉션을 삭제하는 함수
    func deleteDocumentWithSubcollections(documentRef: DocumentReference, completion: @escaping (Error?) -> Void) {
        documentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                completion(nil)
                return
            }
            
            let subcollections = ["chats", "images", "lover1", "lover2", "tasks"]
            let group = DispatchGroup()
            
            for subcollection in subcollections {
                group.enter()
                let collectionRef = documentRef.collection(subcollection)
                self.deleteCollection(collectionRef: collectionRef) { error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                documentRef.delete { error in
                    completion(error)
                }
            }
        }
    }

    @IBAction func quitButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "앱을 종료하시겠습니까?", message: "모든 데이터가 삭제됩니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
            let db = Firestore.firestore()
            let documentRef = db.collection("lovers").document(documentID)
            
            self.deleteDocumentWithSubcollections(documentRef: documentRef) { error in
                if let error = error {
                    print("에러: \(error)")
                } else {
                    print("전체 삭제 완료.")
                    if let bundleIdentifier = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let installViewController = storyboard.instantiateViewController(withIdentifier: "InstallViewController") as? InstallViewController {
                        installViewController.modalPresentationStyle = .fullScreen
                        self.present(installViewController, animated: true, completion: nil)
                    }
                }
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
