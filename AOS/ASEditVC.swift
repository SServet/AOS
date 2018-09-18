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


class ASEditVC: FormViewController, ASIDDelegate, ArticleDelegate{
    
    var asid = 0
    var _as = [String]()
    var article = [String]()
    var oldArticle = [String]()
    var delegateArticle:ArticleDelegate?
    var delegate: ASIDDelegate?
    
    let URL_GET_TTYP = "http://aos.ssit.at/php/v1/ttyp.php"
    let URL_GET_TART = "http://aos.ssit.at/php/v1/tart.php"
    let URL_GET_ARTIKEL = "http://aos.ssit.at/php/v1/artikel.php"
    let URL_POST_AS = "http://aos.ssit.at/php/v1/addEditAS.php"
    let URL_POST_AS_CLOSED = "http://aos.ssit.at/php/v1/EditASClose.php"
    let URL_POST_ARTIKEL_EDIT_AS = "http://aos.ssit.at/php/v1/addArticleEditAS.php"
    
    var asClose = false
    
    override func viewDidLoad() {
        oldArticle = article
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
                var skundearr = [SearchItemModel]()
                let k = self._as[0].split(separator: ";")
                skundearr.append(SearchItemModel.init(0, String(k[1])))
                row.value = skundearr[0]
                row.baseCell.isUserInteractionEnabled = false
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
                                    let a = artid[i] as! NSString
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
                                    let a = ((ttid[i] as! NSString) as String) + ". " + ((termintyp[i] as! NSString) as String) as String
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
        
            <<< ButtonRow("Artikel prüfen"){
                $0.title = "Artikel prüfen"
                $0.onCellSelection(checkArticle)
            }
            <<< ButtonRow("Senden"){
                $0.title = "Senden"
                $0.onCellSelection(buttontapped)
        }
        
    }
    
    // Daten von der Form lesen,
    func buttontapped(cell: ButtonCellOf<String>, row: ButtonRow){
        let kid = getID(_tag: "Kunde")
        let ttid = getID(_tag: "Termintyp")
        let tid  = getID(_tag: "Tätigkeit")
        let descr = getString(_tag: "Beschreibung")
        var dfrom = getDate(_tag: String(describing: form.rowBy(tag: "Datum von")?.baseValue))
        var kgrund = getKulanzGrund(_tag: "Kulanzgrund")
        var kzeit = getKulanzZeit(_tag: "Kulanzzeit")
        let defaultval = UserDefaults.standard
        let tfrom = getZeit(_tag: "Zeit von")
        var dTo = getDate(_tag: String(describing: form.rowBy(tag: "Datum bis")?.baseValue))
        let tTo = getZeit(_tag: "Zeit bis")
        
        var arr = dfrom.components(separatedBy: "-")
        if(arr.count > 1){
            let month = arr[1]
            let day = Int(arr[2])! + 1
            if(Int(month)! < 10){
                if(Int(arr[2])! < 10){
                    dfrom = String(arr[0]) + "-0" + month + "-0" + String(day)
                }else{
                    dfrom = String(arr[0]) + "-0" + month + "-" + String(day)
                }
            }else{
                if(Int(arr[2])! < 10){
                    dfrom = String(arr[0]) + "-" + month + "-0" + String(day)
                }else{
                    dfrom = String(arr[0]) + "-" + month + "-" + String(day)
                }
            }
        }
        
        arr = dTo.components(separatedBy: "-")
        if(arr.count > 1){
            let month = arr[1]
            let day = Int(arr[2])! + 1
            if(Int(month)! < 10){
                if(Int(arr[2])! < 10){
                    dTo = String(arr[0]) + "-0" + month + "-0" + String(day)
                }else{
                    dTo = String(arr[0]) + "-0" + month + "-" + String(day)
                }
            }else{
                if(Int(arr[2])! < 10){
                    dTo = String(arr[0]) + "-" + month + "-0" + String(day)
                }else{
                    dTo = String(arr[0]) + "-" + month + "-" + String(day)
                }
            }
        }
        
        if(kgrund == ""){ kgrund = "Keine Kulanzzeit" }
        if(kzeit == -1){ kzeit = 0 }
        if(checkID(id1: kid, id2: ttid, id3: tid) && descr != ""){
            if let mid = defaultval.string(forKey: "userid"){
                addAS(mid: Int(mid)!, kid: kid, ttid: ttid, tid: tid, descr: descr, dfrom: dfrom, kgrund: kgrund, kzeit: Int(kzeit), tFrom: tfrom, dTo: dTo, tTo: tTo)
            }
        }else{
            popup(title_: "Warnung", message_: "Es wurde keine Beschreibung geschrieben!")
        }
    }
    
