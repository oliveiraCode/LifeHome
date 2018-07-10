//
//  LoginViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-25.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import KRActivityIndicatorView

@objcMembers
class LoginViewController: UIViewController {
    
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    let userRef = Database.database().reference().child("users")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let activityIndicator = KRActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadiusButton()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser?.uid != nil{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnSignIn(_ sender: Any) {
        guard let email = tfEmail.text else {return}
        guard let password = tfPassword.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error == nil && user != nil {
                UserDefaults.standard.set(false, forKey: "ContinueWithoutAnAccount")
                self.appDelegate.getDataFromUser()
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error: \(error!.localizedDescription)")
            }
            
        }
        
    }
    
    @IBAction func loginFacebookTapped(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile","email"], from: self){(result,error) in
            if error != nil{
                
            }else if result!.isCancelled{
                print("User cancelled login")
            }else{
                self.useFirebaseLogin()
            }
        }
    }
    
    func useFirebaseLogin(){
        //add an activity indicator from the KRActivityIndicator framework to this view
        addKRActivityIndicatior()
        
        view.isUserInteractionEnabled = false
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        Auth.auth().signInAndRetrieveData(with: credential){(result,error) in
            
            if error == nil{
                self.appDelegate.userObj.email = result?.user.email!
                self.appDelegate.userObj.username = result?.user.displayName
                self.appDelegate.userObj.id = Auth.auth().currentUser?.uid
                self.appDelegate.userObj.phone = result?.user.phoneNumber ?? "000-0000"
                
                self.getImage(url: (result?.user.photoURL)!)
                
            }else{
                print("Could not Login user \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    func resetForm() {
        //There are several ways of handling error in the Firebase site.
        //https://firebase.google.com/docs/auth/ios/errors
        
        let alert = UIAlertController(title: "Error signing up", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        self.activityIndicator.stopAnimating()
        self.view.isUserInteractionEnabled = true
        
    }
    
    //part of this code was inspired from https://www.youtube.com/watch?v=Z6D68MMx2pw
    func getImage(url:URL){
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: { ( data, response, error) in
            if data != nil{
                let image = UIImage(data: data!)
                if(image != nil){
                    self.appDelegate.userObj.image = image
                    
                    self.saveImageToDatabase(self.appDelegate.userObj.image) { url in
                        if url != nil {
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.photoURL = url
                            
                            changeRequest?.commitChanges { error in
                                if error == nil {
                                    print("User display name changed!")
                                    
                                    self.saveProfile(profileImageURL: url!) { success in
                                        if success {
                                            UserDefaults.standard.set(true, forKey: "ContinueWithoutAnAccount")
                                            self.activityIndicator.stopAnimating()
                                            self.view.isUserInteractionEnabled = true
                                            self.dismiss(animated: true, completion: nil)
                                        } else {
                                            self.resetForm()
                                        }
                                    }
                                    
                                } else {
                                    print("Error: \(error!.localizedDescription)")
                                    self.resetForm()
                                }
                            }
                        } else {
                            self.resetForm()
                        }
                    }
                }
            }
        })
        task.resume()
    }
    
    
    func saveImageToDatabase(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        let storageRef = Storage.storage().reference().child("ImageUsers/\(appDelegate.userObj.id)")
        
        guard let imageData = UIImageJPEGRepresentation(image, 60) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { (strMetaData, error) in
            if error == nil{
                print("Image Uploaded successfully")
            }
            else{
                print("Error Uploading image: \(String(describing: error?.localizedDescription))")
            }
        }
        
    }
    
    func saveProfile(profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        
        let userData = [
            "username": appDelegate.userObj.username,
            "email":appDelegate.userObj.email,
            "phone": appDelegate.userObj.phone,
            "photoURL": profileImageURL.absoluteString
            ] as [String:Any]
        
        userRef.child(appDelegate.userObj.id).setValue(userData) { error, ref in
            completion(error == nil)
        }
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        performSegue(withIdentifier: "showSignUpVC", sender: nil)
    }
    
    func cornerRadiusButton (){
        btnSignIn.layer.borderWidth = 1
        btnSignIn.layer.borderColor = UIColor.init(red: 0/255, green: 111/255, blue: 173/255, alpha: 100).cgColor
        btnSignIn.layer.cornerRadius = 20
        btnSignIn.layer.masksToBounds = true
        
        btnFacebook?.layer.cornerRadius = 20
        btnFacebook?.layer.masksToBounds = true
    }
    
    @IBAction func btnContinueWithoutAnAccountPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "ContinueWithoutAnAccount")
        self.dismiss(animated: true, completion: nil)
    }
    
    //function to add custom activity indicator when the user click into create account
    func addKRActivityIndicatior(){
        activityIndicator.style = .color(.blue)
        activityIndicator.isLarge = true
        activityIndicator.frame = CGRect(x: UIScreen.main.bounds.width/2, y: (UIScreen.main.bounds.height/2) - 130, width: 0, height: 0)
        
        view.addSubview(activityIndicator)
    }
}


