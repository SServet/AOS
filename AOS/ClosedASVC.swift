//
//  OffeneASVC.swift
//  AOS
//
//  Created by SSIT on 28.08.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Alamofire

class ClosedASVC: UITableViewController, ASIDDelegate{
    
    let URL_GET_CAS = "http://aos.ssit.at/php/v1/closedAS.php"
    var URL_GET_AS = "http://aos.ssit.at/php/v1/getAS.php?asid="
    var URL_GET_ASArticle = "http://aos.ssit.at/php/v1/getOffeneASArticle.php?asid="
    
    var _as = [String]()
    var cAS = [String]()
    var article = [String]()
    var asid = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 66
        self.tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "MG")
        self.title = "Abgeschlossene Arbeitsscheine"
        loadClosedAS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cAS.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MG", for: indexPath) as! MGSwipeTableCell
        
        if(self.cAS.count > 0 && indexPath.row < self.cAS.count){
            var arr = self.cAS[indexPath.row].split(separator: ";")
            cell.textLabel?.text = String(arr[0]) + ". " + String(arr[1]) + " "  + String(arr[2])
            cell.detailTextLabel?.text = String(arr[2])
        }

        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print(cAS[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func loadClosedAS(){
        Alamofire.request(URL_GET_CAS, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    
                    let cas = jsonData.value(forKey: "closedAS") as! NSArray
                    let asid = cas.value(forKey: "asid") as! NSArray
                    let descr = cas.value(forKey: "description") as! NSArray
                    let company = cas.value(forKey: "companyname") as! NSArray
                    let datefrom = cas.value(forKey: "dateFrom") as! NSArray
                    let offeneAS = cas.mutableCopy() as! NSMutableArray
                    
                    for i in 0..<cas.count{
                        var a = asid[i] as! String + ";"
                        a += (descr[i] as! String).replacingOccurrences(of: "\n\r", with: "A M K") + ";"
                        a += company[i] as! String + ";"
                        a += datefrom[i] as! String
                        self.cAS.append(a)
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
}

