//
//  EditorVC.swift
//  TodayEditor
//
//  Created by cyan on 2017/2/16.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import Social
import TMKit
import EventKit

/// The most important VC for text editing and displaying reminder list

/*
 There're two ways to showing this VC
 1. When screen is not locked, will init by SLComposeViewController(forServiceType: ""),
 It's scrollable and the inputing experience is perfect, because that's a share extension.
 2. When screen is locked, then init by EditorVC()
 The user interactions is limited, just like a normal widget.
*/

class EditorVC: SLComposeViewController {
  
  // MARK: - Public
  var reminders: [EKReminder] = []
  var openURLHandler: ((URL) -> ())?
  
  // MARK: - Private
  fileprivate let editView = EditView()
  fileprivate let tableView = TableView()
  fileprivate var timer: Timer?
  fileprivate var now = Date()
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  /// Perfect user experience editor
  ///
  /// - Returns: SLComposeViewController
  static func extensionEditor() -> SLComposeViewController {
    if let editor = SLComposeViewController(forServiceType: "app.cyan.todaymind.todayeditor") {
      return editor
    } else {
      return EditorVC()
    }
  }
  
  /// Limited user experience editor
  ///
  /// - Returns: EditorVC
  static func normalEditor() -> EditorVC {
    return EditorVC()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    editView.reloadInitialText()
    view.addSubview(editView)
    editView.snp.makeConstraints { (make) in
      make.top.left.equalTo(0)
      make.width.equalTo(Prefs.widgetWidth())
      make.height.equalTo(Constants.dimension.rowHeight)
    }
    
    editView.editButtonTappedHandler = {
      self.editButtonTapped()
    }
    
    editView.saveButtonTappedHandler = {
      self.saveButtonTapped()
    }
    
    editView.startEditingHandler = {
      self.setTableView(editing: false)
    }
    
    tableView.delegate = self
    tableView.dataSource = self
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.left.bottom.right.equalTo(0)
      make.top.equalTo(editView.snp.bottom)
    }
    
    reloadReminders()
    
    // Trick: disable for a little while
    tableView.isUserInteractionEnabled = false
    performAfterDelay(sec: 0.3) {
      self.tableView.isUserInteractionEnabled = true
    }
    
    DarwinNotificationCenter.post(name: Constants.string.editorLoadedNotification)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    editView.reloadInitialText()
    setupTimer()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    editView.hideKeyboard()
    invalidateTimer()
  }
  
  private func editButtonTapped() {
    toggleTableViewEditing()
  }
  
  private func saveButtonTapped() {
    editView.hideKeyboard()
    guard let text = editView.text else { return }
    editView.clear()
    saveReminder(title: text, alarmDate: editView.alarmDate, calendarIdentifier: editView.calendarIdentifier)
  }
}

// MARK: - EventKit
extension EditorVC {
  
  func authReminder() {
    ReminderManager.shared.auth()
  }
  
  func reloadReminders(completionHandler: Handler? = nil) {
    ReminderManager.shared.fetch { (reminders) in
      self.reminders = reminders
      self.tableView.reloadData()
      completionHandler?()
    }
  }
  
  fileprivate func toggleTableViewEditing() {
    setTableView(editing: !tableView.isEditing)
  }
  
  fileprivate func setTableView(editing: Bool) {
    tableView.setEditing(editing, animated: true)
  }
  
  /// Create a reminder
  ///
  /// - Parameters:
  ///   - title: title
  ///   - alarmDate: alarmDate?
  ///   - calendarIdentifier: calendarIdentifier
  fileprivate func saveReminder(title: String, alarmDate: Date?, calendarIdentifier: String) {
    guard let reminder = ReminderManager.shared.save(
      title: title,
      alarmDate: alarmDate,
      calendarIdentifier: calendarIdentifier
    ) else {
      return
    }
    reminders.insert(reminder, at: 0)
    tableView.beginUpdates()
    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    tableView.endUpdates()
    reloadIndexPaths()
    syncReminder()
  }
  
  /// Remove reminder from data side
  ///
  /// - Parameter indexPath: indexPath
  fileprivate func removeReminder(at indexPath: IndexPath) {
    ReminderManager.shared.remove(reminder: reminders[indexPath.row])
    removeTableViewCell(at: indexPath)
    syncReminder()
  }
  
