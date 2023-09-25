//
//  SignIn_withGoogle_VM.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 11.05.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore
import GoogleSignIn
import SDWebImageSwiftUI


class SignIn_withGoogle_VM: ObservableObject {
    
    @Published var isLoginSuccessed = false
    func signInWithGoogle(){
        guard let clientID = FirebaseApp.app()?.options.clientID else {return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController ) {user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard
                let user = user?.user,
                let idToken = user.idToken else { return }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString )
            Auth.auth().signIn(with: credential){ res, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let user = res?.user else{ return}
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if error != nil {
                                // handle error
                                return
                            }
                            
                            // Kullanıcı Firebase veritabanına kaydedin.
                            guard let user = authResult?.user else { return }
                            let db = Firestore.firestore()
                            let userData: [String: Any] = [
                                "uid": user.uid,
                                "name": user.displayName ?? "",
                                "email": user.email ?? "",
                                "profileImageUrl": user.photoURL?.absoluteString ?? ""
                            ]
                            db.collection("users").document(user.uid).setData(userData) { error in
                                if error != nil {
                                    // handle error
                                } else {
                                    // handle success
                                    
                            }
                            }
                        }
                
                
                
                }
            }
        
        }
    }
