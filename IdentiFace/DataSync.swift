//
//  DataSync.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 18..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class DataSync {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func serverURL(_ path: String) -> String {
        return "http://49.236.136.50/api/" + path + ".php"
    }
    
    func downloadData(reloadTarget tableViewController: UITableViewController) {
        let url = self.serverURL("read")
        let get = Alamofire.request(url, method: .post, encoding: JSONEncoding.default)
        
        get.responseJSON { res in
            guard let jsonObject = res.result.value as? NSDictionary else { return }
            guard let records = jsonObject["records"] as? NSArray else { return }
            
            for record in records {
                guard let item = record as? NSDictionary else { return }
                
                let object = NSEntityDescription.insertNewObject(forEntityName: "CCTV", into: self.context) as! CCTVMO
                
                let date = (item["push_date"] as! String)
                let splitedDate = date.components(separatedBy: " ")
                object.day = splitedDate[0]
                object.time = splitedDate[1]
                object.url = (item["video_url"] as! String)
                
                do {
                    try self.context.save()
                    let url = self.serverURL("datasync")
                    Alamofire.request(url)
                    (tableViewController as? CCTVVideoListVC)?.reloadTable()
                } catch let error as NSError {
                    self.context.rollback()
                    NSLog("An error has occurred : %s", error.localizedDescription)
                }
            }
        }
    }
}
