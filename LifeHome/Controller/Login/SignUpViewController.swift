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
    
    @IBOutlet weak var fullNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var btnCreateAccount: UIButton!
    @IBOutlet weak var changeProfileButton: UIButton!
    
    var imagePicker:UIImagePickerController!
    let activityIndicator = KRActivityIndicatorView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cornerRadiusButton()
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        changeProfileButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }

    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCreateAccountPressed(_ sender: Any) {
        
        //add an activity indicator from the KRActivityIndicator framework to this view
        addKRActivityIndicatior()
        
        view.isUserInteractionEnabled = false
        handleSignUp()
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("ImageUsers/\(uid)")
        
        guard let imageData = UIImagePNGRepresentation(image) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                if let url = metaData?.downloadURL() {
                    completion(url)
                } else {
                    completion(nil)
                }
                // success!
            } else {
                // failed
                completion(nil)
            }
        }
    }
    
    
    @objc func handleSignUp() {
        
      
        guard let username = fullNameField.text else { return }
        guard let email = emailField.text else { return }
        guard let phone = phoneField.text else { return }
        guard let pass = passwordField.text else { return }
        guard let image = profileImageView.image else { return }
        
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                print("User created!")
                
                // 1. Upload the profile image to Firebase Storage
                
                self.uploadProfileImage(image) { url in
                    
                    if url != nil {
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest?.displayName = username
                        changeRequest?.photoURL = url
                        
                        changeRequest?.commitChanges { error in
                            if error == nil {
                                print("User display name changed!")
                                
                                self.saveProfile(username: username,phone: phone, profileImageURL: url!) { success in
                                    if success {
                                        UserDefaults.standard.set(false, forKey: "ContinueWithoutAnAccount")
            
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
    
    
    
    func saveProfile(username:String, phone:String, profileImageURL:URL, completion: @escaping ((_ success:Bool)->())) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/\(uid)")
        
        
        let userObject = [
            "fullName": username,
            "Phone": phone,
            "photoURL": profileImageURL.absoluteString
            ] as [String:Any]
        
        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
        }
    }
    
    
    func cornerRadiusButton (){
        btnCreateAccount.layer.cornerRadius = 25
        btnCreateAccount.layer.masksToBounds = true
    }


    @IBAction func btnCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //function to add custom activity indicator when the user click into create account
    func addKRActivityIndicatior(){
        activityIndicator.style = .color(.blue)
        activityIndicator.isLarge = true
        activityIndicator.frame = CGRect(x: UIScreen.main.bounds.width/2, y: (UIScreen.main.bounds.height/2) - 170, width: 0, height: 0)
        
        view.addSubview(activityIndicator)
    }
    
    
}


extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
   @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}


