//
//  TabBarViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/24/24.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print(UserDefaults.standard.string(forKey: "myGender"))
        self.selectedIndex = 1
    }
    
}
