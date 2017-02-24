//
//  TodayVC.swift
//  TodayExtension
//
//  Created by cyan on 2017/2/15.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import NotificationCenter
import TMKit
import Social

// MARK: - Today View Controller
/*
 Inherit from EditorVC to make the reminder showing quickly
 The states of TodayVC and EditorVC synced by Darwin Notification
 Refer: https://developer.apple.com/library/content/documentation/Darwin/Conceptual/MacOSXNotifcationOv/DarwinNotificationConcepts/DarwinNotificationConcepts.html
*/

class TodayVC: EditorVC {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    authReminder()
    reloadRemindersAndDisplayMode()
    DataDetector.initialize()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadRemindersAndDisplayMode()
    showEditor()
    DarwinNotificationCenter.addObserver(
      target: self,
      selector: #selector(didReceiveEditorLoadedNotification),
      name: Constants.string.editorLoadedNotification
    )
    DarwinNotificationCenter.addObserver(
      target: self,
      selector: #selector(didReceiveSyncNotification),
      name: Constants.string.syncNotification
    )
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    DarwinNotificationCenter.removeObserver(target: self, name: Constants.string.editorLoadedNotification)
    DarwinNotificationCenter.removeObserver(target: self, name: Constants.string.syncNotification)
    hideEditor()
  }
  
  // MARK: - Darwin notifications
  func didReceiveSyncNotification() {
    reloadRemindersAndDisplayMode()
  }
  
  func didReceiveEditorLoadedNotification() {
    setViewAlpha(0, animated: true)
  }
  
  fileprivate func reloadRemindersAndDisplayMode() {
    reloadReminders {
      self.widgetActiveDisplayModeReload()
    }
  }
  
  private func showEditor() {
    
    // Trick: solve incorrect width on SLComposeViewController
    Prefs.set(widgetWidth: view.width)
    
    let editor = DataDetector.protected() ? EditorVC.normalEditor() : EditorVC.extensionEditor()
    editor.modalTransitionStyle = .crossDissolve
    
    if let editor = editor as? EditorVC {
      editor.openURLHandler = { (url) in
        self.dismiss(animated: false) {
          self.extensionContext?.open(url)
        }
      }
    }
    
    editor.completionHandler = { (result) in
      self.setViewAlpha(1)
    }
    
    present(editor, animated: true)
  }
  
  private func hideEditor() {
    setViewAlpha(1)
    dismiss(animated: false)
  }
  
  private func setViewAlpha(_ alpha: CGFloat, animated: Bool = false) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.view.alpha = alpha
      }
    } else {
      view.alpha = alpha
    }
  }
}

// MARK: - Widget
extension TodayVC: NCWidgetProviding {
  
  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    reloadRemindersAndDisplayMode()
    completionHandler(.newData)
  }
  
  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    reloadRemindersAndDisplayMode()
  }
  
  func widgetActiveDisplayModeReload() {
    guard let context = extensionContext else { return }
    context.widgetLargestAvailableDisplayMode = reminders.count > 2 ? .expanded : .compact
    if context.widgetActiveDisplayMode == .compact {
      preferredContentSize = context.widgetMaximumSize(for: .compact)
    } else {
      let count = min(6, reminders.count + 1)
      let height = max(Constants.dimension.widgetHeight, CGFloat(count) * Constants.dimension.rowHeight)
      preferredContentSize = CGSize(width: 0, height: height)
    }
  }
}
