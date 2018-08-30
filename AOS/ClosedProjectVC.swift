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

class ClosedProjectVC: UITableViewController{
    
    let URL_GET_CProjects = "http://aos.ssit.at/php/v1/closedProjects.php"
    
    var cP = [String]()
    var article = [String]()
    var asid = -1
    
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
    
    func loadClosedProjects(){
        Alamofire.request(URL_GET_CProjects, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    
                    let cp = jsonData.value(forKey: "closedProjects") as! NSArray
                    let pid = cp.value(forKey: "pid") as! NSArray
                    let descr = cp.value(forKey: "description") as! NSArray
                    let company = cp.value(forKey: "companyname") as! NSArray
                    
                    for i in 0..<cp.count{
                        var a = pid[i] as! String + ";"
                        a += descr[i] as! String + ";"
                        a += company[i] as! String
                        self.cP.append(a)
                    }
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
}

