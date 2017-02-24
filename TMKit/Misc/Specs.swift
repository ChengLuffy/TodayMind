//
//  Specs.swift
//  TodayMind
//
//  Created by cyan on 2017/2/15.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit

/// UI Specs
public struct Specs {
  
  // MARK: - Color
  public struct Color {
    public let tint = UIColor(hex: 0x455a64)
    public let red = UIColor(hex: 0xea545d)
    public let white = UIColor.white
    public let black = UIColor.black
    public let gray = UIColor.gray
    public let lightGray = UIColor(hex: 0xe0e0e0)
    public let blueGray = UIColor(hex: 0x607d8b)
    public let separator = UIColor(hex: 0x546e7a)
    public let almostClear = UIColor(red: 0, green: 0, blue: 0, alpha: 0.002)
  }
  
  public static let color = Color()
  
  // MARK: - Font size
  public struct FontSize {
    public let tiny: CGFloat = 10
    public let small: CGFloat = 12
    public let regular: CGFloat = 14
    public let large: CGFloat = 16
  }
  
  public static let fontSize = FontSize()
  
  // MARK: - Font
  public struct Font {
    // Lato: http://www.latofonts.com/lato-free-fonts/
    private static let regularName = "Lato-Regular"
    private static let boldName = "Lato-Bold"
    public let tiny = UIFont(name: regularName, size: Specs.fontSize.tiny)
    public let small = UIFont(name: regularName, size: Specs.fontSize.small)
    public let regular = UIFont(name: regularName, size: Specs.fontSize.regular)
    public let large = UIFont(name: regularName, size: Specs.fontSize.large)
    public let smallBold = UIFont(name: boldName, size: Specs.fontSize.small)
    public let regularBold = UIFont(name: boldName, size: Specs.fontSize.regular)
    public let largeBold = UIFont(name: boldName, size: Specs.fontSize.large)
  }
  
  public static let font = Font()
}
