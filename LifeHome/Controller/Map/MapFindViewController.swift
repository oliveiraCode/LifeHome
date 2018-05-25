//
//  FindViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-24.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit

class MapFindViewController: UIViewController {

    @IBOutlet weak var constraintChanged: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func segmentedPressed(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            constraintChanged.constant = 0
        }
        
        if sender.selectedSegmentIndex == 1 {
            constraintChanged.constant = -375
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
