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
    let URL_POST_AS = "http://aos.ssit.at/php/v1/asInsert.php"
    
    
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
            
            <<< MultipleSelectorRow<String>(){
                $0.title = "Vordefinierte Beschreibung"
                $0.options = ["Protokolle OK", "Sicherung OK", "Update OK"]
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
            <<< ButtonRow("Senden"){
                $0.title = "Senden"
                $0.onCellSelection(self.buttontapped)
        }
        }
    func buttontapped(cell: ButtonCellOf<String>, row: ButtonRow){
        let kid = getID(_tag: "Kunde")
        let aid = getID(_tag: "Artikel")
        let ttid = getID(_tag: "Termintyp")
        let tid  = getID(_tag: "Taetigkeit")
        let descr = getString(_tag: "Beschreibung")
        let dfrom = getDate(_tag: String(describing: form.rowBy(tag: "Datum von")?.baseValue))
        let kgrund = getString(_tag: "Kulanzgrund")
        let kzeit = getString(_tag: "Kulanzzeit")
        let defaultval = UserDefaults.standard
        
        print(dfrom)
        
        if let mid = defaultval.string(forKey: "userid"){
            print(mid)
        }
        
        if(checkID(id1: kid, id2: ttid, id3: tid) && descr != ""){
            popup(title_: "Success", message_: "Arbeittschein angelegt!")
        }else{
            popup(title_: "Warnung", message_: "Es wurde keine Beschreibung geschrieben!")
        }
        
    }
    
    func getID(_tag: String) -> Int{
        let id: BaseRow? = form.rowBy(tag: _tag)
        let val = id?.baseValue
        if(val  != nil){
            let a = String(describing: val)
            let b = a.components(separatedBy: "(")
            let c = b[1].components(separatedBy: ".")
            return Int(c[0]) as! Int
        }
        return -1;
    }
    
    func getDate(_tag: String)->Date{
        let a = _tag.components(separatedBy: "(")
        print(a)
        if a.contains("nil") == false{
            let b = a[1].components(separatedBy: " ")
            let df = DateFormatter()
            let date = df.date(from: b[0])
            print(date)
            if(date != nil){
                return date!
            }
        }
        return Date(timeIntervalSinceNow: 0)
    }
    
    func getString(_tag: String) -> String{
        let row: TextRow? = form.rowBy(tag: _tag)
        if(row?.value != nil){
            return (row?.value) as! String
        }
        return ""
    }
    
    func checkID(id1: Int, id2: Int, id3: Int) -> Bool{
        if(id1 == -1){
            popup(title_: "Warnung", message_: "Es wurde kein Kunde ausgewählt!")
            return false
        }else if(id2 == -1){
            popup(title_: "Warnung", message_: "Es wurde kein Termintyp ausgewählt!")
            return false
        }else if(id3 == -1){
            popup(title_: "Warnung", message_: "Es wurde keine Tätigkeitsart ausgewählt!")
            return false
        }
        return true
    }
    
    func popup(title_: String, message_: String){
        let alert = UIAlertController(title: title_ , message: message_, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addAS(mid: Int, kid: Int, aid: Int, ttid: Int, tid: Int, descr: String, dfrom: Date, kgrund: String, kzeit: Int){
        let AS: Parameters=[
            "mid": mid,
            "kid": kid,
            "ttid": ttid,
            "tid": tid,
            "descr": descr,
            "dfrom": dfrom,
            "kgrund": kgrund,
            "kzeit": kzeit
        ]
        
        Alamofire.request(URL_POST_AS, method: .post, parameters: AS).responseJSON{
            response in
            print(response)
        }
        
    }
}


