//
//  File.swift
//  AOS
//
//  Created by SSIT on 12.03.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ArtikelTVC: UITableViewController {
    
    let ASArticle = addArbeitsscheinVC()
    var article = [String]()
    var delegate:ArticleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ArtikelTVC: " + String(describing: article))
        tableView.rowHeight = 66
        
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController:parent)
        if parent == nil {
            delegate?.setArticle(_art: article)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return article.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MGSwipeTableCell
        
        cell.textLabel?.text = article[indexPath.row]
        cell.detailTextLabel?.text = article[indexPath.row]
        
        let rightButton = MGSwipeButton(title: "Löschen", backgroundColor: UIColor.red, callback: { (sender: MGSwipeTableCell!) in
            self.deleteArticle(idx: indexPath.item)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            return true
        })
        
        let leftButton = MGSwipeButton(title: "Fav", backgroundColor: UIColor(red: 0.2471, green: 0.7647, blue: 0.502, alpha: 1) , callback: { (sender: MGSwipeTableCell!) in
            self.zeigeAlert(mitTitel: "Fav")
            return true
        })
        let left2Button = MGSwipeButton(title: "Check", backgroundColor: UIColor.orange, callback: { (sender: MGSwipeTableCell!) in
            self.zeigeAlert(mitTitel: "Check")
            return true
        })
        
        
        rightButton.setPadding(30)
        cell.rightExpansion.buttonIndex = 0
        cell.rightButtons = [rightButton]
        
        leftButton.setPadding(10)
        left2Button.setPadding(10)
        cell.leftExpansion.buttonIndex = 1
        
        cell.leftButtons = [left2Button, leftButton]
        
        return cell
    }
    
    func deleteArticle(idx : Int){
        article.remove(at: idx)
        self.viewDidLoad()
    }
    
    func zeigeAlert(mitTitel : String){
        let alert =  UIAlertController(title: mitTitel, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in })
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}