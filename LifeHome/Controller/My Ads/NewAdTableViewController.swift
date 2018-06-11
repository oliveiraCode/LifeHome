//
//  NewAdTableViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-29.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Photos
import Firebase
import KRProgressHUD


class NewAdTableViewController: UITableViewController,ImagePickerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var ref: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        
        let nibName = UINib(nibName: "MyNewAdCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myNewAdCell")
        
    }
    
    
    //NotificationCenter was inspired from https://stackoverflow.com/questions/38204703/notificationcenter-issue-on-swift-3
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(openTypeOfPropertyVC), name: NSNotification.Name(rawValue: "openTypeOfPropertyVC"), object: nil)
        
        tableView.reloadData() //to show a new value to type of property
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "openTypeOfPropertyVC"), object: nil)
    }
    
    //to call the TableViewController TypeOfProperty
    @objc func openTypeOfPropertyVC(){
        self.performSegue(withIdentifier: "showTypeOfPropertyVC", sender: nil)
    }
    
    
    @IBAction func saveAdPressed(_ sender: Any) {
        
        let indexPath : NSIndexPath = NSIndexPath(row: 0, section: 0) //Create the indexpath to get the cell
        let cell : MyNewAdCell = self.tableView.cellForRow(at: indexPath as IndexPath) as! MyNewAdCell
        
        
        let uid = Auth.auth().currentUser?.uid
        let adId = self.ref.childByAutoId().key //create a new Id
        
        self.uploadProfileImage(image:cell.imgAd.image!, adId:adId, uid:uid!) { url in
            
            let addressObject = [
                "city": cell.tfCity.text!,
                "postal code": cell.tfPostalCode.text!,
                "province": cell.tfProvince.text!,
                "street": cell.tfStreet.text!,
                ] as [String: Any]
            
            var typeOfAd:String!
            if cell.segTypeOfAd.selectedSegmentIndex == 0 {
                typeOfAd = "Rent"
            } else {
                typeOfAd = "Sell"
            }
            
            
            let adObject = [
                "bathroom": cell.lbBathroom.text!,
                "bedroom": cell.lbBedroom.text!,
                "garage": cell.lbGarage.text!,
                "description": cell.tvDescription.text!,
                "price": cell.tfPrice.text!,
                "typeOfAd": typeOfAd,
                "typeOfProperty": cell.btnTypeOfProperty.titleLabel?.text!,
                "Address": addressObject,
                "imageURL": url?.absoluteString
                ] as [String:Any]
            
            
            
            self.ref.child("Ad").child(uid!).child(adId).setValue(adObject)
            
        }

        let alert = UIAlertController(title: "", message: "Saved successfully.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelAdPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func uploadProfileImage(image:UIImage, adId:String, uid:String, completion: @escaping ((_ url:URL?)->())) {
        
        let storageRef = Storage.storage().reference().child("ImageAds/\(uid)/\(adId)")
        
        guard let imageData = UIImageJPEGRepresentation(image, 60) else {return}
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
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
    

    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 1
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myNewAdCell", for: indexPath) as! MyNewAdCell
        
        cell.btnTypeOfProperty.setTitle(appDelegate.arrayTypeOfProperty[appDelegate.selectedRow], for: .normal)
        
        cell.delegate = self
        
        return cell
        
    }
    
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        
        
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
}

extension NewAdTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let cell = tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! MyNewAdCell
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            cell.imgAd.contentMode = .scaleAspectFill
            
            cell.imgAd.image = pickedImage
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}



