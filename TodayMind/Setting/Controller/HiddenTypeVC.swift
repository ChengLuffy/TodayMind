//
//  HiddenTypeVC.swift
//  TodayMind
//
//  Created by cyan on 2017/2/21.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit
import EventKit

class HiddenTypeVC: BaseTypeVC {
  
  // Convert to Set make it faster for searching
  fileprivate var hiddenTypes = Set(Prefs.hiddenTypes())
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = Localized(key: "Lists to show")
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    let calendar = calendars[indexPath.row]
    cell.accessoryType = hiddenTypes.contains(calendar.calendarIdentifier) ? .none : .checkmark
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let identifier = calendars[indexPath.row].calendarIdentifier
    if hiddenTypes.contains(identifier) {
      hiddenTypes.remove(identifier)
    } else {
      hiddenTypes.insert(identifier)
    }
    Prefs.set(hiddenTypes: Array(hiddenTypes))
    tableView.reloadData()
  }
}
