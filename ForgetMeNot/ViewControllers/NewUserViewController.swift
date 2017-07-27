//
//  NewUserViewController.swift
//  ForgetMeNot
//
//  Created by Seth on 7/27/17.
//  Copyright © 2017 Ray Wenderlich. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var btn_save: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func actionSave(_ sender: Any) {
        guard let name = nameLabel.text, name.isEmpty == false else {
            return
        }
        
        // hide keyboard
        tf_name.resignFirstResponder()
        
        // save username to user defaults
        UserDefaults.standard.setValue(name, forKey: "com.bt.name")
        
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
