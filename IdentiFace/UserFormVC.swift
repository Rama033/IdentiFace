//
//  UserFormVC.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 4..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import UIKit

class UserFormVC: UIViewController, UIImagePickerControllerDelegate,
                    UINavigationControllerDelegate, UITextFieldDelegate {
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
    
    var imageIsAdded: Bool = false
    
    lazy var userDAO = UserDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userImage.layer.cornerRadius = (self.userImage.frame.width / 2)
        self.userImage.layer.borderWidth = 0
        self.userImage.layer.masksToBounds = true
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

    @IBAction func addUserImage(_ sender: Any) {
        self.presentPicker(source: .camera)
    }
    
    
    func presentPicker(source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        self.present(picker, animated: false)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.userImage.image = info[UIImagePickerControllerEditedImage] as? UIImage

        self.imageIsAdded = true
        picker.dismiss(animated: false)
    }
    
    @IBAction func saveUserData(_ sender: Any) {
        let data = UserData()
        
        if self.userName.text == "" || self.imageIsAdded == false {
            let alert = UIAlertController(title: nil, message: "이름과 사진은 필수사항 입니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) )
            self.present(alert, animated: true)
            return
        }
        
        data.name = self.userName.text
        data.image = self.userImage?.image
        data.memo = self.userMemo.text
        
        self.userDAO.insert(data)
        
        _ = self.navigationController?.popViewController(animated: true)
    }

}


