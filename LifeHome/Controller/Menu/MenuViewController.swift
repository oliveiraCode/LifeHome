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
import FBSDKCoreKit

class  MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var btnSignInOut: UIButton!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var img_login_logout: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    let ref = Database.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let nameMenu:[String] = [NSLocalizedString("Home", comment: "Home"),
                             NSLocalizedString("Profile", comment: "Profile"),
                             NSLocalizedString("Settings", comment: "Settings"),
                             NSLocalizedString("About", comment: "About")]
    
    let imgMenu:[String] = [NSLocalizedString("home", comment: "home"),
                            NSLocalizedString("profile", comment: "profile"),
                            NSLocalizedString("settings", comment: "settings"),
                            NSLocalizedString("about", comment: "about")]
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent //StatusBar white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        isLogged()
        setupImgProfile()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(updateInfoUser), name: NSNotification.Name(rawValue: "updateInfoUser"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isLogged()
    }
    
    // MARK: - Setup ViewController
    func setupImgProfile(){
        imgProfile.layer.cornerRadius = imgProfile.bounds.height / 2
        imgProfile.layer.borderWidth = 1
        imgProfile.layer.borderColor = UIColor.white.cgColor
        imgProfile.clipsToBounds = true
    }
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    // MARK: - TableView Methods
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
                KRProgressHUD.showError(withMessage: "You must be logged in to access it.")
                
                DispatchQueue.main.asyncAfter(deadline: .now()+10) {
                    KRProgressHUD.dismiss()
                }
            } else {
                let alert = UIAlertController(title: nil, message: "That feature will be created in the next version. Sorry!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                //   performSegue(withIdentifier: "showProfileVC", sender: nil)
            }
            
        }
        
        if indexPath.row == 2  {
            performSegue(withIdentifier: "showSettingsVC", sender: nil)
        }
        
        if indexPath.row == 3  {
            performSegue(withIdentifier: "showAboutVC", sender: nil)
        }
        
    }
    
    
    // MARK: - Account Methods
    @IBAction func btnSignInOut(_ sender: Any) {
        if Auth.auth().currentUser?.uid == nil{
            performSegue(withIdentifier: "showLoginVC", sender: nil)
        } else {
            do {
                try Auth.auth().signOut()
                appDelegate.userObj.resetValues()
                img_login_logout.image = UIImage(named: "login_btn")
                btnSignInOut.setTitle("Sign In", for: .normal)
                lbName.text = "Your name"
                lbEmail.text = "Your email"
                imgProfile.image = UIImage(named: "user")
                
            } catch {
            }
        }
        
    }
    

    func isLogged(){
        if Auth.auth().currentUser?.uid != nil {
            appDelegate.getDataFromUser()
            img_login_logout.image = UIImage(named: "logout_btn")
            btnSignInOut.setTitle("Sign Out", for: .normal)
            
        }
    }
    
    //update info user got from firebase
    @objc func updateInfoUser(){
        lbName.text = appDelegate.userObj.username
        lbEmail.text = appDelegate.userObj.email
        imgProfile.image = appDelegate.userObj.image
    }
    
    
    
}
