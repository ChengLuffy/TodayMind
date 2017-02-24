//
//  TypeCell.swift
//  TodayMind
//
//  Created by cyan on 2017/2/22.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit
import EventKit

class TypeCell: BaseCell {
  
  private let titleView: UILabel = {
    let label = UILabel()
    label.textColor = Specs.color.tint
    label.font = Specs.font.large
    return label
  }()
  
  private let colorView: UIView = {
    let view = UIView()
    view.clipsToBoundsAndRasterize()
    view.layer.cornerRadius = LayoutConstants.colorViewSize * 0.5
    return view
  }()
  
  private struct LayoutConstants {
    static let colorViewSize: CGFloat = 10
    static let colorViewPadding: CGFloat = 5 * UIScreen.main.scale + LayoutConstants.colorViewSize * 0.5
    static let padding: CGFloat = 8
    static let titleViewPadding: CGFloat = 64
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: reuseIdentifier)
    selectedBackgroundView = UIView(color: Specs.color.lightGray)
    
    contentView.addSubview(colorView)
    colorView.snp.makeConstraints { (make) in
      make.left.equalTo(LayoutConstants.colorViewPadding)
      make.centerY.equalToSuperview()
      make.size.equalTo(CGSize(width: LayoutConstants.colorViewSize, height: LayoutConstants.colorViewSize))
    }
    
    contentView.addSubview(titleView)
    titleView.snp.makeConstraints { (make) in
      make.left.equalTo(colorView.snp.right).offset(LayoutConstants.padding)
      make.right.equalTo(-LayoutConstants.titleViewPadding)
      make.centerY.equalToSuperview()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(calendar: EKCalendar) {
    titleView.text = calendar.title
    colorView.backgroundColor = UIColor(cgColor: calendar.cgColor)
  }
}
