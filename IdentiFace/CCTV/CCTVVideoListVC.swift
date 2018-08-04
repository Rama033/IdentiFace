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

class CCTVVideoListVC: UITableViewController {
    let url = URL(string: "http://www.ebookfrenzy.com/ios_book/movie/small.mov")


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cctv_video_cell") as? CCTVVideoCell ?? CCTVVideoCell(style: .default, reuseIdentifier: "cctv_video_cell")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        cell.timeLabel.text = timeFormatter.string(from: Date())
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy:MM:dd"
        cell.dayLabel.text = dayFormatter.string(from: Date())
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! AVPlayerViewController
        destination.player = AVPlayer(url: url!)
    }
    
}
