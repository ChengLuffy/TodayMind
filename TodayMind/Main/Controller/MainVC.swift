//
//  MainVC.swift
//  TodayMind
//
//  Created by cyan on 2017/2/15.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit
import AVFoundation
import AVKit
import SafariServices

// MARK: - Main View Controller
class MainVC: BaseVC {
  
  fileprivate typealias RowModel = Dictionary<String, String>
  
  fileprivate struct Keys {
    static let Section = "section"
    static let Rows = "rows"
    static let Title = "title"
    static let Link = "link"
    static let Id = "id"
    static let ReminderList = Localized(key: "Lists to show")
    static let DefaultCalendar = Localized(key: "List to save")
    static let FetchingLimitation = Localized(key: "Fetching limitation")
    static let HideCompleted = Localized(key: "Hide completed reminders")
    static let DisclosureKeys = Set([Keys.ReminderList, Keys.DefaultCalendar, Keys.FetchingLimitation])
  }
  
  /// Datasource
  fileprivate let data = [
    [
      Keys.Section: Localized(key: "Guide"),
      Keys.Rows: [
        [Keys.Title: Localized(key: "Video")],
        [Keys.Title: Localized(key: "Website"), Keys.Link: "http://ioszen.com/todaymind"]
      ]
    ],
    [
      Keys.Section: Localized(key: "Settings"),
      Keys.Rows: [
        [Keys.Title: Keys.ReminderList],
        [Keys.Title: Keys.DefaultCalendar],
        [Keys.Title: Keys.FetchingLimitation],
        [Keys.Title: Keys.HideCompleted]
      ]
    ],
    [
      Keys.Section: Localized(key: "Feedback"),
      Keys.Rows: [
        [Keys.Title: Localized(key: "Email"), Keys.Id: "log.e@qq.com", Keys.Link: "mailto:log.e@qq.com"],
        [Keys.Title: Localized(key: "Twitter"), Keys.Id: "@cyanapps", Keys.Link: "https://twitter.com/cyanapps"],
        [Keys.Title: Localized(key: "Weibo"), Keys.Id: "@StackOverflowError", Keys.Link: "http://weibo.com/u/1765732340"]
      ]
    ],
    [
      Keys.Section: Localized(key: "Misc"),
      Keys.Rows: [
        [Keys.Title: Localized(key: "Rate"), Keys.Link: "https://itunes.apple.com/app/id1207158665"],
        [Keys.Title: Localized(key: "GitHub"), Keys.Link: "https://github.com/cyanzhong/TodayMind"],
      ]
    ]
  ]
  
  /// Static cells
  fileprivate struct NonreusableCells {
    static let hideCompletedCell = SwitchCell(
      title: Keys.HideCompleted,
      identifier: "HideCell",
      on: Prefs.hideCompleted()
    )
  }
  
  private struct LayoutConstants {
    static let versionViewHeight: CGFloat = 64
  }
  
  private let tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .grouped)
    view.register(BaseCell.self, forCellReuseIdentifier: BaseCell.identifier)
    return view
  }()
  
  private let versionView: UIView = {
    let label = UILabel()
    label.textColor = Specs.color.blueGray
    label.font = Specs.font.smallBold
    label.text = "Ver \(Bundle.main.version) © CYAN LAB"
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: LayoutConstants.versionViewHeight))
    view.addSubview(label)
    label.snp.makeConstraints { (make) in
      make.center.equalTo(view)
    }
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = Bundle.main.name
    ReminderManager.shared.auth()
    
    // Setup static cells
    NonreusableCells.hideCompletedCell.switcher.addTarget(
      self,
      action: #selector(switchHideCompletedReminder),
      for: .valueChanged
    )
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = versionView
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(view)
    }
  }
  
  fileprivate func rows(at section: Int) -> Array<Any> {
    return data[section][Keys.Rows] as! Array<Any>
  }
  
  fileprivate func rowModel(at indexPath: IndexPath) -> RowModel {
    return rows(at: indexPath.section)[indexPath.row] as! RowModel
  }
  
  func switchHideCompletedReminder() {
    Prefs.set(hideCompleted: !Prefs.hideCompleted())
  }
}

// MARK: - TableView
extension MainVC: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return data[section][Keys.Section] as? String
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rows(at: section).count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = rowModel(at: indexPath)
    guard let title = model[Keys.Title] else { return UITableViewCell() }
    if title == Keys.HideCompleted {
      return NonreusableCells.hideCompletedCell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: BaseCell.identifier, for: indexPath)
      cell.textLabel?.text = title
      cell.detailTextLabel?.text = model[Keys.Id]
      cell.accessoryType = Keys.DisclosureKeys.contains(title) ? .disclosureIndicator : .none
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    let model = rowModel(at: indexPath)
    guard let title = model[Keys.Title] else { return }
    
    // Open guide video
    if title == Localized(key: "Video") {
      if let url = Bundle.main.url(forResource: "demo", withExtension: "mp4") {
        let playerVC = AVPlayerViewController()
        playerVC.player = AVPlayer(url: url)
        present(playerVC, animated: true) {
          playerVC.player?.play()
        }
      }
    } else if title == Keys.ReminderList {
      navigationController?.pushViewController(HiddenTypeVC(), animated: true)
    } else if title == Keys.DefaultCalendar {
      navigationController?.pushViewController(DefaultTypeVC(), animated: true)
    } else if title == Keys.FetchingLimitation {
      navigationController?.pushViewController(FetchBoundsVC(), animated: true)
    } else {
      // Open URL
      guard let link = model[Keys.Link] else { return }
      guard let url = URL(string: link) else { return }
      
      // SafariViewController only support HTTP protocol
      if link.hasPrefix("http") {
        let safari = SFSafariViewController(url: url)
        safari.preferredControlTintColor = Specs.color.tint
        present(safari, animated: true)
      } else {
        UIApplication.shared.open(url, options: [:])
      }
    }
  }
  
  func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    return action == #selector(copy(_:))
  }
  
  // MARK: - Copy action
  func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    guard let link = rowModel(at: indexPath)[Keys.Link] else { return }
    UIPasteboard.general.string = link
  }
}
