//
//  TaskListViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/11/24.
//

import UIKit
import FirebaseFirestore

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var tasks: [Date: [Task]] = [:]
    var selectedDate: Date!
    let gender = UserDefaults.standard.string(forKey: "myGender") ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeView.layer.cornerRadius = 3.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateLabel.text = dateFormatter.string(from: selectedDate)

        if gender == "여성"{
            dateLabel.textColor = UIColor.my
        }
    }
    
    // MARK: - TableView DataSource methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sortedTasks = tasks.sorted(by: { $0.key < $1.key })
        let (_, tasksForDate) = sortedTasks[section]
        return tasksForDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        
        let sortedTasks = tasks.sorted(by: { $0.key < $1.key })
        let (_, tasksForDate) = sortedTasks[indexPath.section]
        let task = tasksForDate[indexPath.row]
        
        cell.textLabel?.text = task.title
        cell.contentView.frame.origin.y += 10
        cell.contentView.frame.size.height -= 10
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortedTasks = tasks.sorted(by: { $0.key < $1.key })
        let (_, tasksForDate) = sortedTasks[indexPath.section]
        let selectedTask = tasksForDate[indexPath.row]
        
        // 이동할 TaskDetailViewController를 초기화하고 선택한 일정 정보를 전달합니다.
        let taskDetailVC = storyboard?.instantiateViewController(withIdentifier: "TaskDetailViewController") as! TaskDetailViewController
        taskDetailVC.task = selectedTask
        taskDetailVC.taskListViewController = self
        present(taskDetailVC, animated: true, completion: nil)
    }

}
