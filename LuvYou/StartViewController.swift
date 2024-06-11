//
//  StartViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/13/24.
//

import UIKit
import FirebaseFirestore

class StartViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var girlButton: UIButton!
    @IBOutlet weak var boyButton: UIButton!
    @IBOutlet weak var birthdayPicker: UIDatePicker!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var nameField: UITextField!
    var BtnArray = [UIButton]()
    var gender = "여성"
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeView.layer.cornerRadius = 3
        BtnArray.append(girlButton)
        BtnArray.append(boyButton)
        nameField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        return true
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func selectGender(_ sender: UIButton){
        for Btn in BtnArray {
            if Btn == sender {
                Btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                Btn.tintColor = UIColor.black
                if let title = Btn.titleLabel?.text {
                    gender = title
                } else {
                    gender = "여성"
                }
                print(gender)
            } else {
                Btn.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
                Btn.tintColor = UIColor.systemGray2
            }
        }
        
    }


    
    @IBAction func startButton(_ sender: UIButton) {
        guard let name = nameField.text, !name.isEmpty else {
            showAlert(message: "이름을 입력해주세요.")
            return
        }
        
        guard BtnArray.contains(where: { $0.tintColor == UIColor.black }) else {
            showAlert(message: "성별을 선택해주세요.")
            return
        }
        
        let birthday = birthdayPicker.date
        let startDate = startPicker.date
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
                
        let birthdayString = dateFormatter.string(from: birthday)
        let startDateString = dateFormatter.string(from: startDate)
        
        let finalGender = gender
        let randomCode = String(format: "%07d", arc4random_uniform(10000000))
        
        let loverData: [String: Any] = [
            "name": name,
            "birthday": birthdayString,
            "gender": finalGender,
            "startDate": startDateString,
        ]
        
        let loverRef = db.collection("lovers").document()
    
        
        loverRef.collection("lover1").document("info").setData(loverData) { error in
            if let error = error {
                print("Error adding lover data: \(error)")
            } else {
                print("Lover data added successfully")
                let loverDocumentID = loverRef.documentID
                self.db.collection("lovers").document(loverDocumentID).setData(["code": randomCode])
                UserDefaults.standard.set(1, forKey: "loverID")
                UserDefaults.standard.set(loverDocumentID, forKey: "documentID")
                UserDefaults.standard.set(randomCode, forKey: "code")
                UserDefaults.standard.set(startDateString, forKey: "startDate")
                UserDefaults.standard.set(name, forKey: "myName")
                UserDefaults.standard.set(finalGender, forKey: "myGender")
                UserDefaults.standard.set(birthdayString, forKey: "myBirthday")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let codeVC = storyboard.instantiateViewController(withIdentifier: "CodeViewController") as! CodeViewController
                codeVC.code = randomCode
                        codeVC.modalPresentationStyle = .fullScreen
                        self.present(codeVC, animated: true, completion: nil)
            }
        }
    }

    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
