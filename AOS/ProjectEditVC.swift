//
//  ProjectEditVC.swift
//  AOS
//
//  Created by SSIT on 03.09.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import Foundation

class ProjectEditVC: FormViewController, PIDDelegate, ArticleDelegate {
    
    let URL_GET_ARTIKEL = "http://aos.ssit.at/php/v1/artikel.php"
    let URL_POST_PROJEKT = "http://aos.ssit.at/php/v1/addEditProject.php"
    let URL_POST_PROJEKT_Artikel = "http://aos.ssit.at/php/v1/addArticleEditProject.php"
    
    var pid = 0
    var project = [String]()
    var article = [String]()
    var oldArticle = [String]()
    var delegateArticle:ArticleDelegate?
    var delegate: PIDDelegate?
    
    var closed = false
    var settled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Projekt bearbeiten")
            
            <<< SwitchRow("Projekt abschliessen"){row in
                row.title = "Projekt abgeschlossen"
                row.value = false
                }.onChange{row in
                    if(row.value == true){
                        self.closed = true
                    }else{
                        self.closed = false
                    }
                }
            
            <<< SwitchRow("Projekt abrechnen"){row in
                row.title = "Projekt abgerechnet"
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
                var skundearr = [SearchItemModel]()
                let k = self.project[0].split(separator: ";")
                skundearr.append(SearchItemModel.init(0, String(k[0])))
                row.value = skundearr[0]
                row.baseCell.isUserInteractionEnabled = false
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
                $0.value = String(project[0].split(separator: ";")[1])
            }
            <<< TextRow("Beschreibung") {
                $0.title = "Beschreibung"
                $0.value = String(project[0].split(separator: ";")[2])
            }
            <<< PushRow<String>("Art"){
                $0.title = "Projektart"
                $0.options = ["Pauschal", "Aufwand"]
                $0.selectorTitle = "Wähle eine Projektart"
                if(project[0].split(separator: ";").count >= 8){
                    $0.value = String(project[0].split(separator: ";")[7])
                }
            }
            <<< DecimalRow("Projektvolumen") {
                $0.title = "Projektvolumen in Euro"
                let arr = project[0].split(separator: ";")
                $0.value = Double(project[0].split(separator: ";")[3])
            }
            <<< DateRow("BestellDate"){
                $0.title = "Bestelldatum"
                var tmp = String(project[0].split(separator: ";")[4])
                if(tmp == "0000-00-00"){
                    $0.value = Date()
                }else{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
                    let date = dateFormatter.date(from: String(tmp))
                    $0.value = date
                    $0.reload()
                }
            }
            <<< DateRow("Abgeschlossen Am"){
                $0.title = "Abgeschlossen Am"
                var tmp = String(project[0].split(separator: ";")[5])
                if(tmp == "0000-00-00"){
                    $0.value = Date()
                }else{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
                    let date = dateFormatter.date(from: String(tmp))
                    $0.value = date
                    $0.reload()
                }
            }
            <<< DateRow("Abgerechnet Am"){
                $0.title = "Abgerechnet Am"
                var tmp = String(project[0].split(separator: ";")[6])
                if(tmp == "0000-00-00"){
                    $0.value = Date()
                }else{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
                    let date = dateFormatter.date(from: String(tmp))
                    $0.value = date
                    $0.reload()
                }
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
        article = _art
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
                article.append(string1 + string2 + string3)
            }else{
                article.append(string1 + string2)
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
        if(article.count < 1){
            popup(title_: "INFORMATION", message_: "Es sind keine Artikel vorhanden die überprüft werden können!")
        }else{
            let atvc = self.storyboard?.instantiateViewController(withIdentifier: "ArtikelTVC") as! ArtikelTVC
            atvc.article = article
            atvc.delegate = self
            self.navigationController?.pushViewController(atvc, animated: true)
        }
    }
    
