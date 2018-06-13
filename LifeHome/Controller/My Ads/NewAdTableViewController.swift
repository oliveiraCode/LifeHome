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
    let uid = Auth.auth().currentUser?.uid //get the current uid
    let adObj = Ad()
    let addressObj = Address()
    
    
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
        let adId = ref.childByAutoId().key //create a new Id
        var typeOfAd:String?
        
        self.uploadProfileImage(image:cell.imgAd.image!, adId:adId, uid:uid!) { url in
            
            self.addressObj.street = cell.tfStreet.text!
            self.addressObj.city = cell.tfCity.text!
            self.addressObj.province = cell.tfProvince.text!
            self.addressObj.postalCode = cell.tfPostalCode.text!
            let address = "\(self.addressObj.street!), \(self.addressObj.city!), \(self.addressObj.province!) \(self.addressObj.postalCode!)"
            print(address)
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                    else {
                        print("test")
                        return}
                
                print("vai ser fuder \(location.coordinate.latitude)")
                self.addressObj.latitude = location.coordinate.latitude
                self.addressObj.longitude = location.coordinate.longitude
            }
        
            
            
            let addressData = [
                "city": self.addressObj.city!,
                "postal code": self.addressObj.postalCode!,
                "province": self.addressObj.province!,
                "street": self.addressObj.street!,
                "latitude":self.addressObj.latitude!,
                "longitude":self.addressObj.longitude!
                ] as [String: Any]
            
            
            if cell.segTypeOfAd.selectedSegmentIndex == 0 {
                self.adObj.typeOfAd = TypeOfAd.Rent
                typeOfAd = "Rent"
            } else {
                self.adObj.typeOfAd = TypeOfAd.Sell
                typeOfAd = "Sell"
            }
            
            self.adObj.bathroom = Int(cell.lbBathroom.text! as String)
            self.adObj.bedroom = Int(cell.lbBedroom.text! as String)
            self.adObj.garage = Int(cell.lbGarage.text! as String)
            self.adObj.description = cell.tvDescription.text
            self.adObj.price = Float(cell.tfPrice.text! as String)
            self.adObj.typeOfProperty = cell.btnTypeOfProperty.titleLabel?.text

            
            let adData = [
                "bathroom": self.adObj.bathroom!,
                "bedroom": self.adObj.bedroom!,
                "garage": self.adObj.garage!,
                "description": self.adObj.description!,
                "price": self.adObj.price!,
                "typeOfAd": typeOfAd!,
                "typeOfProperty": self.adObj.typeOfProperty!,
                "Address": addressData,
                "imageURL": url!.absoluteString
                ] as [String:Any]
            
            
            
            self.ref.child("Ad").child(self.uid!).child(adId).setValue(adData)
            
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
    
    func getCoordinates (address:String){
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                else {return}
            
            print("vai ser fuder \(location.coordinate.latitude)")
            self.addressObj.latitude = location.coordinate.latitude
            self.addressObj.longitude = location.coordinate.longitude
        }
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



