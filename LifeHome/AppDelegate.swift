//
//  AppDelegate.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-24.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var currentListAds:[Ad] = []
    var detailAd:[Ad] = []
    var wishlistAd:[Ad] = []
    var selectedRow : Int = 0
    let arrayTypeOfProperty:[String] =
        ["Select...","House","Townhouse","Apartment","Duplex","Triplex","Fourplex","Other"]
    var myCurrentLocation:CLLocation!
    let userObj = User()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //change the default tint color.
        self.window!.tintColor = UIColor.init(red: 0/255, green: 111/255, blue: 173/255, alpha: 100)
        
        
        // Override point for customization after application launch.
        
        
        myCurrentLocation = CLLocation(latitude: 45.5016889, longitude: -73.56725599999999)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func getDataFromUser(){
        
        let userRef = Database.database().reference().child("users")
        
        userRef.child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                
                let users = snapshot.value as! [String:AnyObject]
                self.userObj.id = Auth.auth().currentUser?.uid
                self.userObj.email = users["email"] as! String
                self.userObj.phone = users["phone"] as! String
                self.userObj.username = users["username"] as! String
                let photoURL = users["photoURL"] as! String
                
                let storageRef = Storage.storage().reference(forURL: photoURL)
                storageRef.downloadURL(completion: { (url, error) in
                    
                    do {
                        let data = try Data(contentsOf: url!)
                        self.userObj.image = UIImage(data: data as Data)
                        NotificationCenter.default.post(name: Notification.Name("updateInfoUser"), object: nil)
                        
                    } catch {
                        print("error")
                    }
                    
                })
            }
        })
    }
    
    
    
    
}





