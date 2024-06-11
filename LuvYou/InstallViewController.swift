//
//  InstallViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/13/24.
//

import UIKit

class InstallViewController: UIViewController {
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UserDefaults.standard.string(forKey: "code"))
        if UserDefaults.standard.string(forKey: "documentID") != nil{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let codeVC = storyboard.instantiateViewController(withIdentifier: "CodeViewController") as! CodeViewController
            codeVC.code = UserDefaults.standard.string(forKey: "code")
                    codeVC.modalPresentationStyle = .fullScreen
                    self.present(codeVC, animated: true, completion: nil)
        }
    }

}
