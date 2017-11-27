//
//  ViewController.swift
//  AOS
//
//  Created by SSIT on 16.10.17.
//  Copyright © 2017 SSIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var Login_Mail_Input: UITextField!
    @IBOutlet weak var Login_PW_Input: UITextField!
    @IBOutlet weak var roundedCornerButton: UIButton!
    
    /*
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /*
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if roundedCornerButton != nil{
            roundedCornerButton.layer.cornerRadius = 10
        }
        navigationItem.hidesBackButton = true
    }
    
    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    */
    
    @IBAction func segueLoginButton(_ sender: Any) {
        if(Login_PW_Input.text != "" && Login_Mail_Input.text != ""){
            self.performSegue(withIdentifier: "segueLoginClick", sender: self)
        }
    }
    
}

