//
//  Interface.swift
//  WatchLuvYou Watch App
//
//  Created by Jeewoo Yim on 5/15/24.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBAction func buttonPressed() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd, HH:mm:ss"
        let dateString = formatter.string(from: now)
        
        print("꼬망이가 당신을 보고싶어합니다. \(dateString)")
    }
    @IBOutlet var myButton: WKInterfaceButton!
    
}