    func popup(title_: String, message_: String){
        let alert = UIAlertController(title: title_ , message: message_, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func buttontapped(cell: ButtonCellOf<String>, row: ButtonRow){
        let kid = getID(_tag: "Kunde")
        let label = getString(_tag: "Bezeichnung")
        let descr = getString(_tag: "Beschreibung")
        var cdate = getDate(_tag: String(describing: form.rowBy(tag: "BestellDate")?.baseValue)) as! String
        
        let finisehdOn = getDate(_tag: String(describing: form.rowBy(tag: "Abgeschlossen Am")?.baseValue)) as! String
        let settledOn = getDate(_tag: String(describing: form.rowBy(tag: "Abgerechnet Am")?.baseValue)) as! String
        
        let art = getString(_tag: "Art")
        var vol = form.rowBy(tag: "Projektvolumen")?.baseValue
        
        if(vol != nil){
            vol = vol as! Double
        }
        
        let defaultval = UserDefaults.standard
        if(checkKunde(kid: kid) && checkBezeichung(bez: label)){
            if let mid = defaultval.string(forKey: "userid"){
                addProjekt(mid: Int(mid)!, kid: kid, label: label, descr: descr, orderDate: cdate, finishedOn: finisehdOn, settledOn: settledOn, art: art, vol: Int(vol as! Double))
            }
        }
    }
    
    func getDate(_tag: String)->String{
        let a = _tag.components(separatedBy: "(")
        if a.contains("nil") == false{
            let b = a[1].components(separatedBy: " ")
            return b[0]
        }
        return ""
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
    
    func addProjekt(mid: Int, kid: Int, label: String, descr: String, orderDate: String, finishedOn: String, settledOn: String, art: String, vol: Int){
        var Projekt: Parameters = [:]
        
        if(settled && closed){
            Projekt = [
                "pid": self.pid,
                "label": label,
                "orderDate": orderDate,
                "descr": descr,
                "projectVolume": vol,
                "finishedOn": finishedOn,
                "settledOn": settledOn,
                "type": art,
                "closed": true
            ]
        }else if(!settled && closed){
            Projekt = [
                "pid": self.pid,
                "label": label,
                "orderDate": orderDate,
                "descr": descr,
                "projectVolume": vol,
                "finishedOn": finishedOn,
                "type": art,
                "closed": false
            ]
        }else if(!settled && !closed){
            Projekt = [
                "pid": self.pid,
                "label": label,
                "orderDate": orderDate,
                "descr": descr,
                "projectVolume": vol,
                "type": art,
                "closed": false
            ]
        }else if(settled && !closed){
            Projekt = [
                "pid": self.pid,
                "label": label,
                "orderDate": orderDate,
                "descr": descr,
                "projectVolume": vol,
                "settledOn": settledOn,
                "type": art,
                "closed": false
            ]
        }
        
        Alamofire.request(URL_POST_PROJEKT, method: .post, parameters: Projekt).responseJSON{
            response in
            var Projekt_Artikel: Parameters = [:]
            if(self.article.count > 0){
                for(index, element) in self.article.enumerated(){
                    let arr = element.components(separatedBy: ";")
                    let idx = arr.index(of: "Stk.")
                    let idx2 = arr.index(of: "Std.")
                    if(idx != nil){
                        Projekt_Artikel = [
                            "pid": self.pid,
                            "aid": arr[0],
                            "unit": arr[idx!],
                            "count": arr[2]
                        ]
                    }else if(idx2 != nil){
                        Projekt_Artikel = [
                            "pid": self.pid,
                            "aid": arr[0],
                            "unit": arr[idx2!],
                            "count": arr[2]
                        ]
                    }
                    Alamofire.request(self.URL_POST_PROJEKT_Artikel, method: .post, parameters: Projekt_Artikel).responseJSON{
                        response in
                        self.popup(title_: "Projekt", message_: "Die Artikel wurden dem Projekt erfolgreich hinzugefügt!")
                    }
                }
            }else{
                let PID_Parameter: Parameters = ["pid": self.pid]
                Alamofire.request(self.URL_POST_PROJEKT_Artikel, method: .post, parameters: PID_Parameter).responseJSON{
                    response in
                    self.popup(title_: "Projekt", message_: "Die Artikel wurden dem Projekt erfolgreich hinzugefügt!")
                }
            }
            self.popup(title_: "Projekt", message_: "Projekt erfolgreich aktualisiert!")
        }
    }
    
    
    func setPID(_id: Int, _project: [String]) {
        pid = _id
        project = _project
    }
    
    
}
