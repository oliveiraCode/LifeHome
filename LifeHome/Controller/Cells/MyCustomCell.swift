//
//  MyCustomCell.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-01.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit

//This code was inspired from https://www.youtube.com/watch?v=owwLP7GMDf8
class MyCustomCell: UITableViewCell {

    
    @IBOutlet weak var imgAd: UIImageView!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbTypeOfProperty: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbCity: UILabel!
    @IBOutlet weak var lbDistance: UILabel!
    @IBOutlet weak var lbBathroom: UILabel!
    @IBOutlet weak var lbBedroom: UILabel!
    @IBOutlet weak var lbFloor: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(imgAd:String, lbPrice:String, lbTypeOfProperty:String, lbAddress:String, lbCity:String, lbDistance:String, lbBathroom:String, lbBedroom:String, lbFloor:String){
        self.imgAd.image = UIImage(named: imgAd)
        self.lbPrice.text = lbPrice
        self.lbTypeOfProperty.text = lbTypeOfProperty
        self.lbAddress.text = lbAddress
        self.lbCity.text = lbCity
        self.lbDistance.text = lbDistance
        self.lbBathroom.text = lbBathroom
        self.lbBedroom.text = lbBedroom
        self.lbFloor.text = lbFloor
    }
    
    
}
