//
//  TypeOfPropertyTableViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-04.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit

class TypeOfPropertyTableViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indexPathSelected:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indexPathSelected = appDelegate.selectedRow
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.appDelegate.arrayTypeOfProperty.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Type of Property"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTypeOfProperty", for: indexPath)

        cell.selectionStyle = .none
        
        if (indexPathSelected != nil && indexPathSelected == indexPath.row){
            cell.accessoryType = .checkmark
        }
        else{
            cell.accessoryType = .none
        }
 
        cell.textLabel?.text = self.appDelegate.arrayTypeOfProperty[indexPath.row]

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexPathSelected = indexPath.row
        tableView.reloadData()
    }
    
    
    @IBAction func btnCancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnSavePressed(_ sender: Any) {
        appDelegate.selectedRow = indexPathSelected
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    

}
