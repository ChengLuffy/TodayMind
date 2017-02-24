//
//  StickyView.swift
//  TodayMind
//
//  Created by cyan on 2017/2/18.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit
import EventKit

/// InputAccessoryView use for EditView
class StickyView: UIView {
  
  // MARK: - Public
  let textField: UITextField = {
    let textField = UITextField()
    textField.textColor = Specs.color.tint
    textField.font = Specs.font.regular
    textField.returnKeyType = .done
    textField.clearButtonMode = .whileEditing
    return textField
  }()
  
  var text: String? {
    set {
      textField.text = newValue
    }
    get {
      return textField.text
    }
  }
  
  var alarmDate: Date?
  var calendarIdentifier = Prefs.defaultCalendar()
  
  var clearHandler: Handler?
  var hideHandler: Handler?
  
  // MARK: - Private
  fileprivate enum Mode {
    case collapsed      // all pickers are hidden
    case date           // showing date picker
    case list           // showing list picker
  }

  fileprivate var mode: Mode = .collapsed {
    // Animated changes after mode changed if needed
    willSet {
      if mode == .collapsed {
        switchMode(mode: newValue)
      } else {
        UIView.transition(
          with: self,
          duration: 0.3,
          options: .transitionCrossDissolve,
          animations: { 
            self.switchMode(mode: newValue)
        })
      }
    }
  }
  
  /// Use for select alarm date
  fileprivate let datePicker: UIDatePicker = {
    let picker = UIDatePicker()
    picker.date = Date().nextHour()
    return picker
  }()
  
  /// Use for select reminder list
  fileprivate let listPicker: UITableView = {
    let tableView = UITableView()
    tableView.isHidden = true
    tableView.register(TypeCell.self, forCellReuseIdentifier: TypeCell.identifier)
    tableView.tableFooterView = UIView()
    return tableView
  }()
  
  fileprivate var calendars: [EKCalendar] = []
  
  fileprivate struct LayoutConstants {
    static let regularHeight: CGFloat = Constants.dimension.rowHeight
    static let extendHeight: CGFloat = LayoutConstants.regularHeight * 5
    static let buttonPadding: CGFloat = 6
    static let buttonWidth: CGFloat = 32
    static let alarmButtonWidth: CGFloat = 28
  }
  
