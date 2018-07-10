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
    var adId:String!
    let adObj = Ad()
    let addressObj = Address()
    let contactObj = Contact()
    var locationCoordinate = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeTitleNavigatorBar()
        
        let nibName = UINib(nibName: "MyNewAdCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myNewAdCell")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: NSNotification.Name(rawValue: "saveData"), object: nil)
    }
    
    
    //Hide header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
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
    
    
    @IBAction func btnSaveAdPressed(_ sender: Any) {
        
        let indexPath : NSIndexPath = NSIndexPath(row: 0, section: 0) //Create the indexpath to get the cell
        let cell : MyNewAdCell = self.tableView.cellForRow(at: indexPath as IndexPath) as! MyNewAdCell
        self.adObj.id = ref.childByAutoId().key //create a new Id
    
            
            self.addressObj.street = cell.tfStreet.text!
            self.addressObj.city = cell.tfCity.text!
            self.addressObj.province = cell.tfProvince.text!
            self.addressObj.postalCode = cell.tfPostalCode.text!
            
            //we need to wait the function getCoordinateFromGeoCoder finish to update this information
            self.addressObj.latitude = 0
            self.addressObj.longitude = 0
            
            if cell.segTypeOfAd.selectedSegmentIndex == 0 {
                self.adObj.typeOfAd = TypeOfAd.Rent
            } else {
                self.adObj.typeOfAd = TypeOfAd.Sell
            }
            
            self.adObj.creationDate = self.getTodaysDate()
            self.adObj.imageStorage = self.adObj.id
            self.adObj.image = cell.imgAd.image
            self.adObj.bathroom = Int(cell.lbBathroom.text! as String)
            self.adObj.bedroom = Int(cell.lbBedroom.text! as String)
            self.adObj.garage = Int(cell.lbGarage.text! as String)
            self.adObj.description = cell.tvDescription.text
            self.adObj.price = Float(cell.tfPrice.text! as String)
            self.adObj.typeOfProperty = cell.btnTypeOfProperty.titleLabel?.text
            
            self.contactObj.email = cell.tfEmail.text!
            self.contactObj.phone = cell.tfPhone.text!
            
            self.saveData()
        
            DispatchQueue.main.async {
                let address = "\(self.addressObj.street!), \(self.addressObj.city!), \(self.addressObj.province!) \(self.addressObj.postalCode!)"
                self.getCoordinateFromGeoCoder(address: address)
            }
        
        let alert = UIAlertController(title: "", message: "Saved successfully.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        


    }
    
    func getTodaysDate() -> String{
        let date = NSDate()
        let calendar = NSCalendar.current
        let days = calendar.component(.day, from: date as Date)
        let months = calendar.component(.month, from: date as Date)
        let year = calendar.component(.year, from: date as Date)
        
        var day:String!
        var month:String!
        
        if days < 10 {
            day = "0\(days)"
        } else {
            day = "\(days)"
        }
        
        if months < 10 {
            month = "0\(months)"
        }else{
            month = "\(months)"
        }
        
        return "\(day!)/\(month!)/\(year)"
    }
    
    
    func getCoordinateFromGeoCoder(address:String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks, error) in
            if let placemark = placemarks?.first {
                self.locationCoordinate = placemark.location!
                NotificationCenter.default.post(name: Notification.Name("saveData"), object: nil)
            }
        })
    }
    
    @objc func saveData(){
        
        self.addressObj.latitude = locationCoordinate.coordinate.latitude
        self.addressObj.longitude = locationCoordinate.coordinate.longitude

        var typeOfAd:String?
        
        
        let addressData = [
            "city": self.addressObj.city!,
            "postal code": self.addressObj.postalCode!,
            "province": self.addressObj.province!,
            "street": self.addressObj.street!,
            "latitude":self.addressObj.latitude!,
            "longitude":self.addressObj.longitude!
            ] as [String:Any]
        
        let contactData = [
            "email":self.contactObj.email!,
            "phone":self.contactObj.phone!
        ] as [String:Any]
        
        switch adObj.typeOfAd {
        case .Rent?:
            typeOfAd = "Rent"
        default:
            typeOfAd = "Sell"
        }
        
        let adData = [
            "bathroom": self.adObj.bathroom!,
            "bedroom": self.adObj.bedroom!,
            "garage": self.adObj.garage!,
            "description": self.adObj.description!,
            "price": self.adObj.price!,
            "typeOfAd": typeOfAd!,
            "typeOfProperty": self.adObj.typeOfProperty!,
            "creationDate": self.adObj.creationDate!,
            "Address": addressData,
            "Contact": contactData,
            "imageStorage": self.adObj.imageStorage!
            ] as [String:Any]
        
        self.ref.child("Ad").child(self.uid!).child(self.adObj.id!).setValue(adData)
        
        self.saveImageToDatabase()
       
    }
    
    
    
    @IBAction func cancelAdPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func saveImageToDatabase() {
        
        guard let imageData = UIImageJPEGRepresentation(self.adObj.image!, 60) else {return}
        let storageRef = Storage.storage().reference().child("ImageAds").child(self.uid!).child(self.adObj.imageStorage!)
        
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



