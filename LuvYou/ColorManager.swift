//
//  ColorManager.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/15/24.
//

import Foundation
import UIKit

class ColorManager {
    static let shared = ColorManager()
    
    var myColor: UIColor = UIColor.white // 기본 색상
    var yourColor: UIColor = UIColor.black // 기본 색상
    
    private init() {
        updateColors()
    }
    
    func updateColors() {
        let gender = UserDefaults.standard.string(forKey: "myGender")
        
        if gender == "남성" {
            yourColor = UIColor(red: 160/255, green: 200/255, blue: 255/255, alpha: 1.0) // .luvPink(#A0C8FF)
            myColor = UIColor(red: 255/255, green: 154/255, blue: 195/255, alpha: 1.0) // .luvBlue(#FF9AC3)
        }
    }
}
