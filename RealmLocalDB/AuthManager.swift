//
//  AuthManager.swift
//  RealmLocalDB
//
//  Created by Administrator on 24/04/24.
//

import Foundation
import RealmSwift

class AuthManager {
    static let shared = AuthManager()
    var currentUser: User? // Store the current user object
    
    //application-0-skqlq
    //application-0-anzuc : my personal thing one
    private let app = App(id: "application-0-anzuc")
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        app.login(credentials: Credentials.emailPassword(email: email, password: password)) { result in
            switch result {
            case .success(let user):
                print("Successfully logged in as user: \(user)")
                self.currentUser = user
                completion(.success(user))
            case .failure(let error):
                print("Failed to log in: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    /// Registers a new user with the email/password authentication provider.
    func signUp(email: String, password: String) async throws {
        do {
            try await app.emailPasswordAuth.registerUser(email: email, password: password)
            print("Successfully registered user")
            
        } catch {
            print("Failed to register user: \(error.localizedDescription)")
            throw error
        }
    }
}
