//
//  FindViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-24.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SWRevealViewController

class MapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        sideMenus()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        callLocationServices()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        appDelegate.myCurrentLocation = locations[0] as CLLocation
        
        //Radius in Meters
        let regionRadius: CLLocationDistance = 20000
        
        //Define Region
        let coordinateRegion: MKCoordinateRegion!
        
        //Create a Map region
        coordinateRegion = MKCoordinateRegionMakeWithDistance(appDelegate.myCurrentLocation.coordinate,regionRadius, regionRadius)
        
        
        //set mapView to the region specified
        map.setRegion(coordinateRegion, animated: true)
        self.map.showsUserLocation = true
        self.locationManager.stopUpdatingLocation() //para a atualizacao da localizacao atual
        
        //Displaying all Stores Pins ( annotations)
        displayAnnotations(listAllAds: self.appDelegate.listAllAds)
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("notDetermined")
            break
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            break
        case .authorizedAlways:
            print("authorizedAlways")
            break
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        }
    }
    
    func callLocationServices(){
        //setting this view controller to be responsible of Managing the locations
        self.locationManager.delegate = self
        
        //we want the best accurancy
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //we want location service to on all the time
        self.locationManager.requestAlwaysAuthorization()
        
        //Check if user authorized the use of location services
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startUpdatingLocation()
        }
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        self.map.selectAnnotation(annotation!, animated: true)
    }
    
    
    func displayAnnotations(listAllAds:[Ad]){
        for item in self.appDelegate.listAllAds {
            let adObj : Ad = item
            let adLocation = CLLocationCoordinate2D(latitude: (adObj.address?.latitude)!, longitude: (adObj.address?.longitude)!)
            let aTitle = "\(adObj.typeOfProperty!)"
            let aSubtitle =  String(format: "CAD %.2f", adObj.price!)
            
            let adAnnotation = AdAnnotation(title: aTitle, subtitle: aSubtitle, coordinate: adLocation)
            
            
            self.map.addAnnotation(adAnnotation)
            self.map.selectAnnotation(adAnnotation, animated: true)
            
        }
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
    
    
    
}
