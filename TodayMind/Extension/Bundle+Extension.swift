//
//  Bundle+Extension.swift
//  TodayMind
//
//  Created by cyan on 2017/2/24.
//  Copyright © 2017 cyan. All rights reserved.
//

import Foundation

extension Bundle {
  
  var name: String {
    guard let name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String else { return "TodayMind" }
    return name
  }
  
  var version: String {
    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "1.0" }
    return version
  }
}
