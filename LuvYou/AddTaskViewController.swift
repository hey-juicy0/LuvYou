//
//  AddTaskViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/28/24.
//

import UIKit
import FirebaseFirestore


class AddTaskViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var memberTogether: UIButton!
    @IBOutlet weak var memberYou: UIButton!
    @IBOutlet weak var memberMe: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeView: UIView!
    
    var calendarViewController: CalendarViewController?
    
    let db = Firestore.firestore()
    var member = ""
    var BtnArray = [UIButton]()
    let gender = UserDefaults.standard.string(forKey: "myGender") ?? ""
    let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if gender != "여성"{
            saveButton.tintColor = UIColor.your
            memberMe.tintColor = UIColor.your
            memberYou.tintColor = UIColor.my
        }
        memberMe.setTitle(UserDefaults.standard.string(forKey: "myName") ?? "", for: .normal)
        memberYou.setTitle(UserDefaults.standard.string(forKey: "loverName"), for: .normal)
        BtnArray.append(memberMe)
        BtnArray.append(memberYou)
        BtnArray.append(memberTogether)
        closeView.layer.cornerRadius = 3.0
        memberMe.backgroundColor = UIColor.systemGray6
        contentTextView.layer.borderWidth = 1.0
        if self.traitCollection.userInterfaceStyle == .dark {
            // 다크 모드일 때 테두리 컬러 설정
            contentTextView.layer.backgroundColor = UIColor.black.cgColor
        } else {
            // 라이트 모드일 때 테두리 컬러 설정
            contentTextView.layer.backgroundColor = UIColor.white.cgColor
            contentTextView.layer.borderColor = UIColor.systemGray5.cgColor
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        contentTextView.layer.cornerRadius = 5.0
        contentTextView.clipsToBounds = true
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func selectMember(_ sender: UIButton){
        for Btn in BtnArray{
            if Btn == sender{
                Btn.backgroundColor = UIColor.systemGray6
                Btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
                if let title = Btn.titleLabel?.text {
                    member = title
                }
            } else {
                Btn.backgroundColor = UIColor.clear
            }
        }
    }

    @IBAction func saveTask(_ sender: UIButton) {
        dismissKeyboard()
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let date = datePicker.date
        let content = contentTextView.text ?? ""
        let location = locationTextField.text ?? ""
        let member = member
        
        // 빈 documentID를 가진 Task를 생성
        var task = Task(documentID: "", title: title, date: date, content: content, member: member, location: location)
        
        saveTaskToFirestore(task: task) { documentID in
            if let documentID = documentID {
                task.documentID = documentID
                self.dismiss(animated: true, completion: nil)            } else {
                // 에러 처리
                print("Failed to get documentID")
            }
        }
    }

    func saveTaskToFirestore(task: Task, completion: @escaping (String?) -> Void) {
        let taskData: [String: Any] = [
            "title": task.title,
            "date": task.date,
            "content": task.content,
            "member" : task.member,
            "location": task.location
        ]
        
        let document = db.collection("lovers").document(documentID).collection("tasks").document()
        document.setData(taskData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(nil)
            } else {
                let alert = UIAlertController(title: nil, message: "일정이 추가되었습니다!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)

            }
        }
    }

}
