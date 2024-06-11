//
//  CodeViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/13/24.
//

import UIKit
import FirebaseFirestore

class CodeViewController: UIViewController {
    @IBOutlet weak var codeLabel: UILabel!
    var code: String?
    let db = Firestore.firestore()
    override func viewDidLoad() {
            super.viewDidLoad()
        codeLabel.text = code
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
            codeLabel.isUserInteractionEnabled = true
            codeLabel.addGestureRecognizer(tapGesture)
        }

        @objc func labelTapped() {
            guard let text = codeLabel.text else { return }
            UIPasteboard.general.string = text
            showAlert(message: "초대 번호가 클립보드에 복사되었습니다.")
        }
    
    @IBAction func goHome(_ sender: UIButton) {
        checkLover2Collection()
    }
    
    func checkLover2Collection() {
            guard let documentID = UserDefaults.standard.string(forKey: "documentID") else {
                showAlert(message: "문서 ID를 찾을 수 없습니다.")
                return
            }
        let lover2CollectionRef = db.collection("lovers").document(documentID).collection("lover2")

            lover2CollectionRef.document("info").getDocument { (documentSnapshot, error) in
                if let error = error {
                    print("Error checking lover2 collection: \(error)")
                    self.showAlert(message: "오류가 발생했습니다.")
                } else {
                    if let document = documentSnapshot, document.exists {
                        if let data = document.data() {
                            if let birthday = data["birthday"] as? String {
                                UserDefaults.standard.set(birthday, forKey: "loverBday")
                            }
                            if let name = data["name"] as? String {
                                UserDefaults.standard.set(name, forKey: "loverName")
                            }
                        }
                        self.presentTabBarController()
                    } else {
                        self.showAlert(message: "아직 연인이 입장하지 않았습니다!")
                    }
                }
            }
        }

        func presentTabBarController() {
            UserDefaults.standard.set(true, forKey: "hasStartedBefore")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: true, completion: nil)
            }
        }

        private func showAlert(message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
}
