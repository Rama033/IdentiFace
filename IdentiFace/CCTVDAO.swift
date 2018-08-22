//
//  CctvDAO.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 9..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CCTVDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch(keyword: String? = nil) -> [CCTVData] {
        var cctvList = [CCTVData]()
        
        let fetchRequest: NSFetchRequest<CCTVMO> = CCTVMO.fetchRequest()
        let sortDate = NSSortDescriptor(key: "day", ascending: false)
        let sortTime = NSSortDescriptor(key: "time", ascending: false)
        fetchRequest.sortDescriptors = [sortDate, sortTime]
        if let key = keyword, key.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "day CONTAINS[c] %@", key)
        }
        
        do {
            let resultSet = try self.context.fetch(fetchRequest)
            
            for result in resultSet {
                let data = CCTVData()
                data.dayInfo = result.day
                data.timeInfo = result.time
                data.urlInfo = result.url
                
                data.objectID = result.objectID
                
                cctvList.append(data)
            }
        } catch let error as NSError {
            NSLog("Fetch Error : %s", error.localizedDescription)
        }
        
        return cctvList
    }
    
    func insert(_ data: CCTVData) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "CCTV", into: self.context) as! CCTVMO
        
        object.day = data.dayInfo
        object.time = data.timeInfo
        object.url = data.urlInfo
        
        do {
            try self.context.save()
        } catch let error as NSError {
            self.context.rollback()
            NSLog("Insert Error : %s", error.localizedDescription)
        }
    }
    
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        let object = self.context.object(with: objectID)
        
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        } catch let error as NSError {
            self.context.rollback()
            NSLog("Delete Error : %s", error.localizedDescription)
            return false
        }
    }
}
