//
//  MenuViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-31.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase
import KRProgressHUD

class  MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var btnSignInOut: UIButton!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    let ref = Database.database().reference()
    
    let nameMenu:[String] = ["Home","Profile","Settings","Help","About"]
    let imgMenu:[String] = ["home","profile","settings","help","about"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        cornerRadiusButton()
        
        imgProfile.layer.cornerRadius = imgProfile.bounds.height / 2
        imgProfile.clipsToBounds = true
        
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.nameMenu.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMenu", for: indexPath)
        
        let imgMenu = cell.contentView.viewWithTag(100) as! UIImageView
        let nameMenu = cell.contentView.viewWithTag(101) as! UILabel
        
        
        imgMenu.image = UIImage(named:self.imgMenu[indexPath.row])
        nameMenu.text = self.nameMenu[indexPath.row]
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0  {
              performSegue(withIdentifier: "showHomeVC", sender: nil)
        }
        
        if indexPath.row == 1  {
            
            if Auth.auth().currentUser?.uid == nil {
                KRProgressHUD.showError(withMessage: "You must to be logged in to access it.")
                
                DispatchQueue.main.asyncAfter(deadline: .now()+10) {
                    KRProgressHUD.dismiss()
                }
            } else {
                //   performSegue(withIdentifier: "showProfileVC", sender: nil)
            }
         
        }
        
        if indexPath.row == 2  {
                performSegue(withIdentifier: "showSettingsVC", sender: nil)
        }
        
        if indexPath.row == 3  {
               performSegue(withIdentifier: "showHelpVC", sender: nil)
        }
        
        if indexPath.row == 4  {
            performSegue(withIdentifier: "showAboutVC", sender: nil)
        }
        
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
        
        if Auth.auth().currentUser?.uid == nil{
            performSegue(withIdentifier: "showLoginVC", sender: nil)
        }
        
        if btnSignInOut.titleLabel?.text == "Sign Out" {
            
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser?.uid != nil {
            btnSignInOut.backgroundColor = UIColor.red
            btnSignInOut.setTitle("Sign Out", for: .normal)
            lbName.text = Auth.auth().currentUser?.displayName
            lbEmail.text = Auth.auth().currentUser?.email
            getPhotoFromProfile()
        }
        
    }
    
    func getPhotoFromProfile (){
        
        //this code was inspired from https://stackoverflow.com/questions/39398282/retrieving-image-from-firebase-storage-using-swift
        
        let usersRef = ref.child("users").child((Auth.auth().currentUser?.uid)!)
        
        // only need to fetch once so use single event
        usersRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if !snapshot.exists() { return }
            
            let userInfo = snapshot.value as! NSDictionary
            let photoURL = userInfo["photoURL"] as! String //Here we can get the picture's url from Firebase
            
            let storageRef = Storage.storage().reference(forURL: photoURL)
            storageRef.downloadURL(completion: { (url, error) in
                
                do {
                    let data = try Data(contentsOf: url!)
                    self.imgProfile.image = UIImage(data: data as Data)
                    
                } catch {
                    print("error")
                }
                
            })
        } )
    }
    
    func cornerRadiusButton (){
        btnSignInOut.layer.cornerRadius = 10
        btnSignInOut.layer.masksToBounds = true
    }
    
}
