//
//  SwitchCell.swift
//  TodayMind
//
//  Created by cyan on 2017/2/21.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit

class SwitchCell: BaseCell {
  
  let switcher = UISwitch()
  
  init(title: String, identifier: String, on: Bool) {
    super.init(style: .default, reuseIdentifier: identifier)
    textLabel?.text = title
    switcher.isOn = on
    accessoryView = switcher
    selectionStyle = .none
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