  /// Remove reminder from UI side
  ///
  /// - Parameter indexPath: indexPath
  fileprivate func removeTableViewCell(at indexPath: IndexPath) {
    reminders.remove(at: indexPath.row)
    tableView.beginUpdates()
    tableView.deleteRows(at: [indexPath], with: .fade)
    tableView.endUpdates()
    reloadIndexPaths()
  }
  
  /// Toggle reminder's complete states
  ///
  /// - Parameter indexPath: indexPath
  fileprivate func toggleReminder(at indexPath: IndexPath) {
    let reminder = reminders[indexPath.row]
    ReminderManager.shared.toggle(reminder: reminder)
    syncReminder()
    // Remove cell if `hideCompleted`
    if reminder.isCompleted && Prefs.hideCompleted() {
      performAfterDelay(sec: 0.5) {
        self.removeTableViewCell(at: indexPath)
      }
    }
  }
  
  /// Copy title of a reminder to pasteboard
  ///
  /// - Parameter indexPath: indexPath
  fileprivate func copyReminder(at indexPath: IndexPath) {
    ReminderManager.shared.copy(reminder: reminders[indexPath.row])
    setTableView(editing: false)
  }
  
  /// Sync states between share extension and widget
  private func syncReminder() {
    performAfterDelay(sec: 0.3) {
      DarwinNotificationCenter.post(name: Constants.string.syncNotification)
    }
  }
  
  /// Reload index paths to make sure cells handler works fine
  private func reloadIndexPaths() {
    performAfterDelay(sec: 0.3) {
      self.tableView.reloadData()
    }
  }
}

// MARK: - TableView
extension EditorVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // Add a cell for last separator
    return reminders.count + 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    // Separator cell
    if indexPath.row == reminders.count {
      // Don't show if there's only one cell
      if reminders.count > 1 {
        return 0
      } else {
        // Equals to a separator's height
        return Constants.dimension.onePixel
      }
    } else {
      // Normal cell height
      return Constants.dimension.rowHeight
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // Separator cell
    if indexPath.row == reminders.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: SeparatorCell.identifier, for: indexPath) as! SeparatorCell
      return cell
    } else {
      // Reminder cell
      let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.identifier, for: indexPath) as! ReminderCell
      cell.setup(reminder: reminders[indexPath.row], now: now)
      cell.toggleActionHandler = { [weak self] in
        self?.toggleReminder(at: indexPath)
      }
      // Hide the first one separator
      cell.separatorHidden = indexPath.row == 0
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard indexPath.row < reminders.count else { return }
    let url = reminders[indexPath.row].appURL
    open(url: url)
    openURLHandler?(url)
  }
  
  // MARK: - Swipe to delete & copy
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return indexPath.row < reminders.count
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let deletAction = UITableViewRowAction(style: .destructive, title: Localized(key: "Delete")) { (_, indexPath) in
      self.removeReminder(at: indexPath)
      Taptic.play(sender: self)
    }
    let copyAction = UITableViewRowAction(style: .default, title: Localized(key: "Copy")) { (_, indexPath) in
      self.copyReminder(at: indexPath)
      Taptic.play(sender: self)
    }
    copyAction.backgroundColor = Specs.color.tint
    return [deletAction, copyAction]
  }
}

// MARK: ScrollView
extension EditorVC: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    editView.hideKeyboard()
  }
}

// MARK: Timer
extension EditorVC {
  
  /// Reload the tableView to update time label
  func fireRefresh() {
    now = Date()
    tableView.reloadData()
  }
  
  /// Fire refreshing in every seconds is expensive,
  /// we need to figure out the remain seconds to next minute,
  /// so that we can refreshing in every minutes
  fileprivate func setupTimer() {
    
    invalidateTimer()
    
    // Get appropriate fire date
    let components = Calendar.current.dateComponents([.second], from: Date())
    guard let second = components.second else { return }
    let delay = TimeInterval(60 - second + 1)
    let fireDate = Date(timeIntervalSinceNow: delay)
    
    // Trigger in every minutes
    timer = Timer(
      fireAt: fireDate,
      interval: 60,
      target: self,
      selector: #selector(fireRefresh),
      userInfo: nil,
      repeats: true
    )

    guard let timer = timer else { return }
    RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
  }
  
  fileprivate func invalidateTimer() {
    timer?.invalidate()
  }
}
