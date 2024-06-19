//
//  JoinStartViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/15/24.
//

import UIKit
import FirebaseFirestore
class JoinStartViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    var db = Firestore.firestore()
    let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
    var getGender:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func joinButtonTapped(_ sender: UIButton) {
        guard let name = nameField.text, !name.isEmpty else {
            showAlert(message: "이름을 입력해주세요.")
            return
        }
        
        let birthday = birthdayPicker.date
                
        let birthdayFormatter = DateFormatter()
        birthdayFormatter.dateFormat = "MM-dd"
        
        let birthdayString = birthdayFormatter.string(from: birthday)
        
        let lover2CollectionRef = db.collection("lovers").document(documentID).collection("lover1")

        lover2CollectionRef.document("info").getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error checking lover1 collection: \(error)")
            } else {
                if let document = documentSnapshot, document.exists {
                    if let data = document.data() {
                        if let birthday = data["birthday"] as? String {
                            UserDefaults.standard.set(birthday, forKey: "loverBday")
                        }
                        if let name = data["name"] as? String {
                            UserDefaults.standard.set(name, forKey: "loverName")
                        }
                        if let name = data["startDate"] as? String {
                            UserDefaults.standard.set(name, forKey: "startDate")
                        }
                        if let gender = data["gender"] as? String {
                            self.getGender = (gender == "여성") ? "남성" : "여성"
                        }
                    }
                    
                    self.saveLoverData(name: name, birthday: birthdayString)
                } else {
                    // lover1 컬렉션에 데이터가 없을 경우에도 lover2 컬렉션에 데이터를 저장
                    self.saveLoverData(name: name, birthday: birthdayString)
                }
            }
        }
    }

    func saveLoverData(name: String, birthday: String) {
        let loverData: [String: Any] = [
            "name": name,
            "birthday": birthday,
            "gender": self.getGender ?? ""
        ]
        
        let loverRef = db.collection("lovers").document(documentID)
        loverRef.collection("lover2").document("info").setData(loverData) { error in
            if let error = error {
                print("Error adding lover data: \(error)")
            } else {
                print("Lover data added successfully")
                UserDefaults.standard.set(true, forKey: "hasStartedBefore")
                UserDefaults.standard.set(2, forKey: "loverID")
                UserDefaults.standard.set(self.documentID, forKey: "documentID")
                UserDefaults.standard.set(name, forKey: "myName")
                UserDefaults.standard.set(self.getGender, forKey: "myGender")
                UserDefaults.standard.set(birthday, forKey: "myBday")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBar = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                tabBar.modalPresentationStyle = .fullScreen
                self.present(tabBar, animated: true, completion: nil)
            }
        }
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
