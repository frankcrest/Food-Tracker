//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by Frank Chen on 2019-06-10.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  
  @IBOutlet weak var usernameTextfield: UITextField!
  @IBOutlet weak var passwordTextfield: UITextField!
  let ud = UserDefaults.standard
  var authenticationStatus = false
  let cloudTracker = CloudTrackerNetworker()
  
  override func viewDidAppear(_ animated: Bool) {
    //check if user have saved username/password
    guard let username = ud.string(forKey: "username") else{return}
    guard let password = ud.string(forKey: "password")else {return}

    let parameters = ["username":username,"password":password] as [String:AnyObject]
    cloudTracker.post(data: parameters, toEndpoint: "login", token: nil) { (data, error, response) -> (Void) in
      if let error = error{
        print(error)
      }
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
          if json == nil{
          }else{
            let dict = json!
            self.ud.setValue(dict["token"], forKey: "token")
            self.authenticationStatus = true
            DispatchQueue.main.async {
              self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
          }
          print("The Response is : ",json as Any)
        } catch {
          print("JSON error: \(error.localizedDescription)")
        }
      }
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func signUpTapped(_ sender: UIButton) {
    guard let username = usernameTextfield.text else{return}
    guard let password = passwordTextfield.text else{return}
    
    if username == ud.string(forKey: "username") || password == ud.string(forKey: "password"){
      DispatchQueue.main.async {
        let ua = UIAlertController(title: "You already have an account with username \(username)", message: "Login Instead", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        ua.addAction(cancelAction)
        self.present(ua, animated: true, completion: nil)
      }
    }
    
    if username == "" || password == ""{
      let ua = UIAlertController(title: "Enter a valid username/password", message: "", preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
      ua.addAction(cancelAction)
      self.present(ua, animated: true, completion: nil)
    } else {
      let parameters = ["username":username,"password":password] as [String:AnyObject]
      cloudTracker.post(data: parameters, toEndpoint: "signup", token: nil) { (data, error,response) -> (Void) in
        if error != nil || data == nil {
          print("Client error!")
          return
        }
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
          guard let dict = json else{return}
          self.ud.setValue(dict["username"], forKey: "username")
          self.ud.setValue(dict["password"], forKey: "password")
          self.ud.setValue(dict["token"], forKey: "token")
          self.authenticationStatus = true
          DispatchQueue.main.async {
            self.performSegue(withIdentifier: "signupSegue", sender: self)
          }
          print("The Response is : ",json as Any)
        } catch {
          print("JSON error: \(error.localizedDescription)")
        }
      }
    }
  }
  
  @IBAction func loginTapped(_ sender: UIButton) {
    guard let username = usernameTextfield.text else{return}
    guard let password = passwordTextfield.text else{return}
    
    let parameters = ["username":username,"password":password] as [String:AnyObject]
    
    if username == "" || password == ""{
      let ua = UIAlertController(title: "Enter a valid username/password", message: "", preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
      ua.addAction(cancelAction)
      self.present(ua, animated: true, completion: nil)
    } else {
      cloudTracker.post(data: parameters, toEndpoint: "login", token: nil) { (data, error,response) -> (Void) in
        if error != nil || data == nil {
          print("Client error!")
          let ua = UIAlertController(title: "Enter a valid username/password", message: "", preferredStyle: .alert)
          let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
          ua.addAction(cancelAction)
          self.present(ua, animated: true, completion: nil)
          return
        }
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
          print("Oops!! there is server error!")
          DispatchQueue.main.async {
            let ua = UIAlertController(title: "Enter the correct username/password", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            ua.addAction(cancelAction)
            self.present(ua, animated: true, completion: nil)
          }
          return
        }
        do {
          let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
          if json == nil{
          }else{
            let dict = json!
            self.ud.setValue(dict["token"], forKey: "token")
            self.authenticationStatus = true
            DispatchQueue.main.async {
              self.performSegue(withIdentifier: "loginSegue", sender: self)
            }
          }
          print("The Response is : ",json as Any)
        } catch {
          print("JSON error: \(error.localizedDescription)")
        }
      }
    }
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    guard let username = usernameTextfield.text else{return false}
    guard let password = passwordTextfield.text else{return false}
    if username == "" || password == ""{
      return false
    } else if authenticationStatus == false{
      return false
    }
    return true
  }
}
