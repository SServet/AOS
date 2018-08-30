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

class addTicketVC: FormViewController, ArticleDelegate {
    
    let URL_GET_KUNDEN = "http://aos.ssit.at/php/v1/kunden.php"
    let URL_GET_ARTIKEL = "http://aos.ssit.at/php/v1/artikel.php"
    let URL_GET_TTYP = "http://aos.ssit.at/php/v1/ttyp.php"
    let URL_GET_TART = "http://aos.ssit.at/php/v1/tart.php"
    let URL_POST_TICKET = "http://aos.ssit.at/php/v1/insertTicket.php"
    let URL_POST_TICKET_Artikel = "http://aos.ssit.at/php/v1/artikelTicketInsert.php"
    let URL_POST_Artikel = "http://aos.ssit.at/php/v1/asArticle.php"
    
    var artikel = [String]()
    var closed = false
    var settled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Ticket hinzufügen")
            
            <<< SwitchRow("Ticket abschliessen"){row in
                row.title = "Ticket abgeschlossen"
                row.value = false
                }.onChange{row in
                    if(row.value == true){
                        self.closed = true
                    }else{
                        self.closed = false
                    }
            }
            
            <<< SwitchRow("Ticket abrechnen"){row in
                row.title = "Ticket abgerechnet"
                row.value = false
                }.onChange{row in
                    if(row.value == true){
                        self.settled = true
                    }else{
                        self.settled = false
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
                            row.selectorTitle = "Wähle Sie einen Kunden aus"
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
            
            <<< ButtonRow("Artikel hinzufügen"){
                $0.title = "Artikel hinzufügen"
                $0.onCellSelection(addArticle)
            }
            <<< TextRow("Bezeichnung") {
                $0.title = "Bezeichnung"
            }
            <<< TextRow("Beschreibung") {
                $0.title = "Beschreibung"
            }
            <<< DateRow("Erstelldatum"){
                $0.title = "Erstelldatum"
                $0.value = Date()
            }
            <<< DateRow("Abgeschlossen Am"){
                $0.title = "Abgeschlossen Am"
                $0.value = Date()
            }
            <<< DateRow("Abgerechnet Am"){
                $0.title = "Abgerechnet Am"
                $0.value = Date()
            }
            <<< ButtonRow("Artikel prüfen"){
                $0.title = "Artikel prüfen"
                $0.onCellSelection(checkArticle)
            }
            <<< ButtonRow("Senden"){
                $0.title = "Senden"
                $0.onCellSelection(buttontapped)
            }
        }
    
    func getID(_tag: String) -> Int{
        let id: BaseRow? = form.rowBy(tag: _tag)
        let val = id?.baseValue
        if(val  != nil){
            let a = String(describing: val)
            let b = a.components(separatedBy: "(")
            let c = b[1].components(separatedBy: "\"")
            if c.count > 1{
                let d = c[1].components(separatedBy: ".")
                return Int(d[0]) as! Int
            }
            let d = c[0].components(separatedBy: ".")
            if Int(d[0]) != nil{
                return Int(d[0]) as! Int
            }
            return -1
        }
        return -1;
    }
    
    // Text von der Form lesen
    func getArtikel(_tag: String) -> String{
        let row: TextRow? = form.rowBy(tag: _tag)
        var a = ""
        
        // Text von ausgewaehlte Artikel nehmen
        if(form.rowBy(tag: "Artikel")?.baseValue != nil){
            let arr = String(describing: form.rowBy(tag: "Artikel")?.baseValue).characters.split(separator: "(", maxSplits: 1).map{String($0)}
            let arr1 = arr[1].substring(to: arr[1].index(before: arr[1].endIndex)).components(separatedBy: ".")
            return arr1[1]
        }
        return ""
    }
    
    func setArticle(_art: [String]){
        artikel = _art
    }
    
    // Artikel hinzufuegenß
    func addArticle(cell: ButtonCellOf<String>, row: ButtonRow){
        let id = getID(_tag: "Artikel")
        if(id > -1){
            let descr = getArtikel(_tag: "Artikel")
            let einheit = getArtikeleinheit()
            let anz = form.rowBy(tag: "ArtAnz")?.baseValue as! Int
            let string1 = String(id) + ";" + descr
            let string2 = ";" + String(anz)
            if(einheit != ""){
                let string3 = ";" + einheit
                artikel.append(string1 + string2 + string3)
            }else{
                artikel.append(string1 + string2)
            }
            popup(title_: "Artikel", message_: "Der von ihnen ausgewählter Artikel wurde erfolgreich hinzugefügt!")
        }else{
            popup(title_: "WARNUNG", message_: "Es wurde kein Artikel ausgewählt! Wenn diese Meldung kommt, obwohl ein Artikel ausgewählt wurde," +
                "wählen sie den Artikel erneut aus")
        }
    }

    func getArtikeleinheit() -> String{
        // Artikeleinheit nehmen
        let row1:BaseRow? = form.rowBy(tag: "Artikeleinheit")
        let val = row1?.baseValue
        var einheit = ""
        if(val != nil){
            einheit = String(describing: val)
            let arr = einheit.components(separatedBy: "\"")
            return arr[1]
        }
        return ""
    }
    
    func checkArticle(cell: ButtonCellOf<String>, row: ButtonRow){
        if(artikel.count < 1){
            popup(title_: "INFORMATION", message_: "Es sind keine Artikel vorhanden die überprüft werden können!")
        }else{
            let atvc = self.storyboard?.instantiateViewController(withIdentifier: "ArtikelTVC") as! ArtikelTVC
            atvc.article = artikel
            atvc.delegate = self
            self.navigationController?.pushViewController(atvc, animated: true)
        }
    }
    
    func popup(title_: String, message_: String){
        let alert = UIAlertController(title: title_ , message: message_, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getDate(_tag: String)->String{
        //print(_tag)
        let a = _tag.components(separatedBy: "(")
        if a.contains("nil") == false{
            let b = a[1].components(separatedBy: " ")
            return b[0]
        }
        return ""
    }
    
    // Daten von der Form lesen,
    func buttontapped(cell: ButtonCellOf<String>, row: ButtonRow){
        let kid = getID(_tag: "Kunde")
        let label = getString(_tag: "Bezeichnung")
        let descr = getString(_tag: "Beschreibung")
        var cdate = getDate(_tag: String(describing: form.rowBy(tag: "Erstelldatum")?.baseValue)) as! String
        
        let finisehdOn = getDate(_tag: String(describing: form.rowBy(tag: "Abgeschlossen Am")?.baseValue)) as! String
        let settledOn = getDate(_tag: String(describing: form.rowBy(tag: "Abgerechnet Am")?.baseValue)) as! String
        //print(cdate + "\n" + finisehdOn + "\n" + settledOn)
        let defaultval = UserDefaults.standard
        if(checkKunde(kid: kid) && checkBezeichung(bez: label)){
            if let mid = defaultval.string(forKey: "userid"){
                addTicket(mid: Int(mid)!, kid: kid, label: label, descr: descr, creationDate: cdate, finishedOn: finisehdOn, settledOn: settledOn, close: false)
            }
        }
    }
    
    func addTicket(mid: Int, kid: Int, label: String, descr: String, creationDate: String, finishedOn: String, settledOn: String, close: Bool){
        var Ticket: Parameters=[:]
        
        if(settled && closed){
            Ticket = [
                "mid": mid,
                "kid": kid,
                "label": label,
                "creationDate": creationDate,
                "descr": descr,
                "closed": true,
                "finishedOn": finishedOn,
                "settledOn": settledOn
            ]
        }else if(!settled && closed){
            Ticket = [
                "mid": mid,
                "kid": kid,
                "label": label,
                "creationDate": creationDate,
                "descr": descr,
                "closed": false,
                "finishedOn": finishedOn
            ]
        }else if(!settled && !closed){
            Ticket = [
                "mid": mid,
                "kid": kid,
                "label": label,
                "creationDate": creationDate,
                "descr": descr,
                "closed": false
            ]
        }else if(settled && !closed){
            Ticket = [
                "mid": mid,
                "kid": kid,
                "label": label,
                "creationDate": creationDate,
                "descr": descr,
                "closed": false,
                "settledOn": settledOn
            ]
        }
        
        
        Alamofire.request(URL_POST_TICKET, method: .post, parameters: Ticket).responseJSON{
            response in
            if(self.artikel.count > 0){
                var Ticket_Artikel: Parameters = [:]
                for(index, element) in self.artikel.enumerated(){
                    let arr = element.components(separatedBy: ";")
                    let idx = arr.index(of: "Stk.")
                    let idx2 = arr.index(of: "Std.")
                    if(idx != nil){
                        Ticket_Artikel = [
                            "aid": arr[0],
                            "unit": arr[idx!],
                            "count": arr[2]
                        ]
                    }else if(idx2 != nil){
                        Ticket_Artikel = [
                            "aid": arr[0],
                            "unit": arr[idx2!],
                            "count": arr[2]
                        ]
                    }
                    Alamofire.request(self.URL_POST_TICKET_Artikel, method: .post, parameters: Ticket_Artikel).responseJSON{
                        response in
                        self.popup(title_: "Ticket", message_: "Die Artikel wurden dem Ticket erfolgreich hinzugefügt!")
                    }
                }
            }
            self.popup(title_: "Ticket", message_: "Ticket erfolgreich hinzugefügt!")
        }
    }
    
    func getString(_tag: String) -> String {
        if((form.rowBy(tag: _tag)?.baseValue) != nil){
            return form.rowBy(tag: _tag)?.baseValue as! String
        }else{
            return ""
        }
    }
    
    func checkKunde(kid: Int)->Bool{
        if(kid <= 0){
            popup(title_: "WARNUNG", message_: "Es wurde kein Kunde ausgewählt!")
            return false
        }
        return true
    }
    
    func checkBezeichung(bez: String)->Bool{
        if(bez == ""){
            popup(title_: "WARNUNG", message_: "Es wurde keine Bezeichnung angegeben!")
            return false
        }
        return true
    }
}
