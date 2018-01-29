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

struct SearchItemModel {
    let id: Int
    let title: String
    
    init(_ id:Int,_ title:String) {
        self.id = id
        self.title = title
    }
}
extension SearchItemModel: SearchItem {
    func matchesSearchQuery(_ query: String) -> Bool {
        return title.contains(query)
    }
}
extension SearchItemModel: Equatable {
    static func == (lhs: SearchItemModel, rhs: SearchItemModel) -> Bool {
        return lhs.id == rhs.id
    }
}
extension SearchItemModel: CustomStringConvertible {
    var description: String {
        return title
    }
}

class addArbeitsscheinVC: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Arbeitsschein hinzufügen")
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
            <<< TimeRow(){
                $0.title = "Uhrzeit von"
                var dateComp = DateComponents()
                dateComp.hour = 0
                dateComp.minute = 0
                dateComp.timeZone = TimeZone.current
                $0.value = Calendar.current.date(from: dateComp)
            }
            <<< TimeRow(){
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
