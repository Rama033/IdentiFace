//
//  UserInfoVC.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 4..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import UIKit

class UserInfoVC: UIViewController, UITextFieldDelegate {
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UITextField! {
        didSet {
            self.userName.delegate = self
        }
    }
    @IBOutlet var userMemo: UITextField! {
        didSet {
            self.userMemo.delegate = self
        }
    }
    
    var index: Int!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var userDAO = UserDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userImage.image = self.appDelegate.userList[index].image
        self.userImage.layer.cornerRadius = (self.userImage.frame.width / 2)
        self.userImage.layer.borderWidth = 0
        self.userImage.layer.masksToBounds = true
        self.userName.text = self.appDelegate.userList[index].name
        self.userMemo.text = self.appDelegate.userList[index].memo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveChangedData(_ sender: Any) {
        let data = self.appDelegate.userList[index]
        
        let newData = UserData()
        newData.name = self.userName.text
        newData.memo = self.userMemo.text
        
        userDAO.edit(objectID: data.objectID!, data: newData)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
}
