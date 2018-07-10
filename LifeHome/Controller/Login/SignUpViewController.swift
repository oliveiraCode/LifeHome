//
//  SignUpViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-25.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase
import Photos
import KRActivityIndicatorView

//A lot of code from this page was inspired from YouTube Channel Replicode https://www.youtube.com/watch?v=UPKCULKi0-A&t=7s

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var changeProfileButton: UIButton!
    
    var imagePicker:UIImagePickerController!
    let activityIndicator = KRActivityIndicatorView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cornerRadiusButton()
        userRef = Database.database().reference().child("users")
        
        setupProfileImageView()
        changeProfileButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
    }
    
    func setupProfileImageView(){
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }
    
    @objc func pickImage() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            let cameraPicker = UIImagePickerController()
            cameraPicker.delegate = self
            cameraPicker.sourceType = .camera
            cameraPicker.allowsEditing = true
            self.present(cameraPicker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func showViewTapGestureRecongnizer(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnCreateAccountPressed(_ sender: Any) {
        
        //add an activity indicator from the KRActivityIndicator framework to this view
        addKRActivityIndicatior()
        
        view.isUserInteractionEnabled = false
        handleSignUp()
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPermission()
        
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: print("Access is granted by user")
        case .notDetermined: PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            print("status is \(newStatus)")
            if newStatus == PHAuthorizationStatus.authorized { print("success") }
        })
        case .restricted: print("User do not have access to photo album.")
        case .denied: print("User has denied the permission.")
        }
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
    
    
    @objc func handleSignUp() {
        appDelegate.userObj.username = usernameField.text
        appDelegate.userObj.email = emailField.text
        appDelegate.userObj.phone = phoneField.text
        appDelegate.userObj.password = passwordField.text
        appDelegate.userObj.image = profileImageView.image
        

        Auth.auth().createUser(withEmail: appDelegate.userObj.email, password: appDelegate.userObj.password) { user, error in
            if error == nil && user != nil {
                print("User created!")
                self.appDelegate.userObj.id = Auth.auth().currentUser?.uid //get id from current user
                
                // 1. Upload the profile image to Firebase Storage
                
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
                                        
                                        let alert = UIAlertController(title: "Congratulations!", message: "Your account has been created successfully.", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                            self.dismiss(animated: true, completion: nil)
                                        }))
                                        
                                        self.present(alert, animated: true, completion: nil)
                                        
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
                
            } else {
    
                self.resetForm()
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
    
    
    func cornerRadiusButton (){
        btnCreateAccount.layer.borderWidth = 1
        btnCreateAccount.layer.borderColor = UIColor.init(red: 0/255, green: 111/255, blue: 173/255, alpha: 100).cgColor
        btnCreateAccount.layer.cornerRadius = 25
        btnCreateAccount.layer.masksToBounds = true
    }


    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //function to add custom activity indicator when the user click into create account
    func addKRActivityIndicatior(){
        activityIndicator.style = .color(.black)
        activityIndicator.isLarge = true
        activityIndicator.frame = CGRect(x: UIScreen.main.bounds.width/2, y: (UIScreen.main.bounds.height/2) - 170, width: 0, height: 0)
        
        view.addSubview(activityIndicator)
    }
    
    
}


extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        
        dismiss(animated: true)
    }
    
    
}


