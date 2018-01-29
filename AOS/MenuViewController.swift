//
//  Menu.swift
//  AOS
//
//  Created by SSIT on 15.01.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

