//
//  UserListViewController.swift
//  ForgetMeNot
//
//  Created by Seth on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController {

    var firebase: FirebaseManager? 
    let cellID: String = "UserListCell"
    var users: [User] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let firebase = firebase {
            firebase.getUsers(completion: { [weak self] (userArr) in
                DispatchQueue.main.async {
                    self?.updateUsers(list: userArr)
                }
            })
        }
    }

    func updateUsers(list: [User]) {
        users.removeAll()
        users.append(contentsOf: list)
        tableView.reloadData()
    }
    
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserListTableViewCell
        
        cell.configure(with: users[indexPath.row])
        
        return cell
    }
}
