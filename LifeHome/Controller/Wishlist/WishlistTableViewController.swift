//
//  FavoritesTableViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-28.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import SWRevealViewController

class WishlistTableViewController: UITableViewController,CLLocationManagerDelegate {

    @IBOutlet weak var btnMenu: UIBarButtonItem!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference = Database.database().reference()
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        sideMenus()

        let nibName = UINib(nibName: "MyAdCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myCell")
        
        loadDataWishList()
 
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBadgeValue()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    //Hide header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 1.0 : 32
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.appDelegate.wishlistAd.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyAdCell

        if self.appDelegate.wishlistAd.count > 0 {
        cell.lbAddress.text = self.appDelegate.wishlistAd[indexPath.row].address?.street
        cell.lbCity.text = self.appDelegate.wishlistAd[indexPath.row].address?.city
        cell.imgAd.image = self.appDelegate.wishlistAd[indexPath.row].image
        cell.lbBedroom.text = String(self.appDelegate.wishlistAd[indexPath.row].bedroom!)
        cell.lbBathroom.text = String(self.appDelegate.wishlistAd[indexPath.row].bathroom!)
        cell.lbTypeOfProperty.text = self.appDelegate.wishlistAd[indexPath.row].typeOfProperty?.rawValue
        cell.lbGarage.text = String(self.appDelegate.wishlistAd[indexPath.row].garage!)
        cell.lbPrice.text = String(format: "CAD %.2f",self.appDelegate.wishlistAd[indexPath.row].price!)
        
        if UserDefaults.standard.bool(forKey: "miles"){
            if (self.appDelegate.wishlistAd[indexPath.row].address?.longitude) != nil {
                cell.lbDistance.text = String(format:"%.2f mi ",self.calculateDistanceMi(lat: (self.appDelegate.wishlistAd[indexPath.row].address?.latitude)!, long: (self.appDelegate.wishlistAd[indexPath.row].address?.longitude)!))
            }
        } else if (self.appDelegate.wishlistAd[indexPath.row].address?.longitude) != nil {
            cell.lbDistance.text = String(format:"%.2f km ",self.calculateDistanceKm(lat: (self.appDelegate.wishlistAd[indexPath.row].address?.latitude)!, long: (self.appDelegate.wishlistAd[indexPath.row].address?.longitude)!))
        }
            
            if self.appDelegate.wishlistAd[indexPath.row].image != nil {
                cell.imgAd.image = self.appDelegate.wishlistAd[indexPath.row].image
            } else {
                cell.imgAd.image = UIImage(named: "ImgPlaceholder")
                let imageRef = Storage.storage().reference().child("ImageAds").child(self.appDelegate.wishlistAd[indexPath.row].imageStorage!)
                
                // get the download URL
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("error download image :\(error.localizedDescription)")
                    } else {
                        //appending it to list
                        DispatchQueue.main.async {
                            cell.imgAd.kf.setImage(with: url!)
                        }
                        self.appDelegate.currentListAds[indexPath.row].image = cell.imgAd.image
                    }
                }
            }
            
            
            
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.detailAd.removeAll()
        appDelegate.detailAd.append(appDelegate.wishlistAd[indexPath.row])
        performSegue(withIdentifier: "showWishlistDetailVC", sender: nil)
    }
    
    func calculateDistanceKm(lat: Double, long: Double) -> Double{
        let adLocation = CLLocation(latitude: lat, longitude: long)
        let distanceKm = appDelegate.myCurrentLocation.distance(from: adLocation)/1000
        return distanceKm
    }
    
    func calculateDistanceMi(lat: Double, long: Double) -> Double{
        let distanceKm = calculateDistanceKm(lat: lat, long: long)
        let distanceMi = distanceKm/1.6
        return distanceMi
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete Wishlist", style: .destructive, handler: { action in
            
            //User Defaults
            if editingStyle == .delete {
                // Delete the row from the data source
                self.tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.ref.child("Wishlist").child(uid).child(self.appDelegate.wishlistAd[indexPath.row].id!).setValue(nil)
                
                self.appDelegate.wishlistAd.remove(at: indexPath.row)
                
                self.tableView.endUpdates()
                self.updateBadgeValue()
            }
            
            
        }))

        self.present(alert, animated: true)
 
    }
    

    
    
    func loadDataWishList (){
        
        
        
        let ref: DatabaseReference = Database.database().reference()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            self.appDelegate.wishlistAd.removeAll() //remove all values before get more from firebase
            return}
        
        ref.child("Wishlist").child(uid).observe(.value) { (snapshot) in
            
            self.appDelegate.wishlistAd.removeAll() //remove all values before get more from firebase
            
                for adId in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    let adObj = Ad()
                    guard let adDict = adId.value as? [String: Any] else { continue }
                    
                    
                    adObj.id = adId.key
                    adObj.bedroom = adDict["bedroom"] as? Int
                    adObj.garage = adDict["garage"] as? Int
                    adObj.bathroom = adDict["bathroom"] as? Int
                    adObj.price = adDict["price"] as? Float
                    adObj.description = adDict["description"]! as? String
                    
                    switch adDict["typeOfProperty"]! as? String {
                    case "House":
                        adObj.typeOfProperty = .House
                        break
                    case "Townhouse":
                        adObj.typeOfProperty = .Townhouse
                        break
                    case "Apartment":
                        adObj.typeOfProperty = .Apartment
                        break
                    case "Duplex":
                        adObj.typeOfProperty = .Duplex
                        break
                    case "Triplex":
                        adObj.typeOfProperty = .Triplex
                        break
                    case "Fourplex":
                        adObj.typeOfProperty = .Fourplex
                        break
                    case "Other":
                        adObj.typeOfProperty = .Other
                        break
                    default:
                        print("default")
                    }
                    
                    adObj.creationDate = adDict["creationDate"]! as? String
                    adObj.imageStorage = adDict["imageStorage"]! as? String
                    
                    if (adDict["typeOfAd"]! as! String) == "Sell" {
                        adObj.typeOfAd = .Sell
                    } else {
                        adObj.typeOfAd = .Rent
                    }
                    
                    guard let addressDict = adDict["Address"] as? [String: Any] else { continue }
                    let addressObj = Address()
                    addressObj.city = addressDict["city"] as? String
                    addressObj.postalCode = addressDict["postal code"] as? String
                    addressObj.province = addressDict["province"] as? String
                    addressObj.street = addressDict["street"] as? String
                    addressObj.latitude = addressDict["latitude"] as? Double
                    addressObj.longitude = addressDict["longitude"] as? Double
                    
                    adObj.address = addressObj
                    
                    guard let contactDict = adDict["Contact"] as? [String: Any] else { continue }
                    let contactObj = Contact()
                    contactObj.email = contactDict["email"] as? String
                    contactObj.phone = contactDict["phone"] as? String
                    
                    adObj.contact = contactObj
                    
                    
                    //Call the copmletion handler that was passed to us
                    self.appDelegate.wishlistAd.append(adObj)
                    self.updateBadgeValue()
                    
                }
            }
        
    }
    
    
    func updateBadgeValue(){
        
        DispatchQueue.main.async {
            
            if UserDefaults.standard.bool(forKey: "wishlistNotification") {
                //to put the badgeValue count from wishlist array
                self.tabBarController?.tabBar.items?.last?.badgeValue = "\(self.appDelegate.wishlistAd.count)"
            }
            
            self.tableView.reloadData()
        }
        
        
    }
    
    
    func sideMenus() {
        
        if revealViewController() != nil {
            self.btnMenu.target = revealViewController()
            self.btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    



    
}
