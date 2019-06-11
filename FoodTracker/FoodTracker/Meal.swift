//
//  Meal.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 11/10/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import os.log


class Meal: NSObject, NSCoding {
  
  //MARK: Properties
  
  var id:Int
  var title:String
  var mealDescription:String
  var calories:Int
  var imagePath:String?
  var rating:Int?
  var user_id:Int
  var image:UIImage?
  
  //MARK: Archiving Paths
  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
  
  //MARK: Types
  
  struct PropertyKey {
    static let id = "id"
    static let title = "title"
    static let mealDescription = "description"
    static let calories = "calories"
    static let imagePath = "imagePath"
    static let rating = "rating"
    static let user_id = "user_id"
  }
  
  //MARK: Initialization
  
  init?(id:Int, title:String, mealDescription:String, calories:Int,imagePath:String?, rating:Int?, user_id:Int) {
    
    self.id = id
    self.title = title
    self.mealDescription = mealDescription
    self.calories = calories
    
    if imagePath != nil{
      self.imagePath = imagePath!
    }
    
    if rating != nil{
      self.rating = rating!
    }
    
    self.user_id = user_id
  }
  
  //MARK: NSCoding
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(id, forKey: PropertyKey.id)
    aCoder.encode(title, forKey: PropertyKey.title)
    aCoder.encode(mealDescription, forKey: PropertyKey.mealDescription)
    aCoder.encode(calories, forKey: PropertyKey.calories)
    aCoder.encode(imagePath, forKey: PropertyKey.imagePath)
    aCoder.encode(rating, forKey: PropertyKey.rating)
    aCoder.encode(user_id, forKey: PropertyKey.user_id)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    
    // The name is required. If we cannot decode a name string, the initializer should fail.
    guard let id = aDecoder.decodeObject(forKey: PropertyKey.id) as? Int else {
      os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
      return nil
    }
    
    guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else{
      os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
      return nil
    }
    
    guard let mealDescription = aDecoder.decodeObject(forKey: PropertyKey.mealDescription) as? String else{
      os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
      return nil
    }
    
    guard let calories = aDecoder.decodeObject(forKey: PropertyKey.calories) as? Int else{
      os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
      return nil
    }
    
    let imagePath = aDecoder.decodeObject(forKey: PropertyKey.imagePath) as? String
    let rating = aDecoder.decodeObject(forKey: PropertyKey.rating) as? Int
    
    guard let user_id = aDecoder.decodeObject(forKey: PropertyKey.user_id) as? Int else{
      os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
      return nil
    }
    
    // Must call designated initializer.
    self.init(id: id, title: title, mealDescription: mealDescription, calories: calories, imagePath: imagePath, rating: rating, user_id: user_id)
    
  }
}
