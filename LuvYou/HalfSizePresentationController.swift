//
//  HalfSizePresentationController.swift
//  LuvYou
//
//  Created by Jeewoo Yim on 6/17/24.
//

import Foundation
import UIKit

class HalfSizePresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let height = containerView.bounds.height / 2
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        presentedView?.layer.cornerRadius = 16
        presentedView?.clipsToBounds = true
    }
}
