//
//  JoinViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/13/24.
//

import UIKit
import FirebaseFirestore
class JoinViewController: UIViewController {
    let db = Firestore.firestore()
    @IBOutlet var closeView: UIView!
    @IBOutlet weak var codeField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        closeView.layer.cornerRadius = 3
        let tapGesture = UITapGestureRecognizer(target: self, action:
        #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        if let code = UserDefaults.standard.string(forKey: "code") {
            codeField.text = code
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func joinClick(_ sender: UIButton) {
        guard let code = codeField.text, !code.isEmpty else {
            showAlert(message: "7자리 숫자를 입력하세요")
            return
        }
        
        let loversRef = db.collection("lovers")
        
        loversRef.whereField("code", isEqualTo: code).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("에러: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            if documents.isEmpty {
                self.showAlert(message: "유효하지 않는 초대 번호입니다.")
                
            } else {
                if let document = documents.first {
                    let documentID = document.documentID
                    
                    UserDefaults.standard.set(documentID, forKey: "documentID")
                    
                    let alertController = UIAlertController(title: "확인 완료!", message: "다음 화면에서 사용자님의 이름, 생일을 입력해주세요.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let joinStartVC = storyboard.instantiateViewController(withIdentifier: "JoinStartViewController") as? JoinStartViewController {
                            self.present(joinStartVC, animated: true, completion: nil)
                        }
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
