//
//  EditView.swift
//  TodayMind
//
//  Created by cyan on 2017/2/15.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit

/// Text inputing component
class EditView: UIView {
  
  // MARK: - Public
  var editButtonTappedHandler: Handler?
  var saveButtonTappedHandler: Handler?
  var startEditingHandler: Handler?
  
  // MARK: - Private
  fileprivate let editButton: UIButton = {
    let button = UIButton()
    button.setImage(#imageLiteral(resourceName: "icon_edit").templateImage, for: .normal)
    button.accessibilityLabel = Localized(key: "VO_icon_edit")
    // Set a fake background makes it easier to respond touch events
    button.backgroundColor = Specs.color.almostClear
    return button
  }()
  
  fileprivate let textField: UITextField = {
    let textField = UITextField()
    textField.font = Specs.font.regular
    textField.textColor = Specs.color.tint
    textField.returnKeyType = .done
    textField.clearButtonMode = .whileEditing
    textField.contentVerticalAlignment = .center
    return textField
  }()
  
  fileprivate let startEditingButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = Specs.color.almostClear
    return button
  }()
  
  fileprivate let saveButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle(Localized(key: "Save"), for: .normal)
    button.titleLabel?.font = Specs.font.regular
    button.sizeToFit()
    return button
  }()
  
  fileprivate let stickyView: StickyView = {
    let view = StickyView()
    view.frame = CGRect(x: 0, y: 0, width: 0, height: LayoutConstants.accessoryViewHeight)
    return view
  }()
  
  private let separator = UIView(color: Specs.color.separator)
  
  private struct LayoutConstants {
    static let accessoryViewHeight: CGFloat = Constants.dimension.rowHeight
  }
  
  // MARK: - Init
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    tintColor = Specs.color.tint
    backgroundColor = .clear
    
    editButton.addTarget(self, action: #selector(handleEditButtonTapped(sender:)), for: .touchUpInside)
    addSubview(editButton)
    editButton.snp.makeConstraints { (make) in
      make.left.top.bottom.equalTo(0)
      make.width.equalTo(Constants.padding.leftView)
    }
    
    saveButton.addTarget(self, action: #selector(handleSaveButtonTapped(sender:)), for: .touchUpInside)
    addSubview(saveButton)
    saveButton.snp.makeConstraints { (make) in
      make.top.bottom.equalTo(0)
      make.right.equalTo(-Constants.padding.large)
      make.width.equalTo(saveButton.width)
    }
    
    stickyView.clearHandler = { [weak self] in
      self?.clear()
    }
    
    stickyView.hideHandler = { [weak self] in
      self?.hideKeyboard()
    }
    
    stickyView.textField.delegate = self
    stickyView.textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
    textField.inputAccessoryView = stickyView
    textField.addTarget(self, action: #selector(textFieldValueChanged(_:)), for: .editingChanged)
    addSubview(textField)
    textField.snp.makeConstraints { (make) in
      make.centerY.height.equalTo(self)
      make.left.equalTo(editButton.snp.right)
      make.right.equalTo(saveButton.snp.left).offset(-Constants.padding.small)
    }
    
    startEditingButton.addTarget(
      self,
      action: #selector(handleStartEditingButtonTapped(sender:)),
      for: .touchUpInside
    )
    
    addSubview(startEditingButton)
    startEditingButton.snp.makeConstraints { (make) in
      make.edges.equalTo(textField)
    }
    
    addSubview(separator)
    separator.snp.makeConstraints { (make) in
      make.height.equalTo(Constants.dimension.onePixel)
      make.left.equalTo(Constants.padding.large)
      make.right.equalTo(-Constants.padding.large)
      make.bottom.equalTo(0)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func clear() {
    text = ""
    stickyView.text = ""
  }
  
  func reloadInitialText() {
    placeholder = Localized(key: "Tap to add item...")
  }
  
  func handleStartEditingButtonTapped(sender: UIButton) {
    textField.becomeFirstResponder()
    stickyView.textField.becomeFirstResponder()
  }
  
  func handleEditButtonTapped(sender: UIButton) {
    hideKeyboard()
    editButtonTappedHandler?()
  }
  
  func handleSaveButtonTapped(sender: UIButton) {
    done()
  }
  
  fileprivate func done() {
    hideKeyboard()
    saveButtonTappedHandler?()
  }
}

// MARK: - Extend properties
extension EditView {
  
  var isEnabled: Bool {
    set {
      textField.isEnabled = newValue
    }
    get {
      return textField.isEnabled
    }
  }
  
  var text: String? {
    set {
      textField.text = newValue
    }
    get {
      return textField.text
    }
  }
  
  var alarmDate: Date? {
    get {
      return stickyView.alarmDate
    }
  }
  
  var calendarIdentifier: String {
    get {
      return stickyView.calendarIdentifier
    }
  }
  
  var placeholder: String? {
    set {
      guard let string = newValue else { return }
      textField.attributedPlaceholder = NSAttributedString(
        string: string,
        attributes: [
          NSFontAttributeName: Specs.font.regular as Any,
          NSForegroundColorAttributeName: Specs.color.gray
        ]
      )
    }
    get {
      return textField.attributedPlaceholder?.string
    }
  }
}

// MARK: - EditView TextField
extension EditView: UITextFieldDelegate {

  func hideKeyboard() {
    stickyView.textField.resignFirstResponder()
    stickyView.hideDatePicker()
    textField.resignFirstResponder()
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    stickyView.initial()
    startEditingHandler?()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    done()
    return true
  }
  
  func textFieldValueChanged(_ textField: UITextField) {
    if textField === self.textField {
      stickyView.text = textField.text
    } else if textField === stickyView.textField {
      self.textField.text = textField.text
    }
  }
}
