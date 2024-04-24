//
//  ViewController.swift
//  RealmLocalDB
//
//  Created by Administrator on 22/04/24.
//

import UIKit
import RealmSwift

class LoginCredentials: Object {
    //@Persisted var id: String = UUID().uuidString     // Non-primary key property

    //ObjectId = ObjectId.generate()
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var username: String = ""
    @Persisted var password: String = ""
    @Persisted var owner_id: String = ""
    override class func primaryKey() -> String? {
        return "_id"
    }
}
class ViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let authManager = AuthManager.shared
    var currentUser: User?
    var realmObject = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("Documents directory path: \(documentsDirectoryURL)")
        } else {
            print("Failed to retrieve documents directory path.")
        }
        
        //Custum config
        /*
        Realm.Configuration.defaultConfiguration = localcustumConfigRealm()
        
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
        
        */
    }
    @IBAction func loginTapped(_ sender: UIButton) {
       // insertheDatainRealm(username: userNameTextField.text ?? "", password: passwordTextField.text ?? "")
        loginwithAtlasPersonalDetails();
    }
    
    func loginwithAtlasPersonalDetails() {
        
        authManager.login(email: "gogulayadhav@gmail.com", password: "Rajasekhar@226") { result in
            switch result {
            case .success(let user):
                print("Logged in as user: \(user)")
                self.currentUser = user
                self.createAtlasDatabaseforFlexSyncConfig(currentuser: user)
            case .failure(let error):
                print("Failed to log in: \(error.localizedDescription)")
            }
        }
        
    }
    
    func createAtlasDatabaseforFlexSyncConfig(currentuser: User) {
        do {
            // Create Realm configuration with Flex Sync enabled
            let app = App(id: "application-0-anzuc")
            let currentUser = app.currentUser
            
  
            
            let config = currentUser?.flexibleSyncConfiguration(cancelAsyncOpenOnNonFatalErrors: false) { subscriptions in
                
                if subscriptions.first(named: "todo") == nil {
                    subscriptions.append(QuerySubscription<LoginCredentials>(name: "todo") { $0.owner_id == currentuser.id })
                    // Create a flexible sync subscription for LoginCredentials
                   // subscriptions.append(QuerySubscription<LoginCredentials>(name: "Login", query: .none))
                }
            } ?? Realm.Configuration.defaultConfiguration

            // Open the Realm instance
            let realm = try Realm(configuration: config)

            print("Realm database created successfully")
            addItemToAtlasDatabase(realm: realm, currentUser: currentuser)
        } catch {
            print("Failed to create Realm database: \(error.localizedDescription)")
        }
    }

    
    func addItemToAtlasDatabase(realm:Realm, currentUser: User) {
        do {
            try realm.write {
                let item = LoginCredentials()
                item.username = userNameTextField.text ?? ""
                item.password = passwordTextField.text ?? ""
                item.owner_id = currentUser.id
                realm.add(item)
            }

            print("Item added to Realm successfully")
        } catch {
            print("Failed to add item to Realm: \(error.localizedDescription)")
        }
    }
    
}

extension ViewController {
    
    func localcustumConfigRealm() -> Realm.Configuration
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