    func setASID(_id: Int, as_: [String]){
        asid = _id
        _as = as_
    }
    
    // Artikel hinzufuegenß
    func addArticle(cell: ButtonCellOf<String>, row: ButtonRow){
        let id = getID(_tag: "Artikel")
        if(id > -1){
            let descr = getString(_tag: "Artikel")
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
    
    // Artikel an die View ArtikelTVC senden um dort diese zu loeschen/aendern
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
    
    // ID von einer Row von der Form lesen
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
    
    func popup(title_: String, message_: String){
        let alert = UIAlertController(title: title_ , message: message_, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Text von der Form lesen
    func getString(_tag: String) -> String{
        
        let row: TextRow? = form.rowBy(tag: _tag)
        var a = ""
        
        // Vordefinierte Beschreibungen zu der Beschreibung einfuegen
        if(row?.value != nil){
            if(form.rowBy(tag: "Vordefinierte Beschreibung")?.baseValue != nil){
                let arr = String(describing: form.rowBy(tag: "Vordefinierte Beschreibung")?.baseValue).components(separatedBy: "(")
                let arr1 = arr[2].components(separatedBy: "[")
                let arr2 = arr1[1].components(separatedBy: "\"")
                for tt in arr2{
                    if tt != "" && tt != ", " && tt != "]))"{
                        a += " " + tt
                    }
                }
                return (row?.value) as! String + String(describing: a)
            }
            return (row?.value) as! String
        }
        
        // Vorderfnierte Beschreibung als Beschreibung nehmen
        if(form.rowBy(tag: "Vordefinierte Beschreibung")?.baseValue != nil){
            let arr = String(describing: form.rowBy(tag: "Vordefinierte Beschreibung")?.baseValue).components(separatedBy: "(")
            let arr1 = arr[2].components(separatedBy: "[")
            let arr2 = arr1[1].components(separatedBy: "\"")
            for tt in arr2{
                if tt != "" && tt != ", " && tt != "]))"{
                    a.append(tt + " ")
                }
            }
            return String(describing: a)
        }
        
        // Text von ausgewaehlte Artikel nehmen
        if(form.rowBy(tag: "Artikel")?.baseValue != nil){
            let arr = String(describing: form.rowBy(tag: "Artikel")?.baseValue).characters.split(separator: "(", maxSplits: 1).map{String($0)}
            let arr1 = arr[1].substring(to: arr[1].index(before: arr[1].endIndex)).components(separatedBy: ".")
            return arr1[1]
        }
        return ""
    }
    
    func setArticle(_art: [String]) {
        article = _art
    }
    
    // Datum von Form lesen
    func getDate(_tag: String)->String{
        let a = _tag.components(separatedBy: "(")
        let df = DateFormatter()
        if a.contains("nil") == false{
            let b = a[1].components(separatedBy: " ")
            return b[0]
        }
        return df.string(from: Date(timeIntervalSinceNow: 0))
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
    
    func getZeit(_tag: String)-> String{
        let a = String(describing: form.rowBy(tag: _tag)?.baseValue)
        let timeArr = a.components(separatedBy: " ")
        let timeArr2 = timeArr[1].components(separatedBy: ":")
        var correctTime = Int(timeArr2[0])!
        if((correctTime + 1) == 24){
            correctTime = 00
        }else{
            correctTime += 1
        }
        let time = String(correctTime) + ":" + timeArr2[1] + ":00"
        return time
    }
    
    func getKulanzGrund(_tag: String)->String{
        let row: TextRow? = form.rowBy(tag: _tag)
        
        if row?.value != nil{
            return (row?.value) as! String
        }
        
        return ""
    }
    
    func getKulanzZeit(_tag: String)->Int{
        let row: IntRow? = form.rowBy(tag: _tag)
        
        if row?.value != nil{
            let value = row?.baseValue as! Int
            return value
        }
        
        return -1
    }
    
    // Arbeitsschein anlegen
    func addAS(mid: Int, kid: Int, ttid: Int, tid: Int, descr: String, dfrom: String, kgrund: String, kzeit: Int, tFrom: String, dTo: String, tTo: String){
        var AS: Parameters=[
            "asid": self.asid,
            "descr": descr,
            "ttid": ttid,
            "tid": tid,
            "dfrom": dfrom,
            "kzeit": kzeit,
            "kgrund": kgrund,
            "tfrom": tFrom
        ]
        
        if(!asClose){
            Alamofire.request(URL_POST_AS, method: .post, parameters: AS).responseJSON{
                response in
                if(self.article.count > 0){
                    var AS_Artikel: Parameters = [:]
                    for i in 0..<self.article.count{
                        let arr = self.article[i].components(separatedBy: ";")
                        let idx = arr.index(of: "Stk.")
                        let idx2 = arr.index(of: "Std.")
                        if(idx != nil){
                            AS_Artikel = [
                                "asid": self.asid,
                                "aid": arr[0],
                                "unit": arr[idx!],
                                "count": arr[2]
                            ]
                        }else if(idx2 != nil){
                            AS_Artikel = [
                                "asid": self.asid,
                                "aid": arr[0],
                                "unit": arr[idx2!],
                                "count": arr[2]
                            ]
                        }
                        Alamofire.request(self.URL_POST_ARTIKEL_EDIT_AS, method: .post, parameters: AS_Artikel).responseJSON{
                            response in
                            self.popup(title_: "Arbeitsschein", message_: "Die Artikel wurden dem Arbeitsschein erfolgreich hinzugefügt!")
                        }
                    }
                }
                self.popup(title_: "Arbeitsschein", message_: "Arbeitsschein erfolgreich aktualisiert!")
            }
        }else{
            AS = [
                "asid": self.asid,
                "descr": descr,
                "ttid": ttid,
                "tid": tid,
                "dfrom": dfrom,
                "kzeit": kzeit,
                "kgrund": kgrund,
                "tfrom": tFrom,
                "dTo": dTo,
                "tTo": tTo
            ]
            Alamofire.request(URL_POST_AS_CLOSED, method: .post, parameters: AS).responseJSON{
                response in
                if(self.article.count > 0){
                    var AS_Artikel: Parameters = [:]
                    for i in 0..<self.article.count{
                        let arr = self.article[i].components(separatedBy: ";")
                        let idx = arr.index(of: "Stk.")
                        let idx2 = arr.index(of: "Std.")
                        if(idx != nil){
                            AS_Artikel = [
                                "asid": self.asid,
                                "aid": arr[0],
                                "unit": arr[idx!],
                                "count": arr[2]
                            ]
                        }else if(idx2 != nil){
                            AS_Artikel = [
                                "asid": self.asid,
                                "aid": arr[0],
                                "unit": arr[idx2!],
                                "count": arr[2]
                            ]
                        }
                        Alamofire.request(self.URL_POST_ARTIKEL_EDIT_AS, method: .post, parameters: AS_Artikel).responseJSON{
                            response in
                            self.popup(title_: "Arbeitsschein", message_: "Die Artikel wurden dem Arbeitsschein erfolgreich hinzugefügt!")
                        }
                    }
                }
                self.popup(title_: "Arbeitsschein", message_: "Arbeitsschein erfolgreich aktualisiert!")
            }
        }
    }
}
