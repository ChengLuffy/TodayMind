//
//  Override.swift
//  TodayMind
//
//  Created by cyan on 2017/2/22.
//  Copyright © 2017 cyan. All rights reserved.
//

import Foundation
import TMKit

// Override localized with specific table name
func Localized(key: String) -> String {
  return Localized(key: key, tableName: "Editor")
}
