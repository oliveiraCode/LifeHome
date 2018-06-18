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
    let uid = Auth.auth().currentUser?.uid //get the current uid
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        sideMenus()

        let nibName = UINib(nibName: "MyAdCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myCell")
        
        loadData()
 
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBadgeValue()
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

        
        cell.lbAddress.text = self.appDelegate.wishlistAd[indexPath.row].address?.street
        cell.lbCity.text = self.appDelegate.wishlistAd[indexPath.row].address?.city
        cell.imgAd.image = self.appDelegate.wishlistAd[indexPath.row].image
        cell.lbBedroom.text = String(self.appDelegate.wishlistAd[indexPath.row].bedroom!)
        cell.lbBathroom.text = String(self.appDelegate.wishlistAd[indexPath.row].bathroom!)
        cell.lbTypeOfProperty.text = String(self.appDelegate.wishlistAd[indexPath.row].typeOfProperty!)
        cell.lbGarage.text = String(self.appDelegate.wishlistAd[indexPath.row].garage!)
        cell.lbPrice.text = String(format: "CAD %.2f",self.appDelegate.wishlistAd[indexPath.row].price!)
        
        if UserDefaults.standard.bool(forKey: "miles"){
            if (self.appDelegate.wishlistAd[indexPath.row].address?.longitude) != nil {
                cell.lbDistance.text = String(format:"%.2f mi ",self.calculateDistanceMi(lat: (self.appDelegate.wishlistAd[indexPath.row].address?.latitude)!, long: (self.appDelegate.wishlistAd[indexPath.row].address?.longitude)!))
            }
        } else if (self.appDelegate.wishlistAd[indexPath.row].address?.longitude) != nil {
            cell.lbDistance.text = String(format:"%.2f km ",self.calculateDistanceKm(lat: (self.appDelegate.wishlistAd[indexPath.row].address?.latitude)!, long: (self.appDelegate.wishlistAd[indexPath.row].address?.longitude)!))
        }
        
        return cell
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //User Defaults
        if editingStyle == .delete {
            // Delete the row from the data source
            self.tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
    
            
            self.ref.child("Wishlist").child(self.uid!).child(self.appDelegate.wishlistAd[indexPath.row].id!).setValue(nil)
        
            self.appDelegate.wishlistAd.remove(at: indexPath.row)
            
            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
        
    }
    

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
    
    
    func loadData (){
        
        let ref: DatabaseReference = Database.database().reference()
        
        ref.child("Wishlist").observe(.value) { (snapshot) in
            self.appDelegate.wishlistAd.removeAll() //remove all values before get more from firebase
            
            for userId in snapshot.children.allObjects as! [DataSnapshot] {
                for adId in userId.children.allObjects as! [DataSnapshot] {
                    
                    let adObj = Ad()
                    guard let adDict = adId.value as? [String: Any] else { continue }
                    
                    let storageRef = Storage.storage().reference(forURL: adDict["imageURL"]! as! String)
                    storageRef.downloadURL(completion: { (urls, error) in
                        
                        guard let url = urls else {return}
                        do {
                            let data = try Data(contentsOf: url)
                            adObj.imgUrl = url.absoluteString
                            adObj.image = UIImage(data: data as Data)
                            self.tableView.reloadData()
                        } catch {
                            print("Error: \(error.localizedDescription)")
                        }
                        
                    })
                    
                    adObj.id = adId.key
                    adObj.bedroom = adDict["bedroom"] as? Int
                    adObj.garage = adDict["garage"] as? Int
                    adObj.bathroom = adDict["bathroom"] as? Int
                    adObj.price = adDict["price"] as? Float
                    adObj.description = adDict["description"]! as? String
                    adObj.typeOfProperty = adDict["typeOfProperty"]! as? String
                    
                    
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
                    DispatchQueue.main.async {
                        self.updateBadgeValue()
                    }
                    self.tableView.reloadData()
                    
                }
            }
        }
        
        

        
    }
    
    func updateBadgeValue(){
        if UserDefaults.standard.bool(forKey: "wishlistNotification") {
            //to put the badgeValue count from wishlist array
            tabBarController?.tabBar.items?.last?.badgeValue = "\(self.appDelegate.wishlistAd.count)"
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
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        //setting this view controller to be responsible of Managing the locations
        locationManager.delegate = self
        //we want the best accurancy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //we want location service to on all the time
        locationManager.requestAlwaysAuthorization()
        
        //Check if user authorized the use of location services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        appDelegate.myCurrentLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        manager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error \(error)")
    }


    
}
