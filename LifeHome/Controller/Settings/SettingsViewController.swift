//
//  SettingsViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-31.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var btnSignInOut: UIButton!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        cornerRadiusButton()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           isLogged()
    }
    
    // MARK: - Table view data source
    
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
     return self.appDelegate.nameSettings.count
        
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSettings", for: indexPath)
        
        let imgSettings = cell.contentView.viewWithTag(100) as! UIImageView
        let nameSettings = cell.contentView.viewWithTag(101) as! UILabel
        
        
        imgSettings.image = UIImage(named:self.appDelegate.imgSettings[indexPath.row])
        nameSettings.text = self.appDelegate.nameSettings[indexPath.row]
        
        return cell
    }
    
    
    
     // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
        
     return true
        
     }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    
    @IBAction func btnSignInOut(_ sender: Any) {
        
        isLogged()
        
    }
    
    func isLogged(){
        
        if ((Auth.auth().currentUser?.uid) == nil) && (btnSignInOut.titleLabel?.text == "Sign In"){
            performSegue(withIdentifier: "showLoginVC", sender: nil)
            return
        }
        
        
        if ((Auth.auth().currentUser?.uid) != nil) && !(btnSignInOut.titleLabel?.text == "Sign Out"){
            btnSignInOut.backgroundColor = UIColor.red
            btnSignInOut.setTitle("Sign Out", for: .normal)
            lbName.text = Auth.auth().currentUser?.displayName
            lbEmail.text = Auth.auth().currentUser?.email
        } else {
            
            do {
                try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            btnSignInOut.backgroundColor = UIColor.blue
            btnSignInOut.setTitle("Sign In", for: .normal)
            lbName.text = "Your name"
            lbEmail.text = "Your email"
            imgProfile.image = UIImage(named: "user")
        }
        
        
        
        
    }
    
    
    func cornerRadiusButton (){
        btnSignInOut.layer.cornerRadius = 15
        btnSignInOut.layer.masksToBounds = true
    }

}
