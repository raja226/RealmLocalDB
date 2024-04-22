//
//  ViewController.swift
//  RealmLocalDB
//
//  Created by Administrator on 22/04/24.
//

import UIKit
import RealmSwift

class LoginCredentials: RealmSwift.Object {
    @objc dynamic var id: String = UUID().uuidString // Non-primary key property
    @objc dynamic var username: String = ""
    @objc dynamic var password: String = ""

//    override class func primaryKey() -> String? {
//        return "id"
//    }
}
class ViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Documents directory path: \(documentsDirectoryURL)")
        } else {
            print("Failed to retrieve documents directory path.")
        }
        
        //Custum config
        
        Realm.Configuration.defaultConfiguration = custumConfigRealm()
        
        if let realmFileURL = Realm.Configuration.defaultConfiguration.fileURL {
            let realmFilePath = realmFileURL.path
            print("Realm file path: \(realmFilePath)")
        }
        
         
        do {
            let realm = try Realm()
            let realmFileName = realm.configuration.fileURL?.lastPathComponent ?? "Unknown"
            print("Realm database name: \(realmFileName)")
        } catch {
            print("Error initializing Realm: \(error)")
        }
    }
    @IBAction func loginTapped(_ sender: UIButton) {
        insertheDatainRealm(username: userNameTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    
}

extension ViewController {
    
    func custumConfigRealm() -> Realm.Configuration
    {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Failed to retrieve documents directory URL.")
        }
        let customRealmURL = documentsDirectoryURL.appendingPathComponent("LoginCredentials.realm")
        let customRealmConfig = Realm.Configuration(fileURL: customRealmURL)
        
        return customRealmConfig
        
    }
    
    func insertheDatainRealm(username:String, password:String)
    {
        //Store the data :
        // Create an instance of LoginCredentials
        let loginCredentials = LoginCredentials()
        loginCredentials.username = username
        loginCredentials.password = password

        // Get a Realm instance
        do {
            let realm = try Realm()

            // Begin a write transaction
            try realm.write {
                // Add the LoginCredentials object to the Realm
                realm.add(loginCredentials)
                showAlert(withTitle: "Success", message: "Data Stored")

            }
        } catch {
            // Handle error
            print("Error initializing Realm: \(error)")
            
            showAlert(withTitle: "Error", message: "Failed store")
        }

    }
    
    func showAlert(withTitle title: String, message: String) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
}
