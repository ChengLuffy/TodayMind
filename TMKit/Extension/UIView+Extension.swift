//
//  UIView+Extension.swift
//  TodayMind
//
//  Created by cyan on 26/10/2016.
//  Copyright © 2016 cyan. All rights reserved.
//

import UIKit

// MARK: - Convenience methods for UIView
public extension UIView {
  
  // MARK: - Convenience frame methods
  var width: CGFloat {
    return frame.width
  }
  
  var height: CGFloat {
    return frame.height
  }
  
  var x: CGFloat {
    return frame.minX
  }
  
  var y: CGFloat {
    return frame.minY
  }
  
  var size: CGSize {
    return frame.size
  }
  
  convenience init(color: UIColor) {
    self.init()
    backgroundColor = color
  }
  
  func clipsToBoundsAndRasterize() {
    clipsToBounds = true
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
  }
}
