//
//  CollapsableTableVC.swift
//  AOS
//
//  Created by SSIT on 02.08.18.
//  Copyright © 2018 SSIT. All rights reserved.
//

import UIKit
import CollapsibleTableSectionViewController

struct Item {
    public var name: String
    public var detail: String
    
    public init(name: String, detail: String) {
        self.name = name
        self.detail = detail
    }
}

struct CSection {
    public var name: String
    public var items: [Item]
    
    public init(name: String, items: [Item]) {
        self.name = name
        self.items = items
    }
}

class CollapsableTableVC: CollapsibleTableSectionViewController{
   
    var sections: [CSection] = [CSection(name: "Mac", items: [Item(name: "MacBook Pro", detail: "1500$")])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self as! CollapsibleTableSectionDelegate
    }
}

extension CollapsableTableVC: CollapsibleTableSectionDelegate{
        func numberOfSections(_ tableView: UITableView) -> Int {
            return sections.count
        }
        
        func collapsibleTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return sections[section].items.count
        }
        
        func collapsibleTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell") as UITableViewCell? ?? UITableViewCell(style: .subtitle, reuseIdentifier: "BasicCell")
            
            let item: Item = sections[indexPath.section].items[indexPath.row]
            
            cell.textLabel?.text = item.name
            cell.detailTextLabel?.text = item.detail
            
            return cell
        }
        
        func collapsibleTableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return sections[section].name
        }
    }

