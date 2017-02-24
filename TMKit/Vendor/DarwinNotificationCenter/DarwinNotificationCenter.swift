//
//  DarwinNotificationCenter.swift
//  TodayMind
//
//  Created by cyan on 2017/2/18.
//  Copyright © 2017 cyan. All rights reserved.
//

import Foundation

private class DarwinObserver {
  
  var target: Any
  var selector: Selector
  var name: String
  
  init(target: Any, selector: Selector, name: String) {
    self.target = target
    self.selector = selector
    self.name = name
  }
}

private var observers: [DarwinObserver] = []

/// IPC between the extension and the main app
public class DarwinNotificationCenter {
  
  
  /// Add observer
  ///
  /// - Parameters:
  ///   - target: target
  ///   - selector: selector
  ///   - name: name
  public static func addObserver(target: Any, selector: Selector, name: String) {

    let observer = DarwinObserver(target: target, selector: selector, name: name)
    observers.append(observer)
    
    let handler: CFNotificationCallback = { (_, _, cfname, _, _) in
      guard let name = (cfname?.rawValue as String?) else { return }
      observers.forEach({ (observer) in
        if observer.name == name {
          Timer.scheduledTimer(
            timeInterval: 0,
            target: observer.target,
            selector: observer.selector,
            userInfo: nil,
            repeats: false
          )
        }
      })
    }
    
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      nil,
      handler,
      name as CFString,
      nil,
      .deliverImmediately
    )
  }
  
  /// Remove observer
  ///
  /// - Parameters:
  ///   - target: target
  ///   - name: name
  public static func removeObserver(target: Any, name: String) {
    
    var indexToRemove: Int?
    for (idx, item) in observers.enumerated() {
      if (item.target as AnyObject) === (target as AnyObject) {
        indexToRemove = idx
        break
      }
    }
    
    if let index = indexToRemove {
      observers.remove(at: index)
    }
    
    CFNotificationCenterRemoveObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      nil,
      CFNotificationName(name as CFString),
      nil
    )
  }
  
  /// Post notification
  ///
  /// - Parameter name: notification name
  public static func post(name: String) {
    CFNotificationCenterPostNotification(
      CFNotificationCenterGetDarwinNotifyCenter(),
      CFNotificationName(name as CFString),
      nil,
      nil,
      true
    )
  }
}
