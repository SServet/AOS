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

class OffeneTicketVC: UITableViewController, TIDDelegate {
    
    let URL_GET_OTickets = "http://aos.ssit.at/php/v1/offeneTickets.php"
    var URL_GET_Ticket = "http://aos.ssit.at/php/v1/getTicket.php?tid="
    var URL_GET_TicketArticles = "http://aos.ssit.at/php/v1/getOpenTicketsArticle.php?tid="
    
    var oTickets = [String]()
    var ticket = [String]()
    var article = [String]()
    
    var tid = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 66
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
        //print(self.oTickets)
        if(self.oTickets.count > 0 && indexPath.row < self.oTickets.count){
            var arr = self.oTickets[indexPath.row].split(separator: ";")
            cell.textLabel?.text = String(arr[0]) + ". " + String(arr[1]) + " "  + String(arr[2])
        }
        let rightButton = MGSwipeButton(title: "Details anzeigen und Bearbeiten", backgroundColor: UIColor.orange, callback: { (sender: MGSwipeTableCell!) in
            var arr = self.oTickets[indexPath.row].split(separator: ";")
            
            self.loadTicketDetails(tid: Int(arr[0])!)
            self.tableView.reloadData()
            return true
        })
        
        rightButton.setPadding(30)
        cell.rightExpansion.buttonIndex = 0
        cell.rightButtons = [rightButton]
        
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
                    let label = ot.value(forKey: "label") as! NSArray
                    let company = ot.value(forKey: "companyname") as! NSArray
                    for i in 0..<ot.count{
                        var a = tid[i] as! String + ";"
                        a += label[i] as! String + ";"
                        a += company[i] as! String + ";"
                        self.oTickets.append(a)
                    }
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    func loadTicketDetails(tid: Int){
        URL_GET_Ticket += String(tid)
        URL_GET_TicketArticles += String(tid)
        
        Alamofire.request(URL_GET_Ticket, method: .get).responseJSON{
            response in
            
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let Ticket = jsonData.value(forKey: "Ticket") as! NSArray
                    
                    let kid = Ticket.value(forKey: "kid") as! NSArray
                    let cname = Ticket.value(forKey: "companyname") as! NSArray
                    let cDate = Ticket.value(forKey: "creationDate") as! NSArray
                    let label = Ticket.value(forKey: "label") as! NSArray
                    let descr = Ticket.value(forKey: "descripiton") as! NSArray
                    let finishedOn = Ticket.value(forKey: "finishedOn") as! NSArray
                    let settledOn  = Ticket.value(forKey: "settledOn") as! NSArray
                    
                    let TICKET = Ticket.mutableCopy() as! NSMutableArray
                    
                    for i in 0..<TICKET.count{
                        var a = (kid[i] as! String) + ". " + (cname[i] as! String) + ";" // Kunde
                        a += (label[i] as! String) + ";" // Label
                        a += (cDate[i] as! String) + ";" // Creationdate
                        
                        if(descr[i] is NSNull){
                            a += "Keine Beschreibung;" // Description
                        }else{
                            a += (descr[i] as! String) + ";" // Description
                        }
                        
                        if(finishedOn[i] is NSNull){
                            a += "0000-00-00;" // Finished On
                        }else{
                            a += (finishedOn[i] as! String) + ";" // Finished on
                        }
                        
                        if(settledOn[i] is NSNull){
                            a += "0000-00-00;" // Settled On
                        }else{
                            a += (settledOn[i] as! String) + ";" // Settled on
                        }
                        
                        self.ticket.append(a)
                        
                        Alamofire.request(self.URL_GET_TicketArticles, method: .get).responseJSON{
                            response in
                            
                            if let result = response.result.value{
                                let jsonData = result as! NSDictionary
                                
                                if(!(jsonData.value(forKey: "error") as! Bool)){
                                    let oatArticle = jsonData.value(forKey: "Articles") as! NSArray
                                    let artid = oatArticle.value(forKey: "artID") as! NSArray
                                    let name = oatArticle.value(forKey: "articlename") as! NSArray
                                    let count = oatArticle.value(forKey: "count") as! NSArray
                                    let unit = oatArticle.value(forKey: "unit") as! NSArray
                                    
                                    for i in 0..<oatArticle.count{
                                        var a = (artid[i] as! String) + ";"
                                        a += (name[i] as! String) + ";"
                                        a += (count[i] as! String) + ";"
                                        a += (unit[i] as! String)
                                        self.article.append(a)
                                    }
                                }
                            }
                            self.setTID(_id: tid, _ticket: self.ticket)
                            let tEVC = self.storyboard?.instantiateViewController(withIdentifier: "TicketEditVC") as! TicketEditVC
                            tEVC.tid = tid
                            tEVC.article = self.article
                            tEVC.ticket = self.ticket
                            tEVC.delegate = self
                            tEVC.delegate?.setTID(_id: tid, _ticket: self.ticket)
                            self.navigationController?.pushViewController(tEVC, animated: true)
                            
                        }
                        
                    }
                }
                
            }
            
        }
        
    }
    
    func setTID(_id: Int, _ticket: [String]) {
        tid = _id
        ticket = _ticket
    }
    
}
