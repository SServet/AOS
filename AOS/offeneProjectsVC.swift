//
//  offeneProjectsVC.swift
//  AOS
//
//  Created by SSIT on 10.08.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import Foundation
import MGSwipeTableCell
import UIKit
import Alamofire

class OffeneProjectsVC: UITableViewController{
    
    let URL_GET_OProjects = "http://aos.ssit.at/php/v1/offeneProjects.php"
    
    var oProjects = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 66
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(MGSwipeTableCell.self, forCellReuseIdentifier: "MGProject")
        self.title = "Offene Projekte"
        loadOffeneProjects()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: MGSwipeTableCell = tableView.dequeueReusableCell(withIdentifier: "MGProject", for: indexPath) as! MGSwipeTableCell
        
        if cell == nil {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.default, reuseIdentifier: "MGProject")
        }
        
        if(self.oProjects.count > 0 && indexPath.row < self.oProjects.count){
            var arr = self.oProjects[indexPath.row].split(separator: ";")
            cell.textLabel?.text = String(arr[0]) + ". " + String(arr[1]) + " "  + String(arr[2])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oProjects.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func loadOffeneProjects(){
        Alamofire.request(URL_GET_OProjects, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let op = jsonData.value(forKey: "offeneProjekte") as! NSArray
                    let pid = op.value(forKey: "pid") as! NSArray
                    let descr = op.value(forKey: "description") as! NSArray
                    let company = op.value(forKey: "companyname") as! NSArray
                    for i in 0..<op.count{
                        var a = pid[i] as! String + ";"
                        a += descr[i] as! String + ";"
                        a += company[i] as! String + ";"
                        self.oProjects.append(a)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }    
}
