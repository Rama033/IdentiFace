//
//  UserFormVC.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 4..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import UIKit

class UserFormVC: UIViewController, UITextFieldDelegate {
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
    
    var alert: UIAlertController?
    
    var imageIsAdded: Bool = false
    var imageAddingProgress: Bool = false {
        didSet {
            if self.imageAddingProgress == false {
                self.alert?.title = nil
                self.alert?.message = "등록이 완료되었습니다."
                self.alert?.addAction(UIAlertAction(title: "확인", style: .default))

            }
        }
    }
    
    lazy var userDAO = UserDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImage.layer.cornerRadius = (self.userImage.frame.width / 2)
        self.userImage.layer.borderWidth = 0
        self.userImage.layer.masksToBounds = true
        self.navigationItem.rightBarButtonItem?.isEnabled = false

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.imageAddingProgress == true {
            self.alert = UIAlertController(title: "등록이 진행중입니다.", message: "잠시만 기다려주세요...", preferredStyle: .alert)
            self.present(alert!, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if self.userName.text == "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if self.userName.text == "" {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        return true
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if self.userMemo.isEditing {
            let userInfo: NSDictionary = notification.userInfo! as NSDictionary
            let keyboardFrame: NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.view.frame.origin.y = -(keyboardHeight / 4)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func saveUserData(_ sender: Any) {
        let data = UserData()
        
        data.name = self.userName.text
        data.image = self.userImage?.image
        data.memo = self.userMemo.text
        
        self.userDAO.insert(data)
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UserFaceEnrollmentVC {
            destination.userFormVC = self
            destination.name = self.userName.text
        }
    }
}


