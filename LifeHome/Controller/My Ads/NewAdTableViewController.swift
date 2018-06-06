//
//  NewAdTableViewController.swift
//  LifeHome
//
//  Created by Leandro Oliveira on 2018-05-29.
//  Copyright © 2018 Leandro Oliveira. All rights reserved.
//

import UIKit
import Photos


class NewAdTableViewController: UITableViewController,ImagePickerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let adObj = Ad()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeTitleNavigatorBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        let nibName = UINib(nibName: "MyNewAdCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "myNewAdCell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveAd))
        


    }
    

    //NotificationCenter was inspired from https://stackoverflow.com/questions/38204703/notificationcenter-issue-on-swift-3
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //to call the TableViewController TypeOfProperty
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(openTypeOfPropertyVC), name: NSNotification.Name(rawValue: "openTypeOfPropertyVC"), object: nil)
        
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "openTypeOfPropertyVC"), object: nil)
    }
    
    //to call the TableViewController TypeOfProperty
    @objc func openTypeOfPropertyVC(){
        self.performSegue(withIdentifier: "showTypeOfPropertyVC", sender: nil)
    }
    
    
    @objc func saveAd(){
  
     let indexPath : NSIndexPath = NSIndexPath(row: 0, section: 0) //Create the indexpath to get the cell
     let cell : MyNewAdCell = self.tableView.cellForRow(at: indexPath as IndexPath) as! MyNewAdCell
            
     
   //  print(cell.tfStreet.text!)
   //  print(cell.tfCity.text!)

        
      //  adObj.imageURL = cell.imgAd.image
        
        if cell.segTypeOfAd.selectedSegmentIndex == 0 {
            adObj.typeOfAd = TypeOfAd.Rent
        } else {
            adObj.typeOfAd = TypeOfAd.Sell
        }
        
        adObj.typeOfProperty = cell.btnTypeOfProperty.titleLabel?.text
        
        
        adObj.bedroom = NSString(string: cell.lbBedroom.text!).integerValue
        adObj.bathroom = NSString(string: cell.lbBathroom.text!).integerValue
        adObj.garage = NSString(string: cell.lbGarage.text!).integerValue
        adObj.price = NSString(string: cell.tfPrice.text!).floatValue
        
        
        
        adObj.description = cell.tvDescription.text
        
        let addressObj = Address()
        addressObj.street = cell.tfStreet.text!
        addressObj.province = cell.tfProvince.text!
        addressObj.city = cell.tfCity.text!
        addressObj.postalCode = cell.tfPostalCode.text!
        
        adObj.address = addressObj
        
        print(adObj.bedroom!)
        print(addressObj.province!)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return 1
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myNewAdCell", for: indexPath) as! MyNewAdCell

          cell.btnTypeOfProperty.setTitle(appDelegate.arrayTypeOfProperty[appDelegate.selectedRow], for: .normal)

        cell.delegate = self
        
        return cell
        
    }
    
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        
       
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func changeTitleNavigatorBar(){
        let logo = UIImage(named: "logoTitle")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    

}

extension NewAdTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let cell = tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! MyNewAdCell
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            cell.imgAd.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}
