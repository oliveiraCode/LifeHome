//
//  LoginViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-25.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadiusButton()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    func cornerRadiusButton (){
        btnLogin.layer.cornerRadius = 25
        btnLogin.layer.masksToBounds = true
        
        btnFacebook.layer.cornerRadius = 25
        btnFacebook.layer.masksToBounds = true
    }
    
}


