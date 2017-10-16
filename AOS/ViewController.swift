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

    @IBAction func einstellungenButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueEinstellungen", sender: self)
    }
    
    @IBAction func ticketsButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueTickets", sender: self)
    }
    
    @IBAction func projekteButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "segueProjekte", sender: self)
    }
    @IBAction func arbeitsscheineButtonController(_ sender: Any) {
        self.performSegue(withIdentifier: "segueArbeitsscheine", sender: self)
    }
}

