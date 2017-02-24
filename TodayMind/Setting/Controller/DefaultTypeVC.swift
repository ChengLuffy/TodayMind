//
//  DefaultTypeVC.swift
//  TodayMind
//
//  Created by cyan on 2017/2/21.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit

class DefaultTypeVC: BaseTypeVC {
  
  fileprivate var defaultCalendar = Prefs.defaultCalendar()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = Localized(key: "List to save")
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    let calendar = calendars[indexPath.row]
    cell.accessoryType = calendar.calendarIdentifier == defaultCalendar ? .checkmark : .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    defaultCalendar = calendars[indexPath.row].calendarIdentifier
    Prefs.set(defaultCalendar: defaultCalendar)
    tableView.reloadData()
  }
}
