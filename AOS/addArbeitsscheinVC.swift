//
//  addArbeitsscheinVC.swift
//  AOS
//
//  Created by Marko Peric on 11.12.17.
//  Copyright © 2017 SSIT. All rights reserved.
//

import UIKit
import Eureka

class addArbeitsscheinVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Arbeitsschein hinzufügen")
            <<< PushRow<String>(){
                $0.title = "Kunde"
                $0.options = ["Kunde1", "Kunde2"]
                $0.selectorTitle = "Wähle einen Kunden"
            }
            <<< PushRow<String>(){
                $0.title = "Artikel"
                $0.options = ["Artikel1", "Artikel2"]
                $0.selectorTitle = "Wähle einen Artikel"
            }
            <<< IntRow() {
                $0.title = "Artikelanzahl"
                $0.value = 1
            }
            <<< TextRow() {
                $0.title = "Beschreibung"
            }
            <<< PushRow<String>(){
                $0.title = "Termintyp"
                $0.options = ["Update", "Installation"]
                $0.selectorTitle = "Wähle einen Termintypen"
            }
            <<< PushRow<String>(){
                $0.title = "Tätigkeit"
                $0.options = ["Vor Ort", "Fernwartung"]
                $0.selectorTitle = "Wähle eine Tätigkeit"
            }
            <<< DateRow(){
                $0.title = "Datum von"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< DateRow(){
                $0.title = "Datum bis"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< CountDownInlineRow(){
                $0.title = "Uhrzeit von"
                var dateComp = DateComponents()
                dateComp.hour = 0
                dateComp.minute = 0
                dateComp.timeZone = TimeZone.current
                $0.value = Calendar.current.date(from: dateComp)
            }
            <<< CountDownInlineRow(){
                $0.title = "Uhrzeit bis"
                var dateComp = DateComponents()
                dateComp.hour = 00
                dateComp.minute = 00
                dateComp.timeZone = TimeZone.current
                $0.value = Calendar.current.date(from: dateComp)
            }
            <<< TextRow() {
                $0.title = "Kulanzgrund"
            }
            <<< IntRow() {
                $0.title = "Kulanzzeit"
            }
            <<< IntRow() {
                $0.title = "Artikelanzahl"
        }
        }
}
