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
        tableView.rowHeight = 66
        
    }
    
    // Uebpruefen ob der zurueck Button geklickt wurde
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController:parent)
        if parent == nil {
            // Bearbeite Artikel zurueck senden
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
        
        // Eine Cell anlegen
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MGSwipeTableCell
        
        // Text der Tabelle setzen, Text wird aus den mitgeliferten Array aus Artikeln genommen
        var arr = article[indexPath.row].split(separator: ";")
        let id = arr[0]
        let descr = arr[1]
        let anz = arr[2]
        let einheit = arr[3]
        
        cell.textLabel?.text = String(id)
        
        cell.detailTextLabel?.text = descr + "; " + String(anz) + "; " + einheit
        
        // Einen Swipebutton anlegen der von rechtes kommt
        let rightButton = MGSwipeButton(title: "Löschen", backgroundColor: UIColor.red, callback: { (sender: MGSwipeTableCell!) in
            self.deleteArticle(idx: indexPath.item)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            return true
        })
        
        // Einen Swipebutton anlegen der von links kommt
        let leftButton = MGSwipeButton(title: "Artkel Anzahl ändern", backgroundColor: UIColor(red: 0.2471, green: 0.7647, blue: 0.502, alpha: 1) , callback: { (sender: MGSwipeTableCell!) in
            let alert = UIAlertController(title: "Neue Artikelanzahl", message: "Geben Sie die neue Artikelanzahl ein!", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .default, handler: { (action: UIAlertAction!) in })
            
            let saveAction = UIAlertAction(title: "Speichern", style: .default, handler: { (action: UIAlertAction!) in
                
                let textField = alert.textFields![0] as UITextField
                textField.keyboardType = UIKeyboardType.numberPad
                cell.detailTextLabel?.text = descr + ", " + textField.text! + ", " + einheit
                self.editArticle(idx: indexPath.item, id: String(id), descr: String(descr), anz: textField.text!, einheit: String(einheit))
            })
            
            alert.addTextField { (textField) in
                textField.keyboardType = .decimalPad
            }
            
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            self.present(alert, animated: true, completion: nil)
            
            self.tableView.reloadData()
            return true
        })
        
        
        rightButton.setPadding(30)
        cell.rightExpansion.buttonIndex = 0
        cell.rightButtons = [rightButton]
        
        leftButton.setPadding(10)
        cell.leftExpansion.buttonIndex = 1
        
        cell.leftButtons = [leftButton]
        
        return cell
    }
    
    func deleteArticle(idx : Int){
        article.remove(at: idx)
        self.viewDidLoad()
    }
    
    func editArticle(idx : Int, id : String, descr: String, anz: String, einheit: String){
        self.article[idx] = id + ";" + descr + ";" + anz + ";" + einheit
    }
    
    func zeigeAlert(mitTitel : String){
        let alert =  UIAlertController(title: mitTitel, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in })
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func doStringContainsNumber( _string : String) -> Bool{
        
        let numberRegEx  = "^[0-9]*$"
        let testCase = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
        let containsNumber = testCase.evaluate(with: _string)
        
        return containsNumber
    }
    
}
