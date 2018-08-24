//
//  DataSync.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 18..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
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
    
    func uploadData(_ image: UIImage?, name: String) {
        let url = self.serverURL("upload")
        guard let img = image else { return }
        print(img)
        
        let imgData = UIImagePNGRepresentation(img)?.base64EncodedString()
        let param: Parameters = ["name" : name,
                                "image" : imgData!]
        let call = Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        call.responseJSON
    }
    
    func checkStart() {
        let url = self.serverURL("check")
        Alamofire.request(url)
    }
    
    func getImage(vc: UserFormVC) {
        let url = self.serverURL("get")
        let param: Parameters = ["name" : vc.userName.text!]
        let get = Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        DispatchQueue.main.async {
            get.responseJSON { res in
                guard let jsonObject = res.result.value as? NSDictionary else { return }
                guard let encoded_img = jsonObject["image"] as? String else { return }
                guard let img = Data(base64Encoded: encoded_img) else { return }
                
                vc.userImage.image = UIImage(data: img)
                vc.imageIsAdded = true
                vc.imageAddingProgress = false
            }
        }
    }
    
    func deleteImage(name: String) {
        let url = self.serverURL("delete")
        let param: Parameters = ["name" : name]
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
    }
}
