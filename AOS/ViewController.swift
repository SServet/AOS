//
//  ViewController.swift
//  AOS
//
//  Created by SSIT on 16.10.17.
//  Copyright © 2017 SSIT. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {
    
    let URL_USER_LOGIN = "http://aos.ssit.at/php/v1/login.php"
    
    let defaultValues = UserDefaults.standard
    
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let LoginRequest: Parameters=[
            "email":Login_Mail_Input.text!,
            "password":Login_PW_Input.text!
        ]
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: LoginRequest).responseJSON{
            response in
            if let result = response.result.value{
                
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    
                    //getting the user from response
                    let user = jsonData.value(forKey: "user") as! NSDictionary
                    
                    //getting user values
                    let userId = user.value(forKey: "id") as! String
                    let userEmail = user.value(forKey: "email") as! String
                    
                    //saving user values to defaults
                    self.defaultValues.set(userId, forKey: "userid")
                    self.defaultValues.set(userEmail, forKey: "useremail")
                    self.defaultValues.synchronize()
                    //switching the screen
                    let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
                    self.navigationController?.pushViewController(menuViewController, animated: true)
                    self.dismiss(animated: false, completion: nil)
                    print(self.getDocumentsDirectory())
                }else{
                    let alert = UIAlertController(title: "Warnung!", message: "Falsche E-Mail bzw. Passwort!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if roundedCornerButton != nil{
            roundedCornerButton.layer.cornerRadius = 10
        }
        
        Login_PW_Input.text = ""
        Login_Mail_Input.text = ""
        
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        if defaultValues.string(forKey: "email") != nil{
            let menuViewController = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            self.navigationController?.pushViewController(menuViewController, animated: true)
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
