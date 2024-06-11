//
//  PopUpViewController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 5/25/24.
//

import UIKit

class PopupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 팝업 크기 설정
        self.preferredContentSize = CGSize(width: 250, height: 300)
        
        // 반투명 배경 설정
        self.view.layer.cornerRadius = 12
        self.view.clipsToBounds = true
    }
}
