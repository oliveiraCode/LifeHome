//
//  AboutViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-04.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import SWRevealViewController

class AboutViewController: UIViewController {
    
    @IBOutlet weak var viewAbout: UIView! {
        didSet { //create the object already configured.
            viewAbout.layer.cornerRadius = 9
            viewAbout.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var btnMenu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()
        sideMenus()
    }
    
    
    //MARK - Setup ViewController
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    //MARK - SideMenu Method
    func sideMenus() {
        if revealViewController() != nil {
            
            self.btnMenu.target = revealViewController()
            self.btnMenu.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
}
