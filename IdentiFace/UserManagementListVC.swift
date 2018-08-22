//
//  UserManagementListVC.swift
//  IdentiFace
//
//  Created by CE-MAC-23 on 2018. 8. 4..
//  Copyright © 2018년 CE-MAC-23. All rights reserved.
//

import UIKit

class UserManagementListVC: UITableViewController, UISearchBarDelegate {
    @IBOutlet var searchBar: UISearchBar!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var userDAO = UserDAO()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        self.tableView.allowsSelectionDuringEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.appDelegate.userList = self.userDAO.fetch()
        self.tableView.reloadData()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.userList.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "user_cell") as? UserListCell ?? UserListCell()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        cell.userImage.image = appDelegate?.userList[indexPath.row].image
        cell.userImage.layer.cornerRadius = (cell.userImage.frame.width / 2)
        cell.userImage.layer.borderWidth = 0
        cell.userImage.layer.masksToBounds = true
        cell.userName.text = appDelegate?.userList[indexPath.row].name
        cell.userMemo.text = appDelegate?.userList[indexPath.row].memo
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let objectID = self.appDelegate.userList[indexPath.row].objectID {
            if self.userDAO.delete(objectID) {
                self.appDelegate.userList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UserInfoVC,
            let selectedIndex = self.tableView.indexPathForSelectedRow?.row {
            destination.index = selectedIndex
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text
        
        self.appDelegate.userList = self.userDAO.fetch(keyword: keyword)
        self.view.endEditing(true)
        self.tableView.reloadData()
    }
}
