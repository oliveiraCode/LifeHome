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

class MapViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
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
        let currentLocation = locations[0] as CLLocation
        
        //Radius in Meters
        let regionRadius: CLLocationDistance = 7000
        
        //Define Region
        let coordinateRegion: MKCoordinateRegion!
        
        //Create a Map region
        coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate,regionRadius, regionRadius)
        
        
        //set mapView to the region specified
        map.setRegion(coordinateRegion, animated: true)
        self.map.showsUserLocation = true
        self.locationManager.stopUpdatingLocation() //para a atualizacao da localizacao atual
        
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
