//
//  Tracker.swift
//  TodayMind
//
//  Created by cyan on 27/10/2016.
//  Copyright © 2016 cyan. All rights reserved.
//

import Foundation

/// Log utils
public class Tracker {
  
  static func debug(_ items: Any...) {
    #if DEBUG
      print("#debug: ", items)
    #endif
  }
  
  static func error(_ items: Any...) {
    print("#error: ", items)
  }
}
