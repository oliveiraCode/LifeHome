//
//  FindViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-24.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase

class MapFindViewController: UIViewController {

    @IBOutlet weak var constraintChanged: NSLayoutConstraint!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()

        Auth.auth().addStateDidChangeListener { auth, user in
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if user == nil && !UserDefaults.standard.bool(forKey: "ContinueWithoutAnAccount") {
                let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.appDelegate.window?.rootViewController = controller
                self.appDelegate.window?.makeKeyAndVisible()
            }
            
        }
        
        // Do any additional setup after loading the view.
    }

    

    @IBAction func segmentedPressed(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            constraintChanged.constant = 0
        }
        
        if sender.selectedSegmentIndex == 1 {
            constraintChanged.constant = -375
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