  fileprivate let alarmButton: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "btn_alarm").templateImage, for: .normal)
    button.accessibilityLabel = Localized(key: "VO_btn_alarm")
    button.tintColor = Specs.color.tint
    return button
  }()
  
  private let listButton: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "btn_list").templateImage, for: .normal)
    button.accessibilityLabel = Localized(key: "VO_btn_list")
    button.tintColor = Specs.color.tint
    return button
  }()
  
  private let hideButton: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "btn_down").templateImage, for: .normal)
    button.accessibilityLabel = Localized(key: "VO_btn_down")
    button.tintColor = Specs.color.tint
    return button
  }()
  
  private let topLine = UIView(color: Specs.color.lightGray)
  private let bottomLine = UIView(color: Specs.color.lightGray)
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    tintColor = Specs.color.tint
    backgroundColor = Specs.color.white
    
    addSubview(topLine)
    topLine.snp.makeConstraints { (make) in
      make.height.equalTo(Constants.dimension.onePixel)
      make.left.right.equalTo(0)
    }
    
    alarmButton.addTarget(self, action: #selector(handleAlarmButtonTapped(sender:)), for: .touchUpInside)
    addSubview(alarmButton)
    alarmButton.snp.makeConstraints { (make) in
      make.top.equalTo(0)
      make.left.equalTo(LayoutConstants.buttonPadding)
      make.height.equalTo(Constants.dimension.rowHeight)
      make.width.equalTo(LayoutConstants.alarmButtonWidth)
    }
    
    listButton.addTarget(self, action: #selector(handleListButtonTapped(sender:)), for: .touchUpInside)
    addSubview(listButton)
    listButton.snp.makeConstraints { (make) in
      make.left.equalTo(alarmButton.snp.right)
      make.top.equalTo(0)
      make.size.equalTo(CGSize(width: LayoutConstants.alarmButtonWidth, height: LayoutConstants.regularHeight))
    }
    
    hideButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
    addSubview(hideButton)
    hideButton.snp.makeConstraints { (make) in
      make.top.bottom.equalTo(alarmButton)
      make.right.equalTo(-10)
      make.width.equalTo(LayoutConstants.buttonWidth)
    }
    
    addSubview(textField)
    textField.snp.makeConstraints { (make) in
      make.top.bottom.equalTo(alarmButton)
      make.left.equalTo(listButton.snp.right).offset(LayoutConstants.buttonPadding)
      make.right.equalTo(hideButton.snp.left)
    }
    
    // MARK: Pickers
    datePicker.addTarget(self, action: #selector(handleDatePickerValueChanged(sender:)), for: .valueChanged)
    addSubview(datePicker)
    datePicker.snp.makeConstraints { (make) in
      make.left.bottom.right.equalTo(0)
      make.top.equalTo(textField.snp.bottom)
    }
    
    listPicker.delegate = self
    listPicker.dataSource = self
    addSubview(listPicker)
    listPicker.snp.makeConstraints { (make) in
      make.edges.equalTo(datePicker)
    }
    
    addSubview(bottomLine)
    bottomLine.snp.makeConstraints { (make) in
      make.height.equalTo(Constants.dimension.onePixel)
      make.left.right.equalTo(0)
      make.top.equalTo(LayoutConstants.regularHeight)
    }
    
    ReminderManager.shared.fetchAllCalendars { (calendars) in
      self.calendars = calendars
      self.listPicker.reloadData()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: Handlers
extension StickyView {
  
  /// Reset values for both datePicker and listPicker
  func initial() {
    datePicker.setDate(Date().nextHour(), animated: false)
    alarmDate = nil
    calendarIdentifier = Prefs.defaultCalendar()
    listPicker.reloadData()
  }
  
  func handleAlarmButtonTapped(sender: UIButton) {
    if mode != .date {
      showDatePicker()
    } else {
      hideDatePicker()
      alarmDate = nil // Clear
    }
  }
  
  func handleListButtonTapped(sender: UIButton) {
    if mode != .list {
      showListPicker()
    } else {
      hideListPicker()
    }
  }
  
  func hideKeyboard() {
    hideDatePicker()
    hideHandler?()
  }
  
  func handleDatePickerValueChanged(sender: UIDatePicker) {
    alarmDate = sender.date
  }
  
  func hideDatePicker() {
    alarmButton.tintColor = Specs.color.tint
    set(expanded: false)
  }
  
  fileprivate func switchMode(mode: Mode) {
    switch mode {
    case .date:
      self.listPicker.isHidden = true
      self.datePicker.isHidden = false
    case .list:
      self.listPicker.isHidden = false
      self.datePicker.isHidden = true
    default: break
    }
  }
  
  // MARK: - Pickers
  private func showDatePicker() {
    alarmButton.tintColor = Specs.color.red
    handleDatePickerValueChanged(sender: datePicker)
    set(expanded: true)
    mode = .date
  }
  
  private func hideListPicker() {
    set(expanded: false)
  }
  
  private func showListPicker() {
    set(expanded: true)
    mode = .list
  }
  
  /// Change the accessory view height (self-height)
  ///
  /// - Parameters:
  ///   - height: height
  ///   - animated: animated
  private func set(height: CGFloat, animated: Bool = true) {
    for constraint in constraints {
      if constraint.firstAttribute == .height {
        constraint.constant = height
        break
      }
    }
    if animated {
      UIView.animate(
        withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 0.75,
        initialSpringVelocity: 1,
        options: .curveEaseInOut,
        animations: {
          self.superview?.layoutIfNeeded()
      })
    }
  }
  
  /// Set expand or collapse
  ///
  /// - Parameter expanded: expanded
  private func set(expanded: Bool) {
    let height = expanded ? LayoutConstants.extendHeight : LayoutConstants.regularHeight
    set(height: height)
    if !expanded {
      mode = .collapsed
    }
  }
}

// MARK: TableView
extension StickyView: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Constants.dimension.rowHeight
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return calendars.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TypeCell.identifier, for: indexPath) as! TypeCell
    let calendar = calendars[indexPath.row]
    cell.setup(calendar: calendar)
    cell.accessoryType = calendar.calendarIdentifier == calendarIdentifier ? .checkmark : .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let calendar = calendars[indexPath.row]
    calendarIdentifier = calendar.calendarIdentifier
    tableView.reloadData()
  }
}
