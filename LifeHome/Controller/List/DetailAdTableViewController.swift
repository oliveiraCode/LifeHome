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
    let uid = Auth.auth().currentUser?.uid //get the current uid
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
        
        self.tableView.reloadData() //to change the heart picture
        
        if isWishlist {
            saveData()
            
        } else {
            deleteData()
        }

    }
    
    func deleteData(){
        self.ref.child("Wishlist").child(self.uid!).child(self.appDelegate.detailAd[0].id!).setValue(nil)
    }
    
    func saveData(){
        var typeOfAd:String?
        
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
        
        if self.appDelegate.detailAd[0].typeOfAd == TypeOfAd.Rent{
            typeOfAd = "Rent"
        } else {
            typeOfAd = "Sell"
        }
        
        let adData = [
            "bathroom": self.appDelegate.detailAd[0].bathroom!,
            "bedroom": self.appDelegate.detailAd[0].bedroom!,
            "garage": self.appDelegate.detailAd[0].garage!,
            "description": self.appDelegate.detailAd[0].description!,
            "price": self.appDelegate.detailAd[0].price!,
            "typeOfAd": typeOfAd!,
            "typeOfProperty": self.appDelegate.detailAd[0].typeOfProperty!,
            "Address": addressData,
            "Contact": contactData,
            "imageURL": self.appDelegate.detailAd[0].imgUrl!
            ] as [String:Any]
        
        
        self.ref.child("Wishlist").child(self.uid!).child(self.appDelegate.detailAd[0].id!).setValue(adData)
        
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
        
        if self.appDelegate.detailAd[indexPath.row].typeOfAd == TypeOfAd.Sell {
            cell.lbTypeOfAd.text = "For Sell"
        } else {
            cell.lbTypeOfAd.text = "For Rent"
        }
        cell.lbTypeOfProperty.text = String(self.appDelegate.detailAd[indexPath.row].typeOfProperty!)
        cell.lbPrice.text = String(format: "CAD %.2f",self.appDelegate.detailAd[indexPath.row].price!)
        
        if isWishlist {
            cell.btnWishlist.setImage(UIImage(named: "wishlist_saved"), for: .normal)
            isWishlist = false
        } else {
            cell.btnWishlist.setImage(UIImage(named: "wishlist_unsaved"), for: .normal)
            isWishlist = true
        }
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
}
