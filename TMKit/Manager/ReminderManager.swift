//
//  ReminderManager.swift
//  TodayMind
//
//  Created by cyan on 2017/2/15.
//  Copyright © 2017 cyan. All rights reserved.
//

import EventKit

public typealias ReminderFetchHandler = (([EKReminder]) -> ())
public typealias CalendarFetchHandler = (([EKCalendar]) -> ())

/// EventKit operations
public class ReminderManager {
  
  public static let shared = ReminderManager()
  private let store = EKEventStore()
  
  /// Request access reminder
  ///
  /// - Parameter completionHandler: completionHandler
  public func auth(completionHandler: Handler? = nil) {
    store.requestAccess(to: .reminder) { (granted, error) in
      completionHandler?()
    }
  }
  
  /// Create a new reminder
  ///
  /// - Parameter title: title
  /// - Returns: new reminder or nil
  public func save(title: String, alarmDate: Date?, calendarIdentifier: String? = Prefs.defaultCalendar()) -> EKReminder? {
    // Skip empty title
    guard strlen(title) > 0 else {
      return nil
    }
    
    let reminder = EKReminder(eventStore: store)
    
    // Set title
    reminder.title = title
    
    // Set calendar
    let calendars = store.calendars(for: .reminder)
    var notFound = true
    
    for calendar in calendars {
      if calendar.calendarIdentifier == calendarIdentifier {
        reminder.calendar = calendar
        notFound = false
        break
      }
    }
    
    if notFound { // Bad case
      reminder.calendar = store.defaultCalendarForNewReminders()
      Tracker.error("Oops! appropriate list type not found")
    }
    
    // Set alarm
    if let alarmDate = alarmDate {
      let alarm = EKAlarm(absoluteDate: alarmDate)
      reminder.addAlarm(alarm)
    }
    
    do {
      try store.save(reminder, commit: true)
    } catch {
      Tracker.error("Add reminder failed")
    }
    
    return reminder
  }
  
  /// Remove a reminder
  ///
  /// - Parameter reminder: reminder
  public func remove(reminder: EKReminder) {
    do {
      try store.remove(reminder, commit: true)
    } catch {
      Tracker.error("Remove reminder failed")
    }
  }
  
  /// Toggle complete states of a reminder
  ///
  /// - Parameter reminder: reminder
  public func toggle(reminder: EKReminder) {
    reminder.isCompleted = !reminder.isCompleted
    do {
      try store.save(reminder, commit: true)
    } catch {
      Tracker.error("Toggle reminder failed")
    }
  }
  
  /// Fetch reminders
  ///
  /// - Parameter completionHandler: completionHandler
  public func fetch(completionHandler: @escaping ReminderFetchHandler) {
    // Fetch in all calendars
    let calendars = store.calendars(for: .reminder)
    let predicate = store.predicateForReminders(in: calendars)
    let hideCompleted = Prefs.hideCompleted()
    let hiddenTypes = Set(Prefs.hiddenTypes())
    let now = Date()
    let limit = Prefs.limit()
    
    store.fetchReminders(matching: predicate) { (reminders) in
      
      // Filtering & sorting
      let results = reminders?.filter({ (reminder) -> Bool in
        if hideCompleted && reminder.isCompleted { // Hide completed reminder if needed
          return false
        } else if hiddenTypes.contains(reminder.calendar.calendarIdentifier) { // Hidden by type
          return false
        } else if let date = reminder.date { // Today reminders
          let days = now.daysBetween(other: date)
          return days >= 0 && days < limit
        } else { // Reminders without specific date
          return true
        }
      }).sorted(by: { (first, second) -> Bool in
        if (first.date == nil) != (second.date == nil) { // Reminder has alarm is more important
          if first.date == nil && second.date != nil {
            return false
          } else {
            return true
          }
        } else {
          if first.date == nil { // No alarm, sort by creation & modified date
            if let lastModifiedDate1 = first.lastModifiedDate, let lastModifiedDate2 = second.lastModifiedDate {
              return lastModifiedDate1.compare(lastModifiedDate2) == .orderedDescending
            } else if let creationDate1 = first.creationDate, let creationDate2 = second.creationDate {
              return creationDate1.compare(creationDate2) == .orderedDescending
            } else {
              return true
            }
          } else { // Sort by alarm date
            return first.date!.compare(second.date!) == .orderedAscending
          }
        }
      })
      
      // Back to main thread
      performOnMainThread {
        completionHandler(results ?? [])
      }
    }
  }
  
  /// Fetch all calendars for reminder
  ///
  /// - Parameter completionHandler: completionHandler
  public func fetchAllCalendars(completionHandler: @escaping CalendarFetchHandler) {
    let calendars = store.calendars(for: .reminder)
    completionHandler(calendars)
  }
  
  /// Get default calendar
  ///
  /// - Returns: default calendar
  public func defaultCalendar() -> EKCalendar {
    return store.defaultCalendarForNewReminders()
  }
  
  /// Copy a reminder (title) to pasteboard
  ///
  /// - Parameter reminder: reminder
  public func copy(reminder: EKReminder) {
    UIPasteboard.general.string = reminder.title
  }
}
