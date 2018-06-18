//
//  SettingsViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-04.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import SWRevealViewController

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var imgWishlist: UIImageView!
    @IBOutlet weak var imgMiles: UIImageView!
    @IBOutlet weak var imgKilometers: UIImageView!
    @IBOutlet weak var viewDistance: UIView!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    var isWishList = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        sideMenus()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func btnWishlist(_ sender: UIButton) {
        changeImage(whichTag: sender.tag)
    }
    
    
    @IBAction func btnDistance(_ sender: UIButton) {
        changeImage(whichTag: sender.tag)
    }
    
    
    
    
    
    func changeImage(whichTag:Int){
        switch (whichTag){
        case 100:
            if isWishList {
                UserDefaults.standard.set(true, forKey: "wishlist")
                imgWishlist.image = UIImage(named: "check")
                isWishList = false
            } else {
                UserDefaults.standard.set(false, forKey: "wishlist")
                imgWishlist.image = UIImage(named: "uncheck")
                isWishList = true
            }
            break
        case 101:
            UserDefaults.standard.set(false, forKey: "miles")
            imgKilometers.image = UIImage(named: "check")
            imgMiles.image = UIImage(named: "uncheck")
            break
        case 102:
            UserDefaults.standard.set(true, forKey: "miles")
            imgKilometers.image = UIImage(named: "uncheck")
            imgMiles.image = UIImage(named: "check")
            break
        default:
            if UserDefaults.standard.bool(forKey: "miles") {
                imgKilometers.image = UIImage(named: "uncheck")
                imgMiles.image = UIImage(named: "check")
            } else {
                imgKilometers.image = UIImage(named: "check")
                imgMiles.image = UIImage(named: "uncheck")
            }
            break
        }
        
    }
    
    func setupLayout(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        viewDistance.layer.borderWidth = 0.5
        viewDistance.layer.borderColor = UIColor.init(red: 170/255, green: 170/255, blue: 170/255, alpha: 100).cgColor
        viewNotification.layer.borderColor = UIColor.init(red: 170/255, green: 170/255, blue: 170/255, alpha: 100).cgColor
        viewNotification.layer.borderWidth = 0.5
        
        changeImage(whichTag: 1)
        
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
