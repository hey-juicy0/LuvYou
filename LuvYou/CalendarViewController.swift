//
//  CalendarViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/24/24.
//
import UIKit
import FirebaseFirestore

class CalendarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var daysOfWeekCollectionView: UICollectionView!

    var tasks: [Date: [Task]] = [:]
    var currentDate: Date = Date()
    var lastDayOfMonth: Int = 0
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        return formatter
    }()
    let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
    let startDate = UserDefaults.standard.string(forKey: "startDate") ?? ""
    let specialDays: [String] = ["12-24", "12-25", "11-11", "03-14", "05-14", "02-14"]
    let gender = UserDefaults.standard.string(forKey: "myGender") ?? ""
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!

    let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTasksFromFirestore()
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self

        daysOfWeekCollectionView.delegate = self
        daysOfWeekCollectionView.dataSource = self

        let screenWidth = UIScreen.main.bounds.width
        calendarCollectionView.frame.size.width = screenWidth
        daysOfWeekCollectionView.frame.size.width = screenWidth
        daysOfWeekCollectionView.frame.size.height = 50.0
        
        if gender != "여성"{
            daysOfWeekCollectionView.backgroundColor = UIColor.your
            leftButton.tintColor = UIColor.your
            rightButton.tintColor = UIColor.your
            addButton.tintColor = UIColor.your
            refreshButton.tintColor = UIColor.your
        }

        addButton.setTitleColor(UIColor.my, for: .normal)

        monthLabel.font = UIFont(name: "PretendardVariable-SemiBold", size: 24)
        updateMonthYearLabel()
        setupAutoLayoutConstraints()
        
    }

    func fetchTasksFromFirestore() {
        db.collection("lovers").document(documentID).collection("tasks").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.tasks = [:]
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let documentID = document.documentID
                    let title = data["title"] as? String ?? ""
                    let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                    let content = data["content"] as? String ?? ""
                    let member = data["member"] as? String ?? ""
                    let location = data["location"] as? String ?? ""
                    let task = Task(documentID: documentID, title: title, date: date, content: content, member: member, location: location)
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day], from: task.date)
                    if let taskDate = calendar.date(from: components) {
                        if self.tasks[taskDate] != nil {
                            self.tasks[taskDate]?.append(task)
                        } else {
                            self.tasks[taskDate] = [task]
                        }
                    }
                }
                self.calendarCollectionView.reloadData()
            }
        }
    }

    func updateMonthYearLabel() {
        monthLabel.text = dateFormatter.string(from: currentDate)
        let range = Calendar.current.range(of: .day, in: .month, for: currentDate)!
        lastDayOfMonth = range.count
    }

    @IBAction func prevMonthTapped(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
        updateMonthYearLabel()
        calendarCollectionView.reloadData()
        fetchTasksFromFirestore()
    }

    @IBAction func nextMonthTapped(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
        updateMonthYearLabel()
        calendarCollectionView.reloadData()
        fetchTasksFromFirestore()
    }
    func setupAutoLayoutConstraints() {
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        daysOfWeekCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
            daysOfWeekCollectionView.topAnchor.constraint(equalTo: refreshButton.bottomAnchor, constant: 10),
            daysOfWeekCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            daysOfWeekCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            daysOfWeekCollectionView.heightAnchor.constraint(equalToConstant: 40),

            calendarCollectionView.topAnchor.constraint(equalTo: daysOfWeekCollectionView.bottomAnchor, constant: 10),
            calendarCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            calendarCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            calendarCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
        ])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == daysOfWeekCollectionView {
            let width = (collectionView.bounds.width - 30) / 7
            let height = collectionView.bounds.height
            return CGSize(width: width, height: height)
        } else {
            let width = (collectionView.bounds.width - 30) / 7
            let height = collectionView.bounds.height / 6
            return CGSize(width: width, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == calendarCollectionView {
            let firstDayOfMonth = Calendar.current.dateComponents([.year, .month], from: currentDate)
            let date = Calendar.current.date(from: firstDayOfMonth)!
            let firstWeekdayOfMonth = Calendar.current.component(.weekday, from: date)
            let totalDays = lastDayOfMonth + (firstWeekdayOfMonth - 1)
            let rowCount = (totalDays % 7 == 0) ? (totalDays / 7) : (totalDays / 7) + 1
            return rowCount * 7
        } else {
            return daysOfWeek.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
            let firstDayOfMonth = Calendar.current.dateComponents([.year, .month], from: currentDate)
            let date = Calendar.current.date(from: firstDayOfMonth)!
            let firstWeekdayOfMonth = Calendar.current.component(.weekday, from: date)
            let firstDayOfWeekIndex = indexPath.item - (firstWeekdayOfMonth - 1)
            let currentDay = firstDayOfWeekIndex + 1

            if currentDay > 0 && currentDay <= lastDayOfMonth {
                cell.dateLabel.text = "\(currentDay)"
                let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                var dateComponents = DateComponents()
                dateComponents.year = components.year
                dateComponents.month = components.month
                dateComponents.day = currentDay
                if let taskDate = Calendar.current.date(from: dateComponents) {
                    
                    updateLoveLabel(for: cell.loveLabel, with: taskDate, startDate: startDate)

                    
                    updateSpecialLabel(for: cell.specialLabel, with: taskDate)
                    
                    if let tasksForDate = tasks[taskDate] {
                        if !tasksForDate.isEmpty {
                            cell.taskButton.isHidden = false
                            cell.taskButton.tag = indexPath.row
                            cell.taskButton.addTarget(self, action: #selector(taskButtonClicked(_:)), for: .touchUpInside)
                            if gender != "여성"{
                                cell.taskButton.tintColor = UIColor.your
                            }
                        } else {
                            cell.taskButton.isHidden = true
                        }
                    } else {
                        cell.taskButton.isHidden = true
                    }
                }
            } else {
                cell.dateLabel.text = ""
                cell.loveLabel.isHidden = true
                cell.specialLabel.isHidden = true
                cell.taskButton.isHidden = true
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayOfWeekCell", for: indexPath) as! DayOfWeekCell
            cell.dayLabel.text = daysOfWeek[indexPath.item]
            cell.dayLabel.font = UIFont(name: "PretendardVariable-SemiBold", size: 16)
            return cell
        }
    }
    @IBAction func refreshTapped(_ sender: UIButton) {
        calendarCollectionView.reloadData()
        fetchTasksFromFirestore()
        let alert = UIAlertController(title: nil, message: "캘린더가 새로고침 되었습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)

    }
    
    @objc func taskButtonClicked(_ sender: UIButton) {
        guard let taskListVC = storyboard?.instantiateViewController(withIdentifier: "TaskListViewController") as? TaskListViewController else { return }
        taskListVC.tasks = tasks

        let firstDayOfMonth = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let date = Calendar.current.date(from: firstDayOfMonth)!
        let firstWeekdayOfMonth = Calendar.current.component(.weekday, from: date)
        let firstDayOfWeekIndex = sender.tag - (firstWeekdayOfMonth - 1)
        let selectedDay = firstDayOfWeekIndex + 1

        var selectedDateComponents = Calendar.current.dateComponents([.year, .month], from: date)
        selectedDateComponents.day = selectedDay
        let selectedDate = Calendar.current.date(from: selectedDateComponents)!

        taskListVC.selectedDate = selectedDate
        
        present(taskListVC, animated: true, completion: nil)
    }
  
    func updateLoveLabel(for label: UILabel, with date: Date, startDate: String) {
        label.adjustsFontSizeToFitWidth = true

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let start = dateFormatter.date(from: startDate) else {
            label.isHidden = true
            return
        }

        // startDate의 하루 전날 계산
        let calendar = Calendar.current
        guard let dayBeforeStart = calendar.date(byAdding: .day, value: -1, to: start) else {
            label.isHidden = true
            return
        }

        let startComponents = calendar.dateComponents([.month, .day], from: start)
        let dateComponents = calendar.dateComponents([.month, .day], from: date)

        // 연애 시작일과 주년 표시
        if startComponents.month == dateComponents.month && startComponents.day == dateComponents.day {
            let years = calendar.dateComponents([.year], from: start, to: date).year!
            if years > 0 {
                label.text = "\(years)주년"
                label.isHidden = false
            } else if years == 0 {
                label.text = "연애시작"
                label.isHidden = false
            }
        } else {
            // 50일, 100일 단위 표시
            let daysDifference = calendar.dateComponents([.day], from: dayBeforeStart, to: date).day ?? 0
            if daysDifference > 0 && (daysDifference % 100 == 0) {
                label.text = "\(daysDifference)일"
                label.isHidden = false
            }
            else if daysDifference == 50{
                label.text = "50일"
                label.isHidden = false
            }
            else {
                label.isHidden = true
            }
        }
        if gender != "여성"{
            label.textColor = UIColor.your
        }
    }



    func updateSpecialLabel(for label: UILabel, with date: Date) {
        label.adjustsFontSizeToFitWidth = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        let dateString = dateFormatter.string(from: date)
        label.numberOfLines = 0
        label.sizeToFit()


        if specialDays.contains(dateString) {
            switch dateString {
            case "12-24":
                label.text = "크리스마스\n이브"
            case "12-25":
                label.text = "크리스마스"
            case "11-11":
                label.text = "빼빼로데이"
            case "03-14":
                label.text = "화이트데이"
            case "05-14":
                label.text = "로즈데이"
            case "02-14":
                label.text = "발렌타인\n데이"
            default:
                label.isHidden = true
            }
            label.isHidden = false
        } else {
            label.isHidden = true
        }
    }
}

class DateCell: UICollectionViewCell {
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var loveLabel: UILabel!
    @IBOutlet weak var specialLabel: UILabel!
}

class DayOfWeekCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
