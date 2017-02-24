//
//  Prefs.swift
//  TodayMind
//
//  Created by cyan on 2017/2/16.
//  Copyright © 2017 cyan. All rights reserved.
//

import Foundation

/// Shared preferences between extensions and main app
public class Prefs {
  
  public static let shared = UserDefaults(suiteName: "group.todaymind.share")!
  
  private struct Keys {
    static let WidgetWidth = "widget.width"
    static let HideCompleted = "reminder.hidecompleted"
    static let HiddenTypes = "reminder.hiddencalendar"
    static let DefaultCalendar = "reminder.defaultcalendar"
    static let FetchLimit = "reminder.fetchlimit"
  }
  
  public static func set(widgetWidth: CGFloat) {
    shared.set(widgetWidth, forKey: Keys.WidgetWidth)
    shared.synchronize()
  }
  
  public static func widgetWidth() -> CGFloat {
    guard let object = shared.value(forKey: Keys.WidgetWidth) else { return UIScreen.main.bounds.size.width }
    return object as! CGFloat
  }
  
  public static func set(hideCompleted: Bool) {
    shared.set(hideCompleted, forKey: Keys.HideCompleted)
    shared.synchronize()
  }
  
  public static func hideCompleted() -> Bool {
    guard let object = shared.value(forKey: Keys.HideCompleted) else { return false }
    return object as! Bool
  }
  
  public static func hiddenTypes() -> [String] {
    guard let object = shared.value(forKey: Keys.HiddenTypes) else { return [] }
    return object as! [String]
  }
  
  public static func set(hiddenTypes: [String]) {
    shared.set(hiddenTypes, forKey: Keys.HiddenTypes)
    shared.synchronize()
  }
  
  public static func defaultCalendar() -> String {
    guard let object = shared.value(forKey: Keys.DefaultCalendar) else {
      return ReminderManager.shared.defaultCalendar().calendarIdentifier
    }
    return object as! String
  }
  
  public static func set(defaultCalendar: String) {
    shared.set(defaultCalendar, forKey: Keys.DefaultCalendar)
    shared.synchronize()
  }
  
  public static func limit() -> Int {
    guard let object = shared.value(forKey: Keys.FetchLimit) else { return 3 }
    return object as! Int
  }
  
  public static func set(limit: Int) {
    shared.set(limit, forKey: Keys.FetchLimit)
    shared.synchronize()
  }
}
