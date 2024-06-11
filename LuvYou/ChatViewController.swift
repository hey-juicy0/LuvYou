//
//  ChatViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/15/24.
//
import UIKit
import FirebaseFirestore

struct Message{
    let id: String?
    let text: String?
    let loverID: Int // lover1인지 lover2인지 구분
    let date: Date
    
    init(id: String? = nil, text: String?, loverID: Int, date: Date) {
        self.id = id
        self.text = text
        self.loverID = loverID
        self.date = date
    }
}
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendMessage: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    var messages = [Message]()
    let loverID = UserDefaults.standard.integer(forKey: "loverID")
    let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
    let db = Firestore.firestore()
    var chatCollectionRef: CollectionReference?
    let gender = UserDefaults.standard.string(forKey: "myGender") ?? ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print(documentID)
        stackView.isLayoutMarginsRelativeArrangement = true
                stackView.layoutMargins = UIEdgeInsets(top: 15, left: 5, bottom: 15, right: 5)
        sendMessage.layer.cornerRadius = 10
        sendMessage.layer.borderWidth = 1
        sendMessage.layer.borderColor = UIColor.systemGray5.cgColor
        sendMessage.clipsToBounds = true
        sendMessage.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        if gender != "여성"{
            sendButton.tintColor = UIColor.your
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        chatCollectionRef = db.collection("lovers").document(documentID).collection("chats")
        loadMessages()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var stackViewBottomConstraint: NSLayoutConstraint!
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
            }
            
            let keyboardHeight = keyboardFrame.height
            adjustForKeyboard(show: true, keyboardHeight: keyboardHeight)
        }

    @objc func keyboardWillHide(_ notification: Notification) {
        // 키보드가 사라질 때는 stackViewBottomConstraint의 constant 값을 0으로 설정하여 이전 상태로 돌립니다.
        stackViewBottomConstraint.constant = 0
        // 애니메이션과 함께 레이아웃 변경을 적용합니다.
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    
    func adjustForKeyboard(show: Bool, keyboardHeight: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.stackViewBottomConstraint.constant = show ? keyboardHeight - self.view.safeAreaInsets.bottom : 0
            self.tableView.contentInset.bottom = show ? keyboardHeight : 0
            self.view.layoutIfNeeded()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        var lastDate: Date?
        
        for message in messages {
            if lastDate == nil || !Calendar.current.isDate(message.date, inSameDayAs: lastDate!) {
                rowCount += 1 // New day cell
            }
            rowCount += 1 // Message cell
            lastDate = message.date
        }
        return rowCount
    }

    func loadMessages() {
        guard let chatCollectionRef = chatCollectionRef else { return }
        
        chatCollectionRef.order(by: "date", descending: false)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                self.messages.removeAll()
                
                for document in documents {
                    let data = document.data()
                    let id = document.documentID
                    let text = data["text"] as? String
                    let loverID = data["loverID"] as? Int ?? 0
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    
                    let message = Message(id: id, text: text, loverID: loverID, date: date)
                    self.messages.append(message)
                }
                
                self.tableView.reloadData()
            }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var currentIndex = indexPath.row
        var lastDate: Date?
        
        
        for message in messages {
            // Check if we need to insert a NewDayCell
            if lastDate == nil || !Calendar.current.isDate(message.date, inSameDayAs: lastDate!) {
                if currentIndex == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NewDayCell", for: indexPath) as! NewDayCell
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy년 MM월 dd일"
                    cell.date.text = dateFormatter.string(from: message.date)
                    return cell
                }
                currentIndex -= 1
            }
            
            // Check if we need to insert a MessageCell
            if currentIndex == 0 {
                let cellIdentifier = message.loverID == loverID ? "OutgoingMessageCell" : "IncomingMessageCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageCell
                
                cell.messageTextView.text = message.text
                cell.dateLabel.text = DateFormatter.localizedString(from: message.date, dateStyle: .none, timeStyle: .short)
                
                if gender != "여성"{
                    if message.loverID == loverID{
                        cell.messageTextView.backgroundColor = UIColor.your
                    }
                    else{
                        cell.messageTextView.backgroundColor = UIColor.my
                    }
                }
                cell.dateLabel.text = DateFormatter.localizedString(from: message.date, dateStyle: .none, timeStyle: .short)
                cell.dateLabel.font = UIFont(name: "PretendardVariable-Light", size: 12)
                cell.messageTextView.layer.cornerRadius = 16
                cell.messageTextView.clipsToBounds = true
                cell.messageTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                
                return cell
            }
            currentIndex -= 1
            lastDate = message.date
        }
        
        fatalError("Unhandled case in table view data source")
    }


    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func isNewDayCellNeeded(for indexPath: IndexPath) -> Bool {
        guard indexPath.row < messages.count else {
            return false
        }
        
        if indexPath.row == 0 {
            return true
        }
        
        let currentDate = messages[indexPath.row].date
        let previousDate = messages[indexPath.row - 1].date
        return !Calendar.current.isDate(currentDate, inSameDayAs: previousDate)
    }

    

    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let text = sendMessage.text, !text.isEmpty else { return }
        
        let message = Message(text: text, loverID: loverID, date: Date())
        saveMessageToFirestore(message: message)
        
        sendMessage.text = ""
    }
    


    func saveMessageToFirestore(message: Message) {
        let data: [String: Any] = [
            "text": message.text ?? "",
            "loverID": message.loverID,
            "date": Timestamp(date: message.date)
        ]
        
        chatCollectionRef?.addDocument(data: data) { error in
            if let error = error {
                print("Error saving message: \(error)")
            }
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// Custom cell class
class MessageCell: UITableViewCell {
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
}

class NewDayCell: UITableViewCell {
    @IBOutlet weak var date: UILabel!
}
