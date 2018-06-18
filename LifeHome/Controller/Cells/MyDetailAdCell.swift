//
//  MyDetailAdCell.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-18.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import MapKit

class MyDetailAdCell: UITableViewCell {

    
    @IBOutlet weak var btnWishlist: UIButton!
    @IBOutlet weak var imageAd: UIImageView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var lbPhone: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var lbBedroom: UILabel!
    @IBOutlet weak var lbBathroom: UILabel!
    @IBOutlet weak var lbGarage: UILabel!
    @IBOutlet weak var lbAddress2: UILabel!
    @IBOutlet weak var lbAddress1: UILabel!
    @IBOutlet weak var lbTypeOfAd: UILabel!
    @IBOutlet weak var lbTypeOfProperty: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
        // Configure the view for the selected state
    }
    
    @IBAction func btnWishlist(_ sender: Any) {
         NotificationCenter.default.post(name: Notification.Name("saveWishlist"), object: nil)
    }
    
    
    
    
}
