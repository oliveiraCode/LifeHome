//
//  MyAdCell.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-01.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit

//This code was inspired from https://www.youtube.com/watch?v=owwLP7GMDf8
class MyAdCell: UITableViewCell {

    
    @IBOutlet weak var lbCreatedOn: UILabel!
    @IBOutlet weak var imgAd: UIImageView!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbTypeOfProperty: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var lbCity: UILabel!
    @IBOutlet weak var lbDistance: UILabel!
    @IBOutlet weak var lbBathroom: UILabel!
    @IBOutlet weak var lbBedroom: UILabel!
    @IBOutlet weak var lbGarage: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    
}
