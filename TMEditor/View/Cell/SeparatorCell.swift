//
//  SeparatorCell.swift
//  TodayMind
//
//  Created by cyan on 2017/2/19.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit

/// A dummy cell for display last one separator
class SeparatorCell: UITableViewCell {
  
  static let identifier = "SeparatorCell"
  private let separator = UIView(color: Specs.color.separator)
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: SeparatorCell.identifier)
    
    isUserInteractionEnabled = false
    backgroundColor = .clear
    
    contentView.addSubview(separator)
    separator.snp.makeConstraints { (make) in
      make.left.equalTo(Constants.padding.large)
      make.right.equalTo(-Constants.padding.large)
      make.top.bottom.equalTo(0)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
