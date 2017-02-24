//
//  Taptic.swift
//  TodayMind
//
//  Created by cyan on 2017/2/22.
//  Copyright © 2017 cyan. All rights reserved.
//

import AudioToolbox

/// Non-public, works like magic
/// Acutally you should use public API on iOS 10
public class Taptic {
  public static func play(sender: UITraitEnvironment) {
    if sender.traitCollection.forceTouchCapability == .available {
      AudioServicesPlaySystemSound(1519)
    }
  }
}
