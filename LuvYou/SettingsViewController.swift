//
//  SettingsViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/14/24.
//

import UIKit
import FirebaseFirestore

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func quitButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "앱을 종료하시겠습니까?", message: "모든 데이터가 삭제됩니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
            let documentID = UserDefaults.standard.string(forKey: "documentID") ?? ""
                    let db = Firestore.firestore()
                    
                    db.collection("lovers").document(documentID).delete { error in
                        if let error = error {
                            print("에러: \(error)")
                        } else {
                            print("전체 삭제 완료.")
                            if let bundleIdentifier = Bundle.main.bundleIdentifier {
                                UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
                            }
                        }
                    }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let installViewController = storyboard.instantiateViewController(withIdentifier: "InstallViewController") as? InstallViewController {
                self.present(installViewController, animated: true, completion: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
