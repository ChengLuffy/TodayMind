//
//  UIViewController+Extension.swift
//  TodayMind
//
//  Created by cyan on 2017/2/18.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit

public extension UIViewController {

  /// Open url inside app extension
  ///
  /// - Parameter url: url
  func open(url: URL) {
    var responder: UIResponder? = self as UIResponder
    let selector = #selector(openURL(_:))
    while responder != nil {
      if responder! is UIApplication {
        responder!.perform(selector, with: url)
        return
      }
      responder = responder?.next
    }
  }
  
  /// Fake selector to suppress compile error
  ///
  /// - Parameter url: useless
  /// - Returns: useless
  func openURL(_ url: URL) -> Bool {
    return true
  }
}
