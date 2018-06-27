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

class MyNewAdCell: UITableViewCell, UITextViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPhone: UITextField!
    
    var delegate : ImagePickerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgAd.isUserInteractionEnabled = true
        imgAd.clipsToBounds = true
        imgAd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openImagePicker)))
        
        
        setupLayout()
   
    }
    
    
    func setupLayout(){
        //this code was inspired from https://stackoverflow.com/questions/27652227/text-view-placeholder-swift
        //to put placeholder into TextView, the textViewDidBeginEditing and textViewDidEndEditing must be implemented together.
        tvDescription.delegate = self
        tvDescription.text = "Type here your description"
        tvDescription.textColor = UIColor.lightGray
        
        
        //to make a border on TextView
        tvDescription.layer.borderWidth = 0.6
        tvDescription.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if tvDescription.textColor == UIColor.lightGray {
            tvDescription.text = nil
            tvDescription.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if tvDescription.text.isEmpty {
            tvDescription.text = "Type here your description"
            tvDescription.textColor = UIColor.lightGray
        }
    }
    
    @objc func openImagePicker(){
        delegate?.pickImage()
    }

    
    @IBAction func switchPressed(_ sender: UISwitch) {
        
        if sender.isOn {
             tfEmail.text = appDelegate.userObj.email
            tfPhone.text = appDelegate.userObj.phone
            tfEmail.isEnabled = false
            tfPhone.isEnabled = false
        } else {
            tfEmail.isEnabled = true
            tfPhone.isEnabled = true
            tfEmail.text = ""
            tfPhone.text = ""
        }
        
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


