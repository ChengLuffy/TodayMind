//
//  Date+Extension.swift
//  TodayMind
//
//  Created by cyan on 2017/2/20.
//  Copyright © 2017 cyan. All rights reserved.
//

import Foundation

public extension Date {
  
  /// Calculate remain time to human readable text
  ///
  /// - Parameter other: other date
  /// - Returns: human readable text
  func remainText(to date: Date) -> String {
    
    let remain = Int(timeIntervalSince1970 - date.timeIntervalSince1970)
    var minutes = Int(remain / 60)
    let hours = Int(minutes / 60)
    minutes = Int(minutes - hours * 60)
    
    let seconds = Int(remain - hours * 60 * 60 - minutes * 60)
    // Treat 1sec as 1min
    if seconds > 0 {
      minutes = minutes + 1
    }
    
    // Too special, should replace it with better approach
    let tableName = "Editor"
    
    if hours > 2 {
      return ""
    } else if hours > 0 && minutes > 0 {
      return String(format: Localized(key: "in %dh %dm", tableName: tableName), hours, minutes)
    } else if hours > 0 {
      return String(format: Localized(key: "in %dh", tableName: tableName), hours)
    } else if minutes > 0 {
      return String(format: Localized(key: "in %dm", tableName: tableName), minutes)
    }
    
    return ""
  }
  
  /// Return the beginning of next hour
  ///
  /// - Returns: next hour
  func nextHour() -> Date {
    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day, .hour], from: self)
    if let hour = components.hour {
      components.hour = hour + 1
    }
    return calendar.date(from: components) ?? self
  }
  
  /// Get days between two dates
  ///
  /// - Parameter other: other date
  /// - Returns: days
  func daysBetween(other: Date) -> Int {
    let calendar = Calendar.current
    let date1 = calendar.startOfDay(for: self)
    let date2 = calendar.startOfDay(for: other)
    let components = calendar.dateComponents([.day], from: date1, to: date2)
    return components.day ?? 0
  }
}
