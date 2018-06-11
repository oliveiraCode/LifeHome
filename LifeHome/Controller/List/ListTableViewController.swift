//
//  FindTableViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-24.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase
import SWRevealViewController
import CoreLocation
import KRActivityIndicatorView

class ListTableViewController: UITableViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var locationManager:CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        sideMenus()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let nibName = UINib(nibName: "MyCustomCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myCell")
        
        
        //this code was inspired from Hakim
        if ((Auth.auth().currentUser?.uid) == nil && !UserDefaults.standard.bool(forKey: "ContinueWithoutAnAccount")){
            let offset = 0.1
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(offset * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let loginView = storyBoard.instantiateViewController(withIdentifier: "LoginViewController")
                self.tabBarController?.present(loginView, animated: true, completion: nil)
                
            })
        }
        

        //get all data from Firebase
        loadData()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.appDelegate.listAllAds.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCustomCell
        
        cell.lbAddress.text = self.appDelegate.listAllAds[indexPath.row].address?.street
        cell.lbCity.text = self.appDelegate.listAllAds[indexPath.row].address?.city
        cell.imgAd.image = self.appDelegate.listAllAds[indexPath.row].imageURL
        cell.lbBedroom.text = String(self.appDelegate.listAllAds[indexPath.row].bedroom!)
        cell.lbBathroom.text = String(self.appDelegate.listAllAds[indexPath.row].bathroom!)
        cell.lbTypeOfProperty.text = String(self.appDelegate.listAllAds[indexPath.row].typeOfProperty!)
        cell.lbGarage.text = String(self.appDelegate.listAllAds[indexPath.row].garage!)
        cell.lbPrice.text = String(format: "CAD %.2f",self.appDelegate.listAllAds[indexPath.row].price!)
        
        if (self.appDelegate.listAllAds[indexPath.row].address?.longitude) != nil {
            cell.lbDistance.text = String(format:"%.1f km ",self.calculateDistance(lat: (self.appDelegate.listAllAds[indexPath.row].address?.latitude)!, long: (self.appDelegate.listAllAds[indexPath.row].address?.longitude)!))

        }
 
        return cell
    }

    
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
    
    
    func loadData (){
    
        self.appDelegate.listAllAds.removeAll()
        let ref: DatabaseReference = Database.database().reference()
        
        ref.child("Ad").observe(.value, with:
            { (snapshot) in
                
                for userId in snapshot.children.allObjects as! [DataSnapshot] {
                    
                    for adId in userId.children.allObjects as! [DataSnapshot] {
                        
                        
                        let adObj = Ad()
                        
                        guard let adDict = adId.value as? [String: Any] else { continue }
                        
                        
                        let storageRef = Storage.storage().reference(forURL: adDict["imageURL"]! as! String)
                        storageRef.downloadURL(completion: { (urls, error) in
                            
                            guard let url = urls else {return}
                            
                            do {
                                let data = try Data(contentsOf: url)
                                DispatchQueue.main.async {
                                    adObj.imageURL = UIImage(data: data as Data)
                                    self.tableView.reloadData()
                                }
                                
                            } catch {
                                print("Error: \(error.localizedDescription)")
                            }
                            
                        })
                        
                        
                        
                        
                        
                        
                        
                        adObj.bedroom = Int(adDict["bedroom"]! as! String)
                        adObj.garage = Int(adDict["garage"]! as! String)
                        adObj.bathroom = Int(adDict["bathroom"]! as! String)
                        adObj.price = Float(adDict["price"]! as! String)
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
                        
            
                        
                        
                        let address = "\(addressObj.street!), \(addressObj.city!), \(addressObj.province!) \(addressObj.postalCode!)"
                        
                        
                        let geoCoder = CLGeocoder()
                        geoCoder.geocodeAddressString(address) { (placemarks, error) in
                            guard
                                let placemarks = placemarks,
                                let location = placemarks.first?.location
                           
                                else {
                                    // handle no location found
                                    return
                            }
                            
                            addressObj.latitude = location.coordinate.latitude
                            addressObj.longitude = location.coordinate.longitude
                            
                        }
                        
                        
                        
                        adObj.address = addressObj
                        
                        //Call the copmletion handler that was passed to us
                        
                        self.appDelegate.listAllAds.append(adObj)
                        
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    }
                }
        })

    }
    
    
    func calculateDistance(lat: Double, long: Double) -> Double{
        let adLocation = CLLocation(latitude: lat, longitude: long)
       let distanceKm = appDelegate.myCurrentLocation.distance(from: adLocation)/1000
        return distanceKm
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
        
        print("user latitude = \(appDelegate.myCurrentLocation.coordinate.latitude)")
        print("user longitude = \(appDelegate.myCurrentLocation.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Error \(error)")
    }
    
    
}
