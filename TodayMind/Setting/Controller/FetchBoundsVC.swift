//
//  FetchBoundsVC.swift
//  TodayMind
//
//  Created by cyan on 2017/2/23.
//  Copyright © 2017 cyan. All rights reserved.
//

import UIKit
import TMKit

fileprivate let cellIdentifier = "LimitationCell"

class FetchBoundsVC: BaseVC {
  
  fileprivate var data: [String] = []
  fileprivate var limit = Prefs.limit()
  
  private struct Bounds {
    static let min = 1
    static let max = 7
  }
  
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.register(BaseCell.self, forCellReuseIdentifier: cellIdentifier)
    return tableView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = Localized(key: "Fetching limitation")
    
    for count in Bounds.min...Bounds.max {
      data.append(title(with: count))
    }
    
    tableView.delegate = self
    tableView.dataSource = self
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(view)
    }
  }
  
  private func title(with count: Int) -> String {
    if count == 1 {
      return Localized(key: "1 Day")
    } else {
      return String(format: Localized(key: "%d Days"), count)
    }
  }
}

// MARK: TableView
extension FetchBoundsVC: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func limit(with indexPath: IndexPath) -> Int {
    return indexPath.row + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    cell.textLabel?.text = data[indexPath.row]
    cell.accessoryType = limit(with: indexPath) == limit ? .checkmark : .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    limit = limit(with: indexPath)
    Prefs.set(limit: limit)
    tableView.reloadData()
  }
}
