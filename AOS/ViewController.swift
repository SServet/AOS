//
//  ViewController.swift
//  AOS
//
//  Created by SSIT on 16.10.17.
//  Copyright © 2017 SSIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func segueEinstellungenButton(sender: UIButton) {
        self.performSegue(withIdentifier: "segueTEinstellungenButton", sender: self)
    }
    
    @IBAction func segueTicketsButton(sender: UIButton) {
        self.performSegue(withIdentifier: "segueTicketsButton", sender: self)
    }
    @IBAction func segueProjekteButton(sender: UIButton) {
        self.performSegue(withIdentifier: "segueProjekteButton", sender: self)
        
    }
    @IBAction func segueArbeitsscheineButton(sender: UIButton) {
        self.performSegue(withIdentifier: "segueArbeitsscheineButton", sender: self)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // set title for Einstellungen screen
        
        if segue.identifier == "segueEinstellungen" {
            
            
        }
    }*/
    
}

