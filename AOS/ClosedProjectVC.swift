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

class ClosedProjectVC: UITableViewController, PTKIDDelegate{
    
    let URL_GET_CProjects = "http://aos.ssit.at/php/v1/closedProjects.php"
    
    var cP = [String]()
    var article = [String]()
    var asid = -1
    var pid = -1
    var kid = -1
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 66
        self.tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "MG")
        self.title = "Abgeschlossene Projekte"
        loadClosedProjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cP.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MG", for: indexPath) as! MGSwipeTableCell
        
        if(self.cP.count > 0 && indexPath.row < self.cP.count){
            var arr = self.cP[indexPath.row].split(separator: ";")
            cell.textLabel?.text = String(arr[0]) + ". " + String(arr[1]) + " "  + String(arr[2])
            cell.detailTextLabel?.text = String(arr[2])
        }
        
        let leftButton = MGSwipeButton(title: "AS Übersicht", backgroundColor: UIColor.cyan, callback: { (sender: MGSwipeTableCell!) in
            var arr = self.cP[indexPath.row].split(separator: ";")
            
            self.showClosedAS(pid: Int(arr[0])!)
            return true
        })
        
        cell.leftExpansion.buttonIndex = 1
        cell.leftButtons = [leftButton]
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        print(cP[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func setPTKID(_ptid: Int, _kid: Int, _typ: String) {
        kid = _kid
        pid = _ptid
        type = _typ
    }
    
    func loadClosedProjects(){
        Alamofire.request(URL_GET_CProjects, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    
                    if let cp = jsonData.value(forKey: "closedProjects") as? NSArray {
                        let pid = cp.value(forKey: "pid") as! NSArray
                        let descr = cp.value(forKey: "description") as! NSArray
                        let company = cp.value(forKey: "companyname") as! NSArray
                        
                        for i in 0..<cp.count{
                            var a = pid[i] as! String + ";"
                            a += descr[i] as! String + ";"
                            a += company[i] as! String
                            self.cP.append(a)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            
        }
    }
 
    func showClosedAS(pid: Int){
        self.setPTKID(_ptid: pid, _kid: -1, _typ: "Projekt")
        let CASVC = self.storyboard?.instantiateViewController(withIdentifier: "ClosedTicketProjektASVC") as! ClosedTicketProjektASVC
        CASVC.ptid = pid
        CASVC.kid = -1
        CASVC.type = "Projekt"
        CASVC.delegate = self
        self.navigationController?.pushViewController(CASVC, animated: true)
    }
}

