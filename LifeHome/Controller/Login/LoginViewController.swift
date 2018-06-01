//
//  LoginViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-25.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func btnSignIn(_ sender: Any) {
        guard let email = tfEmail.text else {return}
        guard let password = tfPassword.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error == nil && user != nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                 print("Error: \(error!.localizedDescription)")
            }

        }
        
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        performSegue(withIdentifier: "showSignUpVC", sender: nil)
    }
    
    func cornerRadiusButton (){
        btnSignIn.layer.cornerRadius = 25
        btnSignIn.layer.masksToBounds = true
        
        btnFacebook.layer.cornerRadius = 25
        btnFacebook.layer.masksToBounds = true
    }
    
    @IBAction func btnContinueWithoutAnAccountPressed(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "ContinueWithoutAnAccount")
        
        self.dismiss(animated: true, completion: nil)
    }
}


