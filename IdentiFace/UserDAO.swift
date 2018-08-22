//
//  UserDAO.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 8..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch(keyword: String? = nil) -> [UserData] {
        var userList = [UserData]()
        
        let fetchRequest: NSFetchRequest<UserMO> = UserMO.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true) ]
        if let key = keyword, key.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@ || memo CONTAINS[c] %@", key, key)
        }
        
        do {
            let resultSet = try self.context.fetch(fetchRequest)
            
            for result in resultSet {
                let data = UserData()
                data.name = result.name
                data.image = UIImage(data: result.image!)
                data.memo = result.memo
                
                data.objectID = result.objectID
                
                userList.append(data)
            }
        } catch let error as NSError {
            NSLog("Fetch Erorr: %s", error)
        }
        
        return userList
        
    }
    
    func insert(_ data: UserData) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "User", into: self.context) as! UserMO
        
        object.name = data.name
        object.image = UIImagePNGRepresentation(data.image)
        object.memo = data.memo
        
        do {
            try self.context.save()
            //네트워크 저장 코드
        } catch let error as NSError {
            self.context.rollback()
            NSLog("Insert Error : %s", error.localizedDescription)
        }
    }
    
    func edit(objectID: NSManagedObjectID, data: UserData) {
        let object = self.context.object(with: objectID)
        
        object.setValue(data.name, forKey: "name")
        object.setValue(data.memo, forKey: "memo")
        
        do {
            try self.context.save()
        } catch let error as NSError {
            self.context.rollback()
            NSLog("Edit Error : %s", error.localizedDescription)
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
