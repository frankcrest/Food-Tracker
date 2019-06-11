//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 10/17/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  //MARK: Properties
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var ratingControl: RatingControl!
  @IBOutlet weak var saveButton: UIBarButtonItem!
  @IBOutlet weak var mealDescriptionTextField: UITextField!
  @IBOutlet weak var mealCaloriesTextField: UITextField!
  let ud = UserDefaults.standard
  var authentificationStatus = false
  var imageLink:String?
  /*
   This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
   or constructed as part of adding a new meal.
   */
  let cloudTracker = CloudTrackerNetworker()
  var meal: Meal?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Handle the text field’s user input through delegate callbacks.
    nameTextField.delegate = self
    mealDescriptionTextField.delegate = self
    mealCaloriesTextField.delegate = self
    
    // Set up views if editing an existing Meal.
    if let meal = meal {
      navigationItem.title = meal.title
      nameTextField.text = meal.mealDescription
      //photoImageView.image = meal.photo
      guard let ratingInt = meal.rating else {return}
      ratingControl.rating = ratingInt
    }
    
    // Enable the Save button only if the text field has a valid Meal name.
    saveButton.isEnabled = false
  }
  
  //MARK: UITextFieldDelegate
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // Disable the Save button while editing.
    saveButton.isEnabled = false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // Hide the keyboard.
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    updateSaveButtonState()
    navigationItem.title = textField.text
  }
  
  //MARK: UIImagePickerControllerDelegate
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    // Dismiss the picker if the user canceled.
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
    // The info dictionary may contain multiple representations of the image. You want to use the original.
    guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    }
    
    cloudTracker.postToImgur(image: selectedImage) { (data, error, response) -> (Void) in
      if error != nil || data == nil{
        print("client error")
        return
      }
      do{
        guard let dataToUse = data else{return}
        let json = try JSONSerialization.jsonObject(with: dataToUse, options: []) as? [String:AnyObject]
        guard let jsonToUse = json else{return}
        guard let data = jsonToUse["data"] else{return}
        let link = data["link"] as? String
        guard let linkString = link else{return}
        self.imageLink = linkString
        print(linkString)
      }catch let error{
        print(error)
      }
    }
    
    // Set photoImageView to display the selected image.
    photoImageView.image = selectedImage
    
    // Dismiss the picker.
    dismiss(animated: true, completion: nil)
  }
  
  //MARK: Navigation
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
    let isPresentingInAddMealMode = presentingViewController is UINavigationController
    
    if isPresentingInAddMealMode {
      dismiss(animated: true, completion: nil)
    }
    else if let owningNavigationController = navigationController{
      owningNavigationController.popViewController(animated: true)
    }
    else {
      fatalError("The MealViewController is not inside a navigation controller.")
    }
  }
  
  // This method lets you configure a view controller before it's presented.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    super.prepare(for: segue, sender: sender)
    
    // Configure the destination view controller only when the save button is pressed.
    guard let button = sender as? UIBarButtonItem, button === saveButton else {
      os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
      return
    }
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if authentificationStatus == false{
      return false
    }
    return true
  }
  
  //MARK: Actions
  @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
    
    // Hide the keyboard.
    nameTextField.resignFirstResponder()
    
    // UIImagePickerController is a view controller that lets a user pick media from their photo library.
    let imagePickerController = UIImagePickerController()
    
    // Only allow photos to be picked, not taken.
    imagePickerController.sourceType = .photoLibrary
    
    // Make sure ViewController is notified when the user picks an image.
    imagePickerController.delegate = self
    present(imagePickerController, animated: true, completion: nil)
  }
  
  @IBAction func saveMealTapped(_ sender: UIBarButtonItem) {
    guard let _ = self.imageLink else{return}
    let parameter = ["title":nameTextField.text,"calories":mealCaloriesTextField.text, "description":mealDescriptionTextField.text,"imagePath":self.imageLink] as [String:AnyObject]
    cloudTracker.post(data: parameter, toEndpoint: "users/me/meals", token: ud.string(forKey: "token")) { (data, error, response) -> (Void) in
      
      if error != nil || data == nil{
        print("client error")
        return
      }
      
      do {
        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
        if json == nil{
        }else{
          guard let dict = json!["meal"] as? [String:AnyObject] else{return}
          print(dict)
          self.meal = Meal(id: dict["id"] as! Int, title: dict["title"] as! String, mealDescription: dict["description"] as! String, calories: dict["calories"] as! Int, imagePath: dict["imagePath"] as? String, rating: dict["rating"] as? Int, user_id: dict["user_id"] as! Int)
          
          let parameter = ["rating":self.ratingControl.rating] as [String:AnyObject]
          guard let meal = self.meal else{return}
          self.cloudTracker.post(data: parameter, toEndpoint: "users/me/meals/\(meal.id)/rate", token: self.ud.string(forKey: "token"), completion: { (data, error, response) -> (Void) in
            
            if error != nil || data == nil{
              print("client error")
              return
            }
            do{
              let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
              if json == nil{
              }else{
                guard let dict = json!["meal"] as? [String:AnyObject] else{return}
                print(dict)
                self.authentificationStatus = true
                self.dismiss(animated: true, completion: nil)
                self.meal = Meal(id: dict["id"] as! Int, title: dict["title"] as! String, mealDescription: dict["description"] as! String, calories: dict["calories"] as! Int, imagePath: dict["imagePath"] as? String, rating: dict["rating"] as? Int, user_id: dict["user_id"] as! Int)
              }
            }catch let error{
              print(error)
            }
          })
        }
        print("The Response is : ",json as Any)
      } catch {
        print("JSON error: \(error.localizedDescription)")
      }
    }
  }
  //MARK: Private Methods
  
  private func updateSaveButtonState() {
    // Disable the Save button if the text field is empty.
    if nameTextField.text != "" && mealCaloriesTextField.text != "" && mealDescriptionTextField.text != ""{
      saveButton.isEnabled = true
    }
  }
  
}

