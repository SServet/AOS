//
//  offeneTicketProjektAS.swift
//  AOS
//
//  Created by SSIT on 21.09.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Alamofire

class OffeneTicketProjektAS: UITableViewController, PTKIDDelegate, ArticleDelegate, ASIDDelegate{
    
    var URL_GET_OAS = "http://aos.ssit.at/php/v1/offeneProjektTicketAS.php?"
    var URL_GET_AS = "http://aos.ssit.at/php/v1/getAS.php?asid="
    var URL_GET_ASArticle = "http://aos.ssit.at/php/v1/getOffeneASArticle.php?asid="
    
    var _as = [String]()
    var oAS = [String]()
    var article = [String]()
    var asid = -1
    var ptid = -1
    var kid = -1
    var typ =  ""
    
    var delegate: PTKIDDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 66
        self.tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "MG")
        self.title = "Offene Arbeitsscheine"
        loadOffeneAS()
    }
    
    func setPTKID(_ptid: Int, _kid: Int, _typ: String) {
        ptid = _ptid
        kid = _kid
        typ = _typ
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oAS.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: MGSwipeTableCell = tableView.dequeueReusableCell(withIdentifier: "MG", for: indexPath) as! MGSwipeTableCell
        
        if cell == nil {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.default, reuseIdentifier: "MG")
        }
        
        
        if(self.oAS.count > 0 && indexPath.row < self.oAS.count){
            var arr = self.oAS[indexPath.row].split(separator: ";")
            cell.textLabel?.text = String(arr[0]) + ". " + String(arr[1]) + " "  + String(arr[2])
        }
        
        let rightButton = MGSwipeButton(title: "Details", backgroundColor: UIColor.orange, callback: { (sender: MGSwipeTableCell!) in
            var arr = self.oAS[indexPath.row].split(separator: ";")
            
            self.loadASDetails(_asid: Int(arr[0])!)
            self.tableView.reloadData()
            return true
        })
        
        cell.rightExpansion.buttonIndex = 0
        cell.rightButtons = [rightButton]
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print(oAS[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func loadOffeneAS(){
        if(typ == "Projekt"){
            URL_GET_OAS += "pid=" + String(ptid)
        }else{
            URL_GET_OAS += "tid" + String(ptid)
        }
        Alamofire.request(URL_GET_OAS, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    
                    if let oas = jsonData.value(forKey: "offeneAS") as? NSArray {
                        let asid = oas.value(forKey: "asid") as! NSArray
                        let descr = oas.value(forKey: "description") as! NSArray
                        let company = oas.value(forKey: "companyname") as! NSArray
                        let datefrom = oas.value(forKey: "dateFrom") as! NSArray
                        let offeneAS = oas.mutableCopy() as! NSMutableArray
                        
                        for i in 0..<oas.count{
                            var a = asid[i] as! String + ";"
                            a += descr[i] as! String + ";"
                            a += company[i] as! String + ";"
                            a += datefrom[i] as! String
                            self.oAS.append(a)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    func setASID(_id: Int, as_: [String]){
        asid = _id
        _as = as_
    }
    
    func loadASDetails(_asid: Int){
        URL_GET_AS += String(_asid)
        // Details des AS holen und laden
        Alamofire.request(URL_GET_AS, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let As = jsonData.value(forKey: "AS") as! NSArray
                    let AsDescr = jsonData.value(forKey: "ASDescr") as! NSArray
                    let TTDescr = jsonData.value(forKey: "ASTTDescr") as! NSArray
                    let TKDescr = jsonData.value(forKey: "ASTKDescr") as! NSArray
                    let adescr = AsDescr.value(forKey: "description") as! NSArray
                    let kid = As.value(forKey: "kid") as! NSArray
                    let cname = As.value(forKey: "companyname") as! NSArray
                    let ttid = As.value(forKey: "ttid") as! NSArray
                    let tdescr = TTDescr.value(forKey: "description") as! NSArray
                    let tkid = As.value(forKey: "tkid") as! NSArray
                    let tkdescr = TKDescr.value(forKey: "description") as! NSArray
                    let dfrom = As.value(forKey: "dateFrom") as! NSArray
                    let dto   = As.value(forKey: "dateTo") as! NSArray
                    let tfrom = As.value(forKey: "timeFrom") as! NSArray
                    let tto = As.value(forKey: "timeTo") as! NSArray
                    let kzeit = As.value(forKey: "kulanzzeit") as! NSArray
                    let kgrund = As.value(forKey: "kulanzgrund") as! NSArray
                    let AS = As.mutableCopy() as! NSMutableArray
                    
                    for i in 0..<AS.count{
                        var a = adescr[i] as! String + ";" //Beschreibung
                        a += (kid[i] as! String) + ". " + (cname[i] as! String) + ";" //Kunde
                        a += (ttid[i] as! String) + ". " + (tdescr[i] as! String) + ";" //Termintyp
                        a += (tkid[i] as! String) + ". " + (tkdescr[i] as! String) + ";" //Taetigkeitsart
                        a += dfrom[i] as! String + ";" //Datum von
                        
                        if(dto[i] is NSNull){ //Datum bis
                            a += "0000-00-00;"
                        }else{
                            a += dto[i] as! String
                        }
                        
                        a += tfrom[i] as! String + ";" //Uhrzeit von
                        
                        if(tto[i] is NSNull){ //Uhrzeit bis
                            a += "00:00:00;"
                        }else{
                            a += tto[i] as! String + ";"
                        }
                        
                        a += kzeit[i] as! String + ";" //Kulanzzeit
                        a += kgrund[i] as! String + ";" //Kulanzgrung
                        self._as.append(a)
                        
                        // Artikel zu dem dazugehoerigen AS holen und laden
                        self.URL_GET_ASArticle += String(_asid)
                        Alamofire.request(self.URL_GET_ASArticle, method: .get).responseJSON{
                            response in
                            if let result = response.result.value{
                                let jsonData = result as! NSDictionary
                                
                                if(!(jsonData.value(forKey: "error") as! Bool)){
                                    let oasArticle = jsonData.value(forKey: "Articles") as! NSArray
                                    let artid = oasArticle.value(forKey: "artID") as! NSArray
                                    let name = oasArticle.value(forKey: "articlename") as! NSArray
                                    let count = oasArticle.value(forKey: "count") as! NSArray
                                    let unit = oasArticle.value(forKey: "unit") as! NSArray
                                    
                                    for i in 0..<oasArticle.count{
                                        var a = (artid[i] as! String) + ";"
                                        a += (name[i] as! String) + ";"
                                        a += (count[i] as! String) + ";"
                                        a += (unit[i] as! String)
                                        self.article.append(a)
                                    }
                                }
                            }
                            self.setASID(_id: _asid, as_: self._as)
                            let asEVC = self.storyboard?.instantiateViewController(withIdentifier: "ASEditVC") as! ASEditVC
                            asEVC.asid = _asid
                            asEVC.article = self.article
                            asEVC._as = self._as
                            asEVC.delegate = self
                            self.navigationController?.pushViewController(asEVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func setArticle(_art: [String]) {
        article = _art
    }
    
}

