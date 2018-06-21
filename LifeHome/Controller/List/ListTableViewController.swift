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


class ListTableViewController: UITableViewController,CLLocationManagerDelegate,UISearchBarDelegate,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var listAds:[Ad] = []
    var locationManager:CLLocationManager!
    let arrayOrderBy:[String] = ["Distance", "Price: low to hight", "Price: hight to low"]
    var selectedRow:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        sideMenus()
        
        let nibName = UINib(nibName: "MyAdCell", bundle: nil)
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
        
        //get all Ads data from Firebase
        loadDataAllAds()
        
        setUpSearchBar()
        
    }
    
    private func setUpSearchBar() {
        searchBar.delegate = self
    }
    
    
    //these 3 func were inspired from https://stackoverflow.com/questions/34692277/how-to-exit-from-the-search-on-clicking-on-cancel-button
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.searchBar(searchBar, textDidChange: "")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        appDelegate.currentListAds = listAds.filter({ Ads -> Bool in
            if searchText.isEmpty { return true }
            return (Ads.address?.city!.lowercased().contains(searchText.lowercased()))!
        })
        
        self.tableView.reloadData()
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
        return self.appDelegate.currentListAds.count
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.detailAd.removeAll()
        appDelegate.detailAd.append(appDelegate.currentListAds[indexPath.row])
        performSegue(withIdentifier: "showListDetailVC", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyAdCell
        
        
        cell.lbAddress.text = self.appDelegate.currentListAds[indexPath.row].address?.street
        cell.lbCity.text = self.appDelegate.currentListAds[indexPath.row].address?.city
        cell.imgAd.image = self.appDelegate.currentListAds[indexPath.row].image
        cell.lbBedroom.text = String(self.appDelegate.currentListAds[indexPath.row].bedroom!)
        cell.lbBathroom.text = String(self.appDelegate.currentListAds[indexPath.row].bathroom!)
        cell.lbTypeOfProperty.text = String(self.appDelegate.currentListAds[indexPath.row].typeOfProperty!)
        cell.lbGarage.text = String(self.appDelegate.currentListAds[indexPath.row].garage!)
        cell.lbPrice.text = String(format: "CAD %.2f",self.appDelegate.currentListAds[indexPath.row].price!)
        
        if UserDefaults.standard.bool(forKey: "miles"){
            if (self.appDelegate.currentListAds[indexPath.row].address?.longitude) != nil {
                cell.lbDistance.text = String(format:"%.2f mi ",self.calculateDistanceMi(lat: (self.appDelegate.currentListAds[indexPath.row].address?.latitude)!, long: (self.appDelegate.currentListAds[indexPath.row].address?.longitude)!))
            }
        } else if (self.appDelegate.currentListAds[indexPath.row].address?.longitude) != nil {
            cell.lbDistance.text = String(format:"%.2f km ",self.calculateDistanceKm(lat: (self.appDelegate.currentListAds[indexPath.row].address?.latitude)!, long: (self.appDelegate.currentListAds[indexPath.row].address?.longitude)!))
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
    
    
    func loadDataAllAds (){
        
        let ref: DatabaseReference = Database.database().reference()
        
        ref.child("Ad").observe(.value) { (snapshot) in
            
            self.appDelegate.currentListAds.removeAll() //remove all values before get more from firebase
            self.listAds.removeAll()
            
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
                    self.appDelegate.currentListAds.append(adObj)
                    self.listAds.append(adObj)
                    self.tableView.reloadData()
                    
                }
            }
        }
        
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
    
    @IBAction func btnOrderBy(_ sender: Any) {
        
        //inspired from https://stackoverflow.com/questions/40190629/swift-uialertcontroller-with-pickerview-button-action-stay-up
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 200)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 350, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        vc.view.addSubview(pickerView)
        let alert = UIAlertController(title: "Order by", message: nil, preferredStyle: .actionSheet)
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Apply", style: .default, handler: { action in
            
            switch self.selectedRow {
            case 0 :
                break
            case 1 :
                self.sortByPrice(type: "LowtoHight")
                break
            case 2 :
                self.sortByPrice(type: "HighttoLow")
                break
            default:
                print("default")
                break
            }
            
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
        
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrayOrderBy.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrayOrderBy[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       selectedRow = row
    }
    
    func sortByPrice (type:String){
        if type == "LowtoHight" {
            self.appDelegate.currentListAds = self.appDelegate.currentListAds.sorted{
                $0.price! < $1.price!
            }
        } else {
            self.appDelegate.currentListAds = self.appDelegate.currentListAds.sorted{
                $0.price! > $1.price!
            }
        }
        
    }
    
    
}
