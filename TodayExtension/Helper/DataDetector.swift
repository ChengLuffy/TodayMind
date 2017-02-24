//
//  DataDetector.swift
//  TodayMind
//
//  Created by cyan on 2017/2/16.
//  Copyright © 2017 cyan. All rights reserved.
//

import Foundation

/// Detect screen locked
class DataDetector {
  
  private static var path: String = {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    return path + "/protected-file"
  }()
  
  static func initialize() {
    FileManager.default.createFile(
      atPath: path,
      contents: "".data(using: .utf8),
      attributes: [FileAttributeKey.protectionKey.rawValue: FileProtectionType.complete]
    )
  }
  
  static func protected() -> Bool {
    do {
      let _ = try String(contentsOfFile: path)
    } catch {
      return true
    }
    return false
  }
}
