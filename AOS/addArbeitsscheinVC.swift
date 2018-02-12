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
        return title.lowercased().contains(query.lowercased())
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
    
    let URL_GET_KUNDEN = "http://aos.ssit.at/php/v1/kunden.php"
    let URL_GET_ARTIKEL = "http://aos.ssit.at/php/v1/artikel.php"
    let URL_GET_TTYP = "http://aos.ssit.at/php/v1/ttyp.php"
    let URL_GET_TART = "http://aos.ssit.at/php/v1/tart.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Arbeitsschein hinzufügen")
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
                $0.title = "Beschreibung"
            }
            <<< PushRow<String>(){ row in
                row.title = "Termintyp"
                Alamofire.request(URL_GET_TTYP, method: .get).responseJSON{
                    response in
                    
                    if let result = response.result.value{
                        let jsonData = result as! NSDictionary
                        
                        if(!(jsonData.value(forKey: "error") as! Bool)){
                            
                            let ttyp = jsonData.value(forKey: "ttyp") as! NSArray
                            
                            let termintyp = ttyp.value(forKey: "description") as! NSArray
                            let ttid = ttyp.value(forKey: "ttid") as! NSArray
                            
                            let termintypen = ttyp.mutableCopy() as! NSMutableArray
                            
                            for i in 0..<termintyp.count{
                                if termintyp[i] is NSString{
                                    var a = ((ttid[i] as! NSString) as String) + ". " + ((termintyp[i] as! NSString) as String) as String
                                    termintypen.replaceObject(at: i, with: a)
                                }
                            }
                            
                            row.options = termintypen.flatMap({ $0 as? String })
                            row.selectorTitle = "Wähle Sie einen Termintyp aus"
                        }
                    }
                    
                }
            }
            <<< PushRow<String>(){ row in
                row.title = "Tätigkeit"
                Alamofire.request(URL_GET_TART, method: .get).responseJSON{
                    response in
                    
                    if let result = response.result.value{
                        let jsonData = result as! NSDictionary
                        
                        if(!(jsonData.value(forKey: "error") as! Bool)){
                            
                            let tart = jsonData.value(forKey: "tart") as! NSArray
                            
                            
                            let taetigkeit = tart.value(forKey: "description") as! NSArray
                            let tkid = tart.value(forKey: "tkid") as! NSArray
                            
                            let taetigkeiten = taetigkeit.mutableCopy() as! NSMutableArray
                            
                            for i in 0..<taetigkeit.count{
                                if taetigkeit[i] is NSString{
                                    var a = ((tkid[i] as! NSString) as String) + ". " + ((taetigkeit[i] as! NSString) as String) as String
                                    taetigkeiten.replaceObject(at: i, with: a)
                                }
                            }
                            
                            row.options = taetigkeiten.flatMap({ $0 as? String })
                            row.selectorTitle = "Wählen Sie eine Tätigkeit aus"
                        }
                    }
                    
                }
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
