//
//  EKReminder+Extension.swift
//  TodayMind
//
//  Created by cyan on 2017/2/17.
//  Copyright © 2017 cyan. All rights reserved.
//

import EventKit

public extension EKReminder {
  
  /// URL to open Reminders app
  var appURL: URL {
    // x-apple-reminder://identifier
    return URL(string: String(format: "%@-%@-%@://%@", "x", "apple", "reminder", calendarItemIdentifier))!
  }
  
  /// The first alarm date or nil
  var date: Date? {
    guard let alarm = alarms?.first else { return nil }
    return alarm.absoluteDate
  }
  
  static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
  }()
  
  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd"
    return formatter
  }()
  
  /// Text to showing on widget cells
  var dateText: String? {
    guard let date = date else { return nil }
    let time = EKReminder.timeFormatter.string(from: date)
    let days = Date().daysBetween(other: date)
    let tableName = "Editor"
    if days == 0 { // Today
      return "\(Localized(key: "Today", tableName: tableName)) \(time)"
    } else if days == 1 { // Tomorrow
      return "\(Localized(key: "Tomorrow", tableName: tableName)) \(time)"
    } else { // Other
      return "\(EKReminder.dateFormatter.string(from: date)) \(time)"
    }
  }
}
