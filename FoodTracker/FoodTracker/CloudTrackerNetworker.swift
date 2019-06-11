//
//  CloudTrackerNetworker.swift
//  FoodTracker
//
//  Created by Frank Chen on 2019-06-10.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation
import UIKit

class CloudTrackerNetworker{
  
  var session = URLSession.shared
  let configuration = URLSessionConfiguration.default
  let api = "https://cloud-tracker.herokuapp.com/"
  let imgApi = "https://api.imgur.com/3/upload"
  let ud = UserDefaults.standard
  
  func post(data: [String:AnyObject], toEndpoint:String, token:String?, completion:@escaping (Data?, Error?, URLResponse?) -> (Void)){
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 30
    session = URLSession(configuration: configuration)
    let urlOptional = URL(string: "\(api)\(toEndpoint)")
    guard let url = urlOptional else {return}
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    if token != nil {
       request.addValue(token!, forHTTPHeaderField: "token")
    }
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
    } catch let error {
      print(error.localizedDescription)
    }
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
      
      if error != nil || data == nil {
        print("Client error!")
        return
      }
      DispatchQueue.main.async {
        completion(data,error,response)
      }
    })
    
    task.resume()
  }
  
  func get(toEndpoint:String, token:String?, completion:@escaping (Data?, Error?, URLResponse?) -> (Void)){
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 30
    session = URLSession(configuration: configuration)
    let urlOptional = URL(string: "\(api)\(toEndpoint)")
    guard let url = urlOptional else {return}
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    if token != nil {
      request.addValue(token!, forHTTPHeaderField: "token")
    }
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
      
      if error != nil || data == nil {
        print("Client error!")
        return
      }else{
        DispatchQueue.main.async {
          completion(data,error,response)
        }
      }
    })
    task.resume()
  }
  
  func postToImgur(image: UIImage, completion:@escaping (Data?, Error?, URLResponse?) -> (Void)){
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 30
    session = URLSession(configuration: configuration)
    let urlOptional = URL(string: "\(imgApi)")
    guard let url = urlOptional else {return}
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    request.addValue("Client-ID 887c27b7d390539", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let jpegData = UIImageJPEGRepresentation(image, 1)
    request.httpBody = jpegData
    
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
      
      if error != nil || data == nil {
        print("Client error!")
        return
      }
      DispatchQueue.main.async {
        completion(data,error,response)
      }
    })
    
    task.resume()
  }
  
  func getImage(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 30
    session = URLSession(configuration: configuration)
    session.dataTask(with: url, completionHandler: completion).resume()
  }
  
  func downloadImage(from url: URL, completion:@escaping (Data) -> ()) {
    print("Download Started")
    getImage(from: url) { data, response, error in
      guard let data = data, error == nil else { return }
      DispatchQueue.main.async {
        completion(data)
      }
      print("Download Finished")
    }
  }

}
