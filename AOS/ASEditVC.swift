//
//  ASEditVC.swift
//  AOS
//
//  Created by SSIT on 02.08.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import Foundation


class ASEditVC: FormViewController, ASIDDelegate{

    var asid = 0
    var _as = [String]()
    var delegate: ASIDDelegate?
    
    let URL_GET_KUNDEN = "http://aos.ssit.at/php/v1/kunden.php"
    let URL_GET_TTYP = "http://aos.ssit.at/php/v1/ttyp.php"
    let URL_GET_TART = "http://aos.ssit.at/php/v1/tart.php"
    let URL_GET_ARTIKEL = "http://aos.ssit.at/php/v1/artikel.php"
    
    var asClose = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Arbeitsschein bearbeiten")
            <<< SwitchRow("AS abschliessen"){row in
                row.title = "Arbeitsschein abschließen"
                row.value = false
                }.onChange{row in
                    if(row.value == true){
                        self.asClose = true
                    }else{
                        self.asClose = false
                    }
            }
        
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
                            var skundearr = [SearchItemModel]()
                            let k = self._as[0].split(separator: ";")
                            skundearr.append(SearchItemModel.init(0, String(k[1])))
                            row.value = skundearr[0]
                            row.reload()
                        }
                    }
                }
            }
            
            <<< SearchPushRow<SearchItemModel>("Artikel"){row in
                row.title = "Artikel hinzufügen"
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
            
            <<< PushRow<String>("Artikeleinheit"){row in
                row.title = "Artikeleinheit auswählen"
                row.options = ["Stk.", "Std."]
                row.value = "Stk."
            }
            
            <<< IntRow("ArtAnz") {
                $0.title = "Artikelanzahl hinzufügen"
                $0.value = 1
            }
        
            <<< MultipleSelectorRow<String>("Vordefinierte Beschreibung"){
                $0.title = "Vordefinierte Beschreibung"
                $0.options = ["Protokolle OK", "Sicherung OK", "Update OK"]
            }
            
            <<< TextRow("Beschreibung") {
                $0.title = "Beschreibung"
                $0.value = String(_as[0].split(separator: ";")[0])
            }
            
            <<< PushRow<String>("Termintyp"){ row in
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
                            let k = self._as[0].split(separator: ";")
                            row.value = String(k[2])
                            row.reload()
                        }
                    }
                }
            }
        
            <<< PushRow<String>("Tätigkeit"){ row in
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
                            let k = self._as[0].split(separator: ";")
                            row.value = String(k[3])
                            row.reload()
                        }
                    }
                }
            }
        
            <<< DateRow("Datum von"){
                $0.title = "Datum von"
                let k = self._as[0].split(separator: ";")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
                let date = dateFormatter.date(from: String(k[4]))
                $0.value = date
                $0.reload()
            }
            <<< DateRow("Datum bis"){
                $0.title = "Datum bis"
                let k = self._as[0].split(separator: ";")
                $0.reload()
                if(k[5] == "0000-00-00"){
                    let date = Date()
                    $0.value = Calendar.current.startOfDay(for: date)
                }else{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
                    let date = dateFormatter.date(from: String(k[5]))
                    $0.value = date
                    $0.reload()
                }
            }
            <<< TimeRow("Zeit von"){
                $0.title = "Uhrzeit von"
                let k = self._as[0].split(separator: ";")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH':'mm':'ss'"
                let date = dateFormatter.date(from: String(k[6]))
                $0.value = date
                $0.reload()
            }
            <<< TimeRow("Zeit bis"){
                $0.title = "Uhrzeit bis"
                let k = self._as[0].split(separator: ";")
                if(k[7] == "00:00:00"){
                    let date = Date()
                    $0.value = date
                }else{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH':'mm':'ss'"
                    let date = dateFormatter.date(from: String(k[7]))
                    $0.value = date
                    $0.reload()
                }
            }
            <<< TextRow("Kulanzgrund") { row in
                row.title = "Kulanzgrund"
                let k = self._as[0].split(separator: ";")
                if(k[9] != "Keine Kulanzzeit"){
                    row.value = String(k[9])
                }
            }
            <<< IntRow("Kulanzzeit") { row in
                row.title = "Kulanzzeit"
                let k = self._as[0].split(separator: ";")
                if(k[8] == "0.00"){
                    row.value = 0
                }else{
                    row.value = Int(k[8])
                }
        }
        
    }
    
    func setASID(_id: Int, as_: [String]){
        asid = _id
        _as = as_
    }
}
