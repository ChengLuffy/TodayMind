//
//  Constants.swift
//  TodayMind
//
//  Created by cyan on 2017/2/15.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit

/// Constants in TMEditor targets
struct Constants {
  
  // MARK: - String
  struct String {
    let syncNotification = "syncNotification"
    let editorLoadedNotification = "editorLoadedNotification"
  }
  
  static var string = String()
  
  // MARK: - Padding
  struct Padding {
    let small: CGFloat = 5
    let regular: CGFloat = 12
    let large: CGFloat = 15
    let extra: CGFloat = 20
    let leftView: CGFloat = 50
  }

  static var padding = Padding()

  // MARK: - Dimension
  struct Dimension {
    // Widget height is dynamic, depends on system font size
    var level: CGFloat {
      return UIFont.preferredFont(forTextStyle: .body).pointSize
    }
    // Defaults to 110
    var widgetHeight: CGFloat {
      return 110.0 + (level - 17.0) * 5
    }
    var rowHeight: CGFloat {
      return widgetHeight / 3
    }
    var onePixel = 1.0 / UIScreen.main.scale
  }
  
  static var dimension = Dimension()
}
