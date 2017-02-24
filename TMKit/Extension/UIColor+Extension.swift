//
//  UIColor+Extension.swift
//  TodayMind
//
//  Created by cyan on 26/10/2016.
//  Copyright © 2016 cyan. All rights reserved.
//

import UIKit

// MARK: - Convenience methods for UIColor
public extension UIColor {
  
  /// Init color without divide 255.0
  ///
  /// - Parameters:
  ///   - r: (0 ~ 255) red
  ///   - g: (0 ~ 255) green
  ///   - b: (0 ~ 255) blue
  ///   - a: (0 ~ 1) alpha
  convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
  }
  
  /// Init color without divide 255.0
  ///
  /// - Parameters:
  ///   - r: (0 ~ 255) red
  ///   - g: (0 ~ 255) green
  ///   - b: (0 ~ 1) alpha
  convenience init(r: Int, g: Int, b: Int) {
    self.init(r: r, g: g, b: b, a: 1)
  }
  
  /// Init color with hex code
  ///
  /// - Parameter hex: hex code (eg. 0x00eeee)
  convenience init(hex: Int) {
    self.init(r: (hex & 0xff0000) >> 16, g: (hex & 0xff00) >> 8, b: (hex & 0xff), a: 1)
  }
}
