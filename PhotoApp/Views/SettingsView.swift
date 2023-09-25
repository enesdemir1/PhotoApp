//
//  SettingsView.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 10.05.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import SDWebImageSwiftUI
import FirebaseStorage
import FirebaseFirestore



struct SettingsView: View {
    @ObservedObject private var vm = User_Fecth_VM()
    @State var newPassword = ""
    @State var confirmPassword = ""
    @State var showAlert = false
    @State var alertMessage = ""
    @State var image: UIImage?
    @State var showingImagePicker = false
    var body: some View {
        VStack{
            NavigationView{
                VStack {
                    
                    TextField("New Password",text:$newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    TextField("Again New Password",text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                   
                    Button(action: {
                        ChangePassword()
                    }) {
                        Text("Change Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8.0)
                    }
                    .padding()
                    //------Change Profile Image------------------------------
                        //---------------------------------------
                    }
                
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Change Password"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .navigationBarHidden(true)
                    
                }
                
            }
        }
        func ChangePassword(){
        
        guard newPassword == confirmPassword else {
                    print("Passwords do not match.")
                    alertMessage="Passwords do not match."
                    showAlert = true
                    return
                }
        if let user = Auth.auth().currentUser {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        print("Error updating password: \(error.localizedDescription)")
                        alertMessage = error.localizedDescription
                        showAlert = true
                        
                        return
                    }
                    
                    print("Password updated successfully!")
                    alertMessage="Password updated successfully!"
                    showAlert = true
                    handleSignOut()
                    LoginView(didCompleteLoginProcess: {})
                }
            } else {
                print("No authenticated user.")
                alertMessage="No authenticated user."
                showAlert = true
            }
            
    }
    func handleSignOut(){
        vm.isUserCurrentlyLoggedOut.toggle()
        try? Auth.auth().signOut()
    }
}

  
    

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}




   
 

