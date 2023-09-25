//
//  User_VM.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 30.05.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore

class User_VM: ObservableObject {
    @Published var loginStatusMessage = ""
    @Published private var isLoginMode = false
    @Published private var email = ""
    @Published private var password = ""
    @Published private var phoneNumber = ""
    @Published private var name = ""
    @Published private var birthday = Date()
    @Published private var shouldShowImagePicker = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var image: UIImage?
    
    let didCompleteLoginProcess: () -> ()
    
    init(didCompleteLoginProcess: @escaping () -> ()) {
        self.didCompleteLoginProcess = didCompleteLoginProcess
    }
    func createNewAccount(){
        if self.image == nil{self.loginStatusMessage = "You must select avatar "
            return }
        Auth.auth().createUser(withEmail: email, password: password){
            result,err in
            if let err = err{
                print("Failed to create user:",err)
                self.loginStatusMessage = "failed"
                return
            }
            print("Successfully created user:\(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully"
            
            self.persistImageToStorage()
        }
    }
    public func persistImageToStorage(){
        guard let uid = Auth.auth().currentUser?.uid
        else {return}
        let ref = Storage.storage().reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5)else{return}
        ref.putData(imageData, metadata: nil){ metadata, err in
            if let err = err{
                self.loginStatusMessage = "Failed to push\(err)"
                return
            }
            ref.downloadURL{url,err in
                if let err = err {
                    self.loginStatusMessage="Failed to dowland:\(err)"
                    return
                }
                self.loginStatusMessage = "Succesfully url :"
                guard let url = url else {return }
                
                self.storeUserInformation(imageProfileURL: url)
            }
        }
        
    }
    //MARK-------------KULLANICI OLUŞTUĞUNDA GİRİLEN BİLGİLERİNİ users TABLOSUNA YAZ
    public func storeUserInformation(imageProfileURL:URL){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["name":self.name,"PhoneNumber":self.phoneNumber,"email": self.email,"Birtday":self.birthday, "uid": uid,"password":password, "profileImageUrl": imageProfileURL.absoluteString] as [String : Any]
        Firestore.firestore().collection("users").document(uid).setData(userData){err in
    
            if let err = err{
                print(err)
                self.loginStatusMessage="StoreUserInformation\(err)"
                return
            }
        }
    }
    func LoginAccount(){
        Auth.auth().signIn(withEmail: email, password: password){
            result,err in
            if let err = err{
                print("Failed to login user:",err)
                self.loginStatusMessage = "failed"
                return
            }
            print("Successfully login user:\(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully"
            self.didCompleteLoginProcess()
            print("sesese" ,self.didCompleteLoginProcess())
        }
    }
    func EmailPasswordReset(){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            } else {
                self.alertMessage = "Password reset email has been sent."
                self.showAlert = true
            }
        }
    }
    
}


