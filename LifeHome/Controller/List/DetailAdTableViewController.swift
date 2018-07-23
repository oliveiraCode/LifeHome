//
//  DetailsAdTableViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-18.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase

class DetailAdTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference = Database.database().reference()
    var uid = Auth.auth().currentUser?.uid //get the current uid
    var isWishlist = false
    var imgURL:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeTitleNavigatorBar()
        
        let nibName = UINib(nibName: "MyDetailAdCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myCell")
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(saveWishlist), name: NSNotification.Name(rawValue: "saveWishlist"), object: nil)
        
        
    }
    

    
    @objc func saveWishlist(){
        
        
        //Check if the user is logged before to show a new ad view controller
        if Auth.auth().currentUser?.uid == nil {
            let alert = UIAlertController(title: "Sign In", message: "You must sign in to save an annonce.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { action in
                self.performSegue(withIdentifier: "showLoginVC", sender: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            if isWishlist {
                saveData()
            } else {
                deleteData()
            }
        }
        
        
    }
    
    func deleteData(){
        self.ref.child("Wishlist").child(self.uid!).child(self.appDelegate.detailAd[0].id!).setValue(nil)
        self.tableView.reloadData() //to change the heart picture
    }
    
    func saveData(){
        
        let addressData = [
            "city": self.appDelegate.detailAd[0].address!.city!,
            "postal code": self.appDelegate.detailAd[0].address!.postalCode!,
            "province": self.appDelegate.detailAd[0].address!.province!,
            "street": self.appDelegate.detailAd[0].address!.street!,
            "latitude": self.appDelegate.detailAd[0].address!.latitude!,
            "longitude": self.appDelegate.detailAd[0].address!.longitude!
            ] as [String:Any]
        
        let contactData = [
            "email":self.appDelegate.detailAd[0].contact!.email!,
            "phone":self.appDelegate.detailAd[0].contact!.phone!
            ] as [String:Any]
        
        let adData = [
            "bathroom": self.appDelegate.detailAd[0].bathroom!,
            "bedroom": self.appDelegate.detailAd[0].bedroom!,
            "garage": self.appDelegate.detailAd[0].garage!,
            "description": self.appDelegate.detailAd[0].description!,
            "price": self.appDelegate.detailAd[0].price!,
            "typeOfAd": self.appDelegate.detailAd[0].typeOfAd!.rawValue,
            "typeOfProperty": self.appDelegate.detailAd[0].typeOfProperty!.rawValue,
            "creationDate":self.appDelegate.detailAd[0].creationDate!,
            "Address": addressData,
            "Contact": contactData,
            "imageStorage": self.appDelegate.detailAd[0].imageStorage!
            ] as [String:Any]
        
        
        self.ref.child("Wishlist").child(self.uid!).child(self.appDelegate.detailAd[0].id!).setValue(adData)
        self.tableView.reloadData() //to change the heart picture
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        uid = Auth.auth().currentUser?.uid //get the current uid
        //tableView.reloadData()
    }
    
    
    func checkIfWishlistExist () -> Bool{
        var existFlag = false
        
        if Auth.auth().currentUser?.uid == nil { return existFlag }
        
        ref.child("Wishlist").child(self.uid!).observe(.value) { (snapshot) in
            
            for adId in snapshot.children.allObjects as! [DataSnapshot] {
                
                if adId.key == self.appDelegate.detailAd[0].id! {
                    existFlag = true
                    self.tableView.reloadData()
                }
            }
            
        }
        return existFlag
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyDetailAdCell
        
        cell.lbCreatedOn.text = "Created on \(self.appDelegate.detailAd[indexPath.row].creationDate!)"
        cell.lbPhone.text = self.appDelegate.detailAd[indexPath.row].contact?.phone
        cell.lbEmail.text = self.appDelegate.detailAd[indexPath.row].contact?.email
        cell.imageAd.image = self.appDelegate.detailAd[indexPath.row].image
        cell.tvDescription.text = self.appDelegate.detailAd[indexPath.row].description
        cell.lbBedroom.text = String(self.appDelegate.detailAd[indexPath.row].bedroom!)
        cell.lbBathroom.text = String(self.appDelegate.detailAd[indexPath.row].bathroom!)
        cell.lbGarage.text = String(self.appDelegate.detailAd[indexPath.row].garage!)
        cell.lbAddress1.text = self.appDelegate.detailAd[indexPath.row].address?.street
        
        let address = "\((self.appDelegate.detailAd[indexPath.row].address?.city)!), \((self.appDelegate.detailAd[indexPath.row].address?.province)!), \((self.appDelegate.detailAd[indexPath.row].address?.postalCode)!.uppercased())"
        cell.lbAddress2.text = address
        
        cell.lbTypeOfAd.text = "For \((self.appDelegate.detailAd[indexPath.row].typeOfAd?.rawValue)!)"
        
        cell.lbTypeOfProperty.text = self.appDelegate.detailAd[indexPath.row].typeOfProperty?.rawValue
        cell.lbPrice.text = String(format: "CAD %.2f",self.appDelegate.detailAd[indexPath.row].price!)
        
        
        if isWishlist || checkIfWishlistExist(){
            cell.btnWishlist.setImage(UIImage(named: "wishlist_saved"), for: .normal)
            isWishlist = false
        } else {
            cell.btnWishlist.setImage(UIImage(named: "wishlist_unsaved"), for: .normal)
            isWishlist = true
        }
        
        let imageRef = Storage.storage().reference().child("ImageAds").child(self.appDelegate.detailAd[indexPath.row].imageStorage!)
        
        // get the download URL
        imageRef.downloadURL { url, error in
            if let error = error {
                print("error downlaoding image :\(error.localizedDescription)")
            } else {
                //appending it to list
                
                DispatchQueue.main.async {
                    cell.imageAd.kf.setImage(with: url!, placeholder: UIImage(named: "ImgPlaceholder"))
                }
                
            }
        }
        
        
        cell.displayAnnotations()
        
        return cell
    }
    
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
}
