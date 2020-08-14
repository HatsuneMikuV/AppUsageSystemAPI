//
//  AppiTunesMusicViewController.swift
//  AppUsageSystemAPI
//
//  Created by AngleMiku on 2020/8/15.
//  Copyright © 2020 AngleMiku. All rights reserved.
//

import UIKit
import MediaPlayer

class AppiTunesMusicViewController: UIViewController {
  
  var dataArray:[[String:Any]] = []
  private let cellIdentifier = "folderCell"
  
  private var player : AVPlayer?
  
  //MARK: pragma mark ==============Life Cycle==========
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    requestAuthorizationForMediaLibrary()
  }
  
  //MARK: pragma mark ==============Private=============
  private func requestAuthorizationForMediaLibrary() {
    let authStatus = MPMediaLibrary.authorizationStatus()
    if authStatus == .denied {
      let infoDictionary = Bundle.main.infoDictionary
      let appName = infoDictionary?["CFBundleDisplayName"] ?? "APP"
      let message = "Allow \(appName) to access your media database?"
      
      let alertController = UIAlertController.init(title: "Warning", message: message, preferredStyle: .alert)
      let okAction = UIAlertAction.init(title: "OK", style: .default) { [weak self] (_) in
        guard let weakSelf = self else { return }
        weakSelf.navigationController?.popViewController(animated: true)
      }
      let setAction = UIAlertAction.init(title: "Setting", style: .default) { [weak self] (_) in
        guard let weakSelf = self else { return }
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
          weakSelf.navigationController?.popViewController(animated: true)
        }
      }
      alertController.addAction(okAction)
      alertController.addAction(setAction)
      present(alertController, animated: true, completion: nil)
    } else if authStatus == .notDetermined || authStatus == .restricted {
      MPMediaLibrary.requestAuthorization { [weak self] (authStatus) in
        guard let weakSelf = self else { return }
        if authStatus == .authorized {
          weakSelf.getItunesMusic()
        } else {
          weakSelf.navigationController?.popViewController(animated: true)
        }
      }
    } else if authStatus == .authorized {
      getItunesMusic()
    }
  }
  
  private func getItunesMusic() {
    
    let query = MPMediaQuery()
    let albumNamePredicate = MPMediaPropertyPredicate(value: NSNumber(integerLiteral: 1 << 0), forProperty: MPMediaItemPropertyMediaType)
    query.addFilterPredicate(albumNamePredicate)
    if let itemsFromGenericQuery = query.items, itemsFromGenericQuery.count > 0 {
      for music in itemsFromGenericQuery {
        resolverMediaItem(music: music)
      }
      tableView.reloadData()
    }
  }
  
  private func resolverMediaItem(music:MPMediaItem) {
    var musicDict:[String:Any] = [:]
    if let name = music.title {
      musicDict["title"] = name
    }
    if let fileURL = music.assetURL {
      musicDict["url"] = fileURL
    }
    if let singer = music.artist {
      musicDict["singer"] = singer
    } else {
      musicDict["singer"] = "unknow"
    }
    musicDict["playbackDuration"] = music.playbackDuration
    if let artwork = music.artwork {
      musicDict["artwork"] = artwork.image(at: CGSize(width: 120, height: 120))
    }
    debugPrint("======\(musicDict)")
    dataArray.append(musicDict)
  }
  //MARK: pragma mark ==============Public==============
  //MARK: pragma mark ==============Actions=============
  //MARK: pragma mark ==============UI-Lazy=============
  private lazy var tableView: UITableView = {
    let tableView = UITableView.init(frame: view.bounds)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    return tableView
  }()
  
}

extension AppiTunesMusicViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    if indexPath.row < dataArray.count {
      if let title = dataArray[indexPath.row]["title"] as? String {
        cell.textLabel?.text = title
      }
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row < dataArray.count {
      if let url = dataArray[indexPath.row]["url"] as? URL {
        if let player = self.player {
          player.pause()
        }
        self.player = AVPlayer.init(url: url)
        self.player?.play()
      }
    }
  }
}

/// Export MPMediaItem to temporary file.
///
/// - Parameters:
///   - assetURL: The `assetURL` of the `MPMediaItem`.
///   - completionHandler: Closure to be called when the export is done. The parameters are a boolean `success`, the `URL` of the temporary file, and an optional `Error` if there was any problem. The parameters of the closure are:
///
///   - fileURL: The `URL` of the temporary file created for the exported results.
///   - error: The `Error`, if any, of the asynchronous export process.

func export(_ assetURL: URL, completionHandler: @escaping (_ fileURL: URL?, _ error: Error?) -> ()) {
  let asset = AVURLAsset(url: assetURL)
  guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
    completionHandler(nil, ExportError.unableToCreateExporter)
    return
  }
  
  let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent(NSUUID().uuidString)
    .appendingPathExtension("m4a")
  
  exporter.outputURL = fileURL
  exporter.outputFileType = AVFileType.m4a
  
  exporter.exportAsynchronously {
    if exporter.status == .completed {
      completionHandler(fileURL, nil)
    } else {
      completionHandler(nil, exporter.error)
    }
  }
}
enum ExportError: Error {
  case unableToCreateExporter
}
