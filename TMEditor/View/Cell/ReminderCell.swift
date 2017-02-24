//
//  ReminderCell.swift
//  TodayMind
//
//  Created by cyan on 2017/2/17.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import EventKit
import TMKit

/// TableViewCell for display reminder
class ReminderCell: UITableViewCell {
  
  static let identifier = "ReminderCell"
  
  // MARK: - Public
  var separatorHidden: Bool {
    set {
      separator.isHidden = newValue
    }
    get {
      return separator.isHidden
    }
  }
  
  var toggleActionHandler: Handler?
  
  // MARK: - Private
  fileprivate let checkbox = CheckBox()
  
  fileprivate let titleView: UILabel = {
    let label = UILabel()
    label.textAlignment = .left
    label.font = Specs.font.regular
    label.textColor = Specs.color.tint
    return label
  }()
  
  fileprivate let dateView: UILabel = {
    let label = UILabel()
    label.textAlignment = .right
    label.font = Specs.font.small
    label.textColor = Specs.color.blueGray
    return label
  }()
  
  fileprivate let remainView: UILabel = {
    let label = UILabel()
    label.font = Specs.font.tiny
    label.textColor = Specs.color.white
    label.backgroundColor = Specs.color.red
    label.textAlignment = .center
    label.clipsToBoundsAndRasterize()
    label.layer.cornerRadius = 2
    label.isHidden = true
    return label
  }()
  
  fileprivate let separator = UIView(color: Specs.color.separator)
  fileprivate var remainText = ""
  
  fileprivate struct LayoutConstants {
    static let checkboxWidth: CGFloat = Constants.padding.leftView
    static let deleteButtonSize = CGSize(width: 36, height: 20)
    static let remainViewHeight: CGFloat = 14
    static let remainViewPadding: CGFloat = 8
  }
  
  // MARK: - Init
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: .default, reuseIdentifier: ReminderCell.identifier)
    
    tintColor = Specs.color.tint
    backgroundColor = .clear
    selectionStyle = .none
    
    checkbox.addTarget(self, action: #selector(handleCheckBoxTapped(sender:)), for: .touchUpInside)
    contentView.addSubview(checkbox)
    checkbox.snp.makeConstraints { (make) in
      make.width.equalTo(LayoutConstants.checkboxWidth)
      make.left.top.bottom.equalTo(0)
    }
    
    contentView.addSubview(separator)
    separator.snp.makeConstraints { (make) in
      make.height.equalTo(Constants.dimension.onePixel)
      make.left.equalTo(Constants.padding.large)
      make.right.equalTo(-Constants.padding.large)
      make.top.equalTo(0)
    }
    
    contentView.addSubview(titleView)
    contentView.addSubview(dateView)
    contentView.addSubview(remainView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(reminder: EKReminder, now: Date) {
    checkbox.set(reminder: reminder)
    titleView.text = reminder.title
    dateView.text = reminder.dateText
    remainText = reminder.date?.remainText(to: now) ?? ""
    setNeedsDisplay()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    // Clear states to prevent error drawing when reused
    dateView.text = ""
    remainText = ""
    remainView.isHidden = true
  }
  
  override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    let alpha: CGFloat = highlighted ? 0.4 : 1.0
    UIView.animate(withDuration: 0.2) { 
      self.titleView.alpha = alpha
    }
  }
}

// MARK: - Layout
extension ReminderCell {
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    dateView.sizeToFit()
    
    // Layout date view
    let contentViewWidth = min(Prefs.widgetWidth(), contentView.width)
    let contentViewHeight = contentView.height
    let x = contentViewWidth - dateView.width - Constants.padding.large
    let y = (contentViewHeight - dateView.height) * 0.5
    let width = dateView.width
    let height = dateView.height
    
    // Layout remain text view
    if strlen(remainText) > 0 {
      dateView.frame = CGRect(x: x, y: y - 9, width: width, height: height)
      remainView.isHidden = false
      remainView.text = remainText
      remainView.sizeToFit()
      remainView.frame = CGRect(
        x: dateView.frame.maxX - remainView.width - LayoutConstants.remainViewPadding,
        y: dateView.frame.maxY,
        width: remainView.width + LayoutConstants.remainViewPadding,
        height: LayoutConstants.remainViewHeight
      )
    } else {
      dateView.frame = CGRect(x: x, y: y, width: width, height: height)
      remainView.isHidden = true
    }
    
    // Layout title view
    let rightViewsWidth = max(dateView.width, remainView.width) + Constants.padding.regular + Constants.padding.large
    titleView.frame = CGRect(
      x: LayoutConstants.checkboxWidth,
      y: 0,
      width: contentViewWidth - LayoutConstants.checkboxWidth - rightViewsWidth,
      height: contentViewHeight
    )
  }
}

// MARK: - Actions
extension ReminderCell {
  func handleCheckBoxTapped(sender: CheckBox) {
    sender.toggle()
    toggleActionHandler?()
  }
}
