//
//  TaskDetailViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/29/24.
//

import UIKit
import Foundation
import FirebaseFirestore

struct Task {
    var documentID: String
    var title: String
    var date: Date
    var content: String
    var member: String
    var location: String
}

class TaskDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    var taskListViewController: TaskListViewController?
    var calendarViewController: CalendarViewController?
    var task: Task?
    let name = UserDefaults.standard.string(forKey: "myName") ?? ""
    let gender = UserDefaults.standard.string(forKey: "myGender") ?? ""
    let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
    override func viewDidLoad() {
        super.viewDidLoad()
        closeView.layer.cornerRadius = 3.0
        if let task = task {
            titleLabel.text = task.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일 hh:mm a"
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            
            let dateString = dateFormatter.string(from: task.date)
            dateLabel.text = dateString
            contentTextView.text = task.content
            contentTextView.textContainer.lineFragmentPadding = 0
            memberLabel.text = task.member
            if gender != "여성"{
                if task.member == "함께"{
                    memberLabel.textColor = UIColor.luvPurple
                }
                else if task.member == name{
                    memberLabel.textColor = UIColor.your
                }
                else{
                    memberLabel.textColor = UIColor.my
                }
            }
            else{
                if task.member == "함께"{
                    memberLabel.textColor = UIColor.luvPurple
                }
                else if task.member == name{
                    memberLabel.textColor = UIColor.your
                }
                else{
                    memberLabel.textColor = UIColor.my
                }
            }
            locationLabel.text = task.location
        }
    }
    
    @IBAction func deleteTap(_ sender: UIButton) {
        if let task = task {
            let db = Firestore.firestore()
            let alert = UIAlertController(title: nil, message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
                let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
                let db = Firestore.firestore()
                db.collection("lovers").document(documentID).collection("tasks").document(task.documentID).delete { error in
                    if let error = error {
                        print("에러: \(error)")
                    } else {
                        self.dismiss(animated: true, completion: nil)
                        self.taskListViewController?.dismiss(animated: true, completion: nil)

                    }
                }
            }))
            present(alert, animated: true, completion: nil)
        }
        else {
            print("Task is nil")
        }
    }
}
