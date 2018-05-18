//
//  ViewController.swift
//  KudaGoParser
//
//  Created by Никита Гагаринов on 14.05.2018.
//  Copyright © 2018 nikita. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var parseManager = ParseManager()
    let currentDate = Date().timeIntervalSince1970

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        parseManager.parseKudaGo(request: parseType.events(currentDate: currentDate).request) {_ in
            self.tableView?.reloadData()
        }
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parseManager.listOfFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        fillDataIn(cell)
        
        return cell
    }
    
    func fillDataIn(_ cell: TableViewCell) {
        
        
        
    }
    
    
}

