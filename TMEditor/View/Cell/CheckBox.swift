//
//  CheckBox.swift
//  TodayMind
//
//  Created by cyan on 2017/2/19.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit
import EventKit

/// CheckBox for switch complete states
class CheckBox: UIButton {
  
  private var completed: Bool!
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    // Set a fake background makes it easier to respond touch events 
    backgroundColor = Specs.color.almostClear
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(reminder: EKReminder) {
    completed = reminder.isCompleted
    tintColor = UIColor(cgColor: reminder.calendar.cgColor)
    setupImage()
  }
  
  /// Toggle states
  func toggle() {
    completed = !completed
    setupImage()
  }
  
  override var isHighlighted: Bool {
    didSet {
      UIView.animate(withDuration: 0.2) { 
        self.alpha = self.isHighlighted ? 0.4 : 1.0
      }
    }
  }
  
  // MARK: - Private
  private func setupImage() {
    if completed == true {
      setImage(#imageLiteral(resourceName: "item_completed").templateImage, for: .normal)
      accessibilityLabel = Localized(key: "VO_item_completed")
    } else {
      setImage(#imageLiteral(resourceName: "item_incomplete").templateImage, for: .normal)
      accessibilityLabel = Localized(key: "VO_item_incomplete")
    }
  }
}
