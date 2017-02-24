//
//  UIImage+Extension.swift
//  TodayMind
//
//  Created by cyan on 2017/2/19.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit

public extension UIImage {
  
  /// Image for apply tintColor to UIImageView, UIButton etc.
  var templateImage: UIImage {
    return withRenderingMode(.alwaysTemplate)
  }
}
