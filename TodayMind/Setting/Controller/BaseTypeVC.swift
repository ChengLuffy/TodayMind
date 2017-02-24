//
//  BaseTypeVC.swift
//  TodayMind
//
//  Created by cyan on 2017/2/22.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit
import EventKit

let kCellIdentifier = "TypeCell"

// MARK: Base List View Controller, display all calendars for reminder
class BaseTypeVC: BaseVC {
  
  var calendars: [EKCalendar] = []
  
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.register(TypeCell.self, forCellReuseIdentifier: kCellIdentifier)
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(view)
    }
    
    ReminderManager.shared.fetchAllCalendars { (calendars) in
      self.calendars = calendars
      self.tableView.reloadData()
    }
  }
}

// MARK: - TableView
extension BaseTypeVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return calendars.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath) as! TypeCell
    cell.setup(calendar: calendars[indexPath.row])
    return cell
  }
}
