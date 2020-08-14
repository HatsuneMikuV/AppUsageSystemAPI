//
//  ViewController.swift
//  AppUsageSystemAPI
//
//  Created by AngleMiku on 2020/8/14.
//  Copyright © 2020 AngleMiku. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  private var dataArray = ["iTunes Music"]
  private let cellIdentifier = "folderCell"
  
  
  //MARK: pragma mark ==============Life Cycle==========
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    // Do any additional setup after loading the view.
    
    setSubviews()
    layout()
  }
  
  
  //MARK: pragma mark ==============Set Subviews========
  
  private func setSubviews() {
    
    view.addSubview(tableView)
  }
  
  
  //MARK: pragma mark ==============Layout==============
  
  private func layout() {
    tableView.frame = view.bounds
  }
  
  
  //MARK: pragma mark ==============Public==============

  //MARK: pragma mark ==============UI-Lazy=============
  private lazy var tableView: UITableView = {
    let tableView = UITableView.init(frame: view.bounds)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    return tableView
  }()
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    if indexPath.row < dataArray.count {
      cell.textLabel?.text = dataArray[indexPath.row]
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row < dataArray.count {
      goto(index: indexPath.row)
    }
  }
  
  func goto(index:Int) {
    if index == 0 {
      navigationController?.pushViewController(AppiTunesMusicViewController(), animated: true)
    }
  }
}
