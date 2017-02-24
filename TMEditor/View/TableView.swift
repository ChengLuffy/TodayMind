//
//  TableView.swift
//  TodayMind
//
//  Created by cyan on 2017/2/17.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit

/// TableView for display reminders
class TableView: UITableView {
 
  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: .zero, style: .plain)
    tintColor = Specs.color.tint
    backgroundColor = .clear
    separatorStyle = .none
    tableFooterView = UIView()
    register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.identifier)
    register(SeparatorCell.self, forCellReuseIdentifier: SeparatorCell.identifier)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
