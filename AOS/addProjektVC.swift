//
//  addArbeitsscheinVC.swift
//  AOS
//
//  Created by Marko Peric on 11.12.17.
//  Copyright © 2017 SSIT. All rights reserved.
//

import UIKit
import Eureka
import Foundation

class addProjektVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Projekt hinzufügen")
            <<< SearchPushRow<SearchItemModel>("Kunde"){
                $0.title = "Kunde"
                $0.options = [SearchItemModel.init(1, "Kunde1"), SearchItemModel.init(2, "Kunde2"), SearchItemModel.init(3, "Kunde3")]
                $0.selectorTitle = "Kunden auswählen"
            }
            <<< SearchPushRow<SearchItemModel>("Artikel"){
                $0.title = "Artikel"
                $0.options = [SearchItemModel.init(1, "Artikel1"), SearchItemModel.init(2, "Artikel2"), SearchItemModel.init(3, "Artikel3")]
                $0.selectorTitle = "Artikel auswählen"
            }
            <<< IntRow() {
                $0.title = "Artikelanzahl"
                $0.value = 1
            }
            <<< TextRow() {
                $0.title = "Bezeichnung"
            }
            <<< TextRow() {
                $0.title = "Beschreibung"
            }
            <<< PushRow<String>(){
                $0.title = "Projektart"
                $0.options = ["Pauschal", "Aufwand"]
                $0.selectorTitle = "Wähle eine Projektart"
            }
            <<< IntRow() {
                $0.title = "Projektvolumen in Euro"
                $0.value = 1
            }
            <<< DateRow(){
                $0.title = "Bestelldatum"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< DateRow(){
                $0.title = "Abgeschlossen Am"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
            <<< DateRow(){
                $0.title = "Abgerechnet Am"
                $0.value = Date(timeIntervalSinceReferenceDate: 0)
            }
        }
}
