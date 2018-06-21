//
//  MyAdsTableViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-28.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase
import SWRevealViewController
import CoreLocation

class MyAdsTableViewController: UITableViewController,CLLocationManagerDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ref: DatabaseReference = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid //get the current uid
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    var listMyAds:[Ad] = []
    
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        sideMenus()

        //Register cell classes
        let nibName = UINib(nibName: "MyAdCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myCell")
        
        loadDataMyAds()
    }

 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()

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
        return listMyAds.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyAdCell
        
        if listMyAds.count > 0 {
            cell.lbAddress.text = listMyAds[indexPath.row].address?.street
            cell.lbCity.text = listMyAds[indexPath.row].address?.city
            cell.imgAd.image = listMyAds[indexPath.row].image
            cell.lbBedroom.text = String(listMyAds[indexPath.row].bedroom!)
            cell.lbBathroom.text = String(listMyAds[indexPath.row].bathroom!)
            cell.lbTypeOfProperty.text = String(listMyAds[indexPath.row].typeOfProperty!)
            cell.lbGarage.text = String(listMyAds[indexPath.row].garage!)
            cell.lbPrice.text = String(format: "CAD %.2f",listMyAds[indexPath.row].price!)
            
            if UserDefaults.standard.bool(forKey: "miles"){
                if (listMyAds[indexPath.row].address?.longitude) != nil {
                    cell.lbDistance.text = String(format:"%.2f mi ",self.calculateDistanceMi(lat: (listMyAds[indexPath.row].address?.latitude)!, long: (listMyAds[indexPath.row].address?.longitude)!))
                }
            } else if (listMyAds[indexPath.row].address?.longitude) != nil {
                cell.lbDistance.text = String(format:"%.2f km ",self.calculateDistanceKm(lat: (listMyAds[indexPath.row].address?.latitude)!, long: (listMyAds[indexPath.row].address?.longitude)!))
            }
            
        }
        
        
        // Configure the cell...
        
        return cell
    }


    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        //User Defaults
        if editingStyle == .delete {
            // Delete the row from the data source
            self.tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
           
        self.ref.child("Ad").child(self.uid!).child(self.listMyAds[indexPath.row].id!).setValue(nil)

            self.listMyAds.remove(at: indexPath.row)

            self.tableView.endUpdates()
            self.tableView.reloadData()
        }
        
    }

    
    @IBAction func btnNewAd(_ sender: Any) {
        
        //Check if the user is logged before to show a new ad view controller
        if Auth.auth().currentUser?.uid == nil {
            let alert = UIAlertController(title: "Sign In", message: "You must sign in to create a new ad.", preferredStyle: UIAlertControllerStyle.actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { action in
            self.performSegue(withIdentifier: "showLoginVC", sender: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            appDelegate.selectedRow = 0 //to reset the type of property button
            performSegue(withIdentifier: "showNewAdVC", sender: nil)
        }
    }
    
    // put the logo into navigationBar
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    func sideMenus() {
        
        if revealViewController() != nil {
            
            self.btnMenu.target = revealViewController()
            self.btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    
    
    func loadDataMyAds (){

        let ref: DatabaseReference = Database.database().reference()
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        ref.child("Ad").child(uid).observe(.value, with:
            { (snapshot) in
                
                self.listMyAds.removeAll() //remove all values before get more from firebase
                
                    for adId in snapshot.children.allObjects as! [DataSnapshot] {
                        
                        
                        let adObj = Ad()
                        
                        guard let adDict = adId.value as? [String: Any] else { continue }
                        
                        
                        let storageRef = Storage.storage().reference(forURL: adDict["imageURL"]! as! String)
                        storageRef.downloadURL(completion: { (url, error) in
                            
                            do {
                                let data = try Data(contentsOf: url!)
                                    adObj.imgUrl = url!.absoluteString
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
                        

                        //Call the copmletion handler that was passed to us
                        
                        self.listMyAds.append(adObj)
                        self.tableView.reloadData()

                    }
                
        })
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
            //locationManager.startUpdatingHeading()
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
