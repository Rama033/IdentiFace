//
//  CCTVVideoListVC.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 4..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class CCTVVideoListVC: UITableViewController, UISearchBarDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var cctvDAO = CCTVDAO()

    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.resyncData), name: NSNotification.Name(rawValue: "resyncData"), object: nil)
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.tableView.allowsSelectionDuringEditing = true
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.refreshControl?.addTarget(self, action: #selector(resyncData), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.reloadTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver("resyncData")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.cctvList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cctv_video_cell") as? CCTVListCell ?? CCTVListCell(style: .default, reuseIdentifier: "cctv_video_cell")
        
        cell.dayLabel.text = appDelegate.cctvList[indexPath.row].dayInfo
        cell.timeLabel.text = appDelegate.cctvList[indexPath.row].timeInfo
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let objectID = self.appDelegate.cctvList[indexPath.row].objectID {
            if self.cctvDAO.delete(objectID) {
                self.appDelegate.cctvList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AVPlayerViewController,
            let selectedIndex = self.tableView.indexPathForSelectedRow?.row {
            destination.player = AVPlayer(url: URL(string: self.appDelegate.cctvList[selectedIndex].urlInfo!)! )
            
            let navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width/4, height: 60) )
            navTitle.numberOfLines = 2
            navTitle.textAlignment = .left
            navTitle.font = UIFont.systemFont(ofSize: 14)
            navTitle.text = "날짜: \(self.appDelegate.cctvList[selectedIndex].dayInfo!) \n시간: \(self.appDelegate.cctvList[selectedIndex].timeInfo!)"
            
            destination.navigationItem.titleView = navTitle
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = self.searchBar.text
        self.appDelegate.cctvList = self.cctvDAO.fetch(keyword: keyword)
        self.view.endEditing(true)
        self.tableView.reloadData()
    }
    
    @objc func reloadTable() {
        self.appDelegate.cctvList = self.cctvDAO.fetch()
        self.tableView.reloadData()
    }
    
    @objc func resyncData(_ sender: Any? = nil) {
        let sync = DataSync()
        sync.downloadData(reloadTarget: self)
        self.refreshControl?.endRefreshing()
    }
    
}
