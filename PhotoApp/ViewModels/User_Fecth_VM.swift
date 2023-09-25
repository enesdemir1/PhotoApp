//
//  User_Fecth_VM.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 17.05.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SDWebImageSwiftUI
struct ChatUser{
    let uid,email,profileImageUrl,name: String
    
}
class User_Fecth_VM: ObservableObject{
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    init(){
        DispatchQueue.main.async {
            self.isUserCurrentlyLoggedOut = Auth.auth().currentUser?.uid == nil
            
        }
        
        fetchCurrentUser()
        
    }
    public func fetchCurrentUser(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            self.errorMessage = "Not find firebase UID"
            return}
        self.errorMessage = "\(uid)"
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user : \(error)"
                print("Failed to fetch current user:",error)
                return
            }
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
                
            }
            self.errorMessage = "Data:\(data.description)"
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let name = data["name"] as? String ?? ""
           // let phoneNumber = data["phoneNumber"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"] as? String ?? ""
            self.chatUser = ChatUser(uid: uid, email: email, profileImageUrl: profileImageUrl,name: name)
           // self.errorMessage = chatUser.profileImageUrl
        }
    }
    @Published var isUserCurrentlyLoggedOut = false
    func handleSignOut(){
        isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
    
    
    
}
