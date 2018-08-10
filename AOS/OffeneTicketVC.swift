//
//  offeneTicketVC.swift
//  AOS
//
//  Created by SSIT on 10.08.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import Foundation
import MGSwipeTableCell
import UIKit
import Alamofire

class OffeneTicketVC: UITableViewController {
    
    let URL_GET_OTickets = "http://aos.ssit.at/php/v1/offeneTickets.php"
    
    var oTickets = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 66
        self.tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "MGTicket")
        self.title = "Offene Tickets"
        loadOffenTickets()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oTickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      var cell: MGSwipeTableCell = tableView.dequeueReusableCell(withIdentifier: "MGTicket", for: indexPath) as! MGSwipeTableCell
        
        if cell == nil {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.default, reuseIdentifier: "MGTicket")
        }
        //print(self.oTickets.count)
        if(self.oTickets.count > 0 && indexPath.row < self.oTickets.count){
            var arr = self.oTickets[indexPath.row].split(separator: ";")
            cell.textLabel?.text = String(arr[0]) + ". " + String(arr[1]) + " "  + String(arr[2])
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func loadOffenTickets(){
        Alamofire.request(URL_GET_OTickets, method: .get).responseJSON{
            response in
            //print(response)
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let ot = jsonData.value(forKey: "offeneTickets") as! NSArray
                    let tid = ot.value(forKey: "tid") as! NSArray
                    let descr = ot.value(forKey: "description") as! NSArray
                    let company = ot.value(forKey: "companyname") as! NSArray
                    for i in 0..<ot.count{
                        var a = tid[i] as! String + ";"
                        a += descr[i] as! String + ";"
                        a += company[i] as! String + ";"
                        self.oTickets.append(a)
                    }
                    
                    //print(self.oTickets)
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
}
