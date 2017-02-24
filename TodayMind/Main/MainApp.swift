//
//  MainApp.swift
//  TodayMind
//
//  Created by cyan on 2017/2/15.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit

@UIApplicationMain
class MainApp: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = UINavigationController(rootViewController: MainVC())
    window?.makeKeyAndVisible()
    setup()
    return true
  }
}

// MARK: - Customization
extension MainApp {
  func setup() {
    
    // Global view tint
    let tintColor = Specs.color.tint
    UIView.appearance().tintColor = tintColor
    
    // NavigationBar
    UINavigationBar.appearance().titleTextAttributes = [
      NSForegroundColorAttributeName: tintColor,
      NSFontAttributeName: Specs.font.largeBold as Any
    ]
    
    // Table
    let tableHeaderAppearance = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
    tableHeaderAppearance.textColor = Specs.color.gray
    tableHeaderAppearance.font = Specs.font.smallBold
    
    // BarButton
    let barButtonItemAppearance = UIBarButtonItem.appearance()
    barButtonItemAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -64), for: UIBarMetrics.default)
  }
}
