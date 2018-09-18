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

class OffeneProjectsVC: UITableViewController, PIDDelegate{
    
    let URL_GET_OProjects = "http://aos.ssit.at/php/v1/offeneProjects.php"
    var URL_GET_Projects = "http://aos.ssit.at/php/v1/getProject.php?pid="
    var URL_GET_ProjectsArticle = "http://aos.ssit.at/php/v1/getOpenProjectsArticle.php?pid="
    
    var oProjects = [String]()
    
    var pid = -1
    var project = [String]()
    var article = [String]()
    
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
        
        let rightButton = MGSwipeButton(title: "Details anzeigen und Bearbeiten", backgroundColor: UIColor.orange, callback: { (sender: MGSwipeTableCell!) in
            var arr = self.oProjects[indexPath.row].split(separator: ";")
            
            self.loadProjectDetails(pid: Int(arr[0])!)
            self.tableView.reloadData()
            return true
        })
        
        rightButton.setPadding(30)
        cell.rightExpansion.buttonIndex = 0
        cell.rightButtons = [rightButton]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return oProjects.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func setPID(_id: Int, _project: [String]) {
        pid = _id
        project = _project
    }
    
    func loadOffeneProjects(){
        Alamofire.request(URL_GET_OProjects, method: .get).responseJSON{
            response in
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let op = jsonData.value(forKey: "offeneProjekte") as! NSArray
                    let pid = op.value(forKey: "pid") as! NSArray
                    let label = op.value(forKey: "label") as! NSArray
                    let company = op.value(forKey: "companyname") as! NSArray
                    for i in 0..<op.count{
                        var a = pid[i] as! String + ";"
                        a += label[i] as! String + ";"
                        a += company[i] as! String + ";"
                        self.oProjects.append(a)
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadProjectDetails(pid: Int){
        URL_GET_Projects += String(pid)
        URL_GET_ProjectsArticle += String(pid)
        
        Alamofire.request(URL_GET_Projects, method: .get).responseJSON{
            response in
            
            if let result = response.result.value{
                let jsonData = result as! NSDictionary
                
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    let Project = jsonData.value(forKey: "Project") as! NSArray
                    
                    let kid = Project.value(forKey: "kid") as! NSArray
                    let cname = Project.value(forKey: "companyname") as! NSArray
                    let label = Project.value(forKey: "label") as! NSArray
                    let descr = Project.value(forKey: "description") as! NSArray
                    let pVolume = Project.value(forKey: "projectVolume") as! NSArray
                    let cDate = Project.value(forKey: "creationDate") as! NSArray
                    let finishedOn = Project.value(forKey: "finishedOn") as! NSArray
                    let settledOn = Project.value(forKey: "settledOn") as! NSArray
                    let type = Project.value(forKey: "projectType") as! NSArray
                    
                    let PROJECT = Project.mutableCopy() as! NSMutableArray
                    
                    for i in 0..<PROJECT.count{
                        var a = (kid[i] as! String) + ". " + (cname[i] as! String) + ";" // Kunde
                        a += (label[i] as! String) + ";" // Label
                        
                        if((descr[i] as! String) == ""){
                            a += "Keine Beschreibung;"
                        }else{
                            a += (descr[i] as! String) + ";" // Description
                        }
                        
                        a += (pVolume[i] as! String) + ";" // Projectvolume
                        a += (cDate[i] as! String) + ";" // Creationdate
                        
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
                        
                        a += (type[i] as! String) + ";" // Projecttype
                        
                        self.project.append(a)
                        
                        Alamofire.request(self.URL_GET_ProjectsArticle, method: .get).responseJSON{
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
                            self.setPID(_id: pid, _project: self.project)
                            let pEVC = self.storyboard?.instantiateViewController(withIdentifier: "ProjectEditVC") as! ProjectEditVC
                            pEVC.pid = pid
                            pEVC.article = self.article
                            pEVC.project = self.project
                            pEVC.delegate = self
                            self.navigationController?.pushViewController(pEVC, animated: true)
                        }
                        
                    }
                    
                }
                
            }
        }
        
    }
    
}
