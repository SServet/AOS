//
//  addArbeitsscheinVC.swift
//  AOS
//
//  Created by Marko Peric on 11.12.17.
//  Copyright © 2017 SSIT. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import Foundation

class addProjektVC: FormViewController {
    
    let URL_GET_KUNDEN = "http://aos.ssit.at/php/v1/kunden.php"
    let URL_GET_ARTIKEL = "http://aos.ssit.at/php/v1/artikel.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Projekt hinzufügen")
            <<< SearchPushRow<SearchItemModel>("Kunde"){ row in
                row.title = "Kunde"
                Alamofire.request(URL_GET_KUNDEN, method: .get).responseJSON{
                    response in
                    if let result = response.result.value{
                        let jsonData = result as! NSDictionary
                        
                        if(!(jsonData.value(forKey: "error") as! Bool)){
                            
                            let customer = jsonData.value(forKey: "customer") as! NSArray
                            let companyname = customer.value(forKey: "companyname") as! NSArray
                            let kid = customer.value(forKey: "kid") as! NSArray
                            
                            var sarr = [SearchItemModel]()
                            for i in 0..<companyname.count{
                                if companyname[i] is NSString{
                                    var a = kid[i] as! NSString
                                    var b:String = a as String
                                    b += ". " + ((companyname[i] as! NSString) as String)
                                    sarr.append(SearchItemModel.init(Int((kid[i] as! NSString).intValue), b))
                                }
                            }
                            
                            row.options = sarr
                            row.selectorTitle = "Wähle Sie einen Kunden aus"
                        }
                    }
                    
                }
                /*
                 row.options = [SearchItemModel.init(1, "Kunde1"), SearchItemModel.init(2, "Kunde2"), SearchItemModel.init(3, "Kunde3")]
                 row.selectorTitle = "Kunden auswählen"*/
            }
            <<< SearchPushRow<SearchItemModel>("Artikel"){ row in
                row.title = "Artikel"
                Alamofire.request(URL_GET_ARTIKEL, method: .get).responseJSON{
                    response in
                    
                    if let result = response.result.value{
                        let jsonData = result as! NSDictionary
                        
                        if(!(jsonData.value(forKey: "error") as! Bool)){
                            
                            let article = jsonData.value(forKey: "articles") as! NSArray
                            
                            let articlename = article.value(forKey: "articlename") as! NSArray
                            let artid = article.value(forKey: "artid") as! NSArray
                            
                            var sarr = [SearchItemModel]()
                            for i in 0..<articlename.count{
                                if articlename[i] is NSString{
                                    var a = artid[i] as! NSString
                                    var b:String = a as String
                                    b += ". " + ((articlename[i] as! NSString) as String)
                                    sarr.append(SearchItemModel.init(Int((artid[i] as! NSString).intValue), b))
                                }
                            }
                            
                            row.options = sarr
                            row.selectorTitle = "Wählen Sie ein Artikel aus"
                        }
                    }
                    
                }
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
