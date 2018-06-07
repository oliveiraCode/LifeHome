//
//  MyNewAdCell.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-06-04.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit

protocol ImagePickerDelegate {
    
    func pickImage()
}

class MyNewAdCell: UITableViewCell {

    
    @IBOutlet weak var imgAd: UIImageView!
    @IBOutlet weak var segTypeOfAd: UISegmentedControl!
    @IBOutlet weak var btnTypeOfProperty: UIButton!
    @IBOutlet weak var lbBedroom: UILabel!
    @IBOutlet weak var lbBathroom: UILabel!
    @IBOutlet weak var lbGarage: UILabel!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tvDescription: UITextView!
    @IBOutlet weak var tfStreet: UITextField!
    @IBOutlet weak var tfPostalCode: UITextField!
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var tfProvince: UITextField!
    
    
    var delegate : ImagePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgAd.isUserInteractionEnabled = true
        imgAd.clipsToBounds = true
        imgAd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openImagePicker)))
        
    }

    @objc func openImagePicker(){
        delegate?.pickImage()
    }

  
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func stepperBedroom(_ sender: UIStepper) {
        self.lbBedroom.text = "\(Int(sender.value))"
        
    }
    
    @IBAction func stepperBathroom(_ sender: UIStepper) {
        self.lbBathroom.text = "\(Int(sender.value))"
    }
    
    @IBAction func stepperGarage(_ sender: UIStepper) {
        self.lbGarage.text = "\(Int(sender.value))"
    }
    
    
    @IBAction func btnTypeOfPropertyPressed(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("openTypeOfPropertyVC"), object: nil)
        
    }
    
    
    
}


