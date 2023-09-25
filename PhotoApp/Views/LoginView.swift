//
//  LoginView.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 10.05.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore
struct LoginView: View {
    let didCompleteLoginProcess : () -> ()
    @StateObject private var  vm = SignIn_withGoogle_VM()
    @State var loginStatusMessage = ""
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var phoneNumber = ""
    @State private var name = ""
    @State private var birthday = Date()
    @State private var shouldShowImagePicker = false
    @State var showAlert = false
    @State var alertMessage = ""
    @State var image : UIImage?
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing:16){
                    Picker(selection: $isLoginMode, label: Text("Picker here")){
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    if !isLoginMode{//Giriş mi kayıt ol mu
                        Button{
                            shouldShowImagePicker.toggle()
                        }
                    label:{
                        VStack {
                            if let image = self.image{
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128)
                                    .cornerRadius(64)
                            }else{
                                Image(systemName: "person.fill")
                                    .font(.system(size: 64))
                                    .padding()
                                    .foregroundColor(Color(.label))
                            }
                        }
                    }
                        TextField("Name",text: $name)
                            .autocapitalization(.none)
                        TextField("Phone Number",text: $phoneNumber )
                            .autocapitalization(.none)
                        DatePicker(selection: $birthday, in: ...Date(), displayedComponents: .date) {
                            Text("Birtday")
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10.0)
                                .padding(.horizontal)
                        }
                        .padding()
                        .fixedSize()
                    }
                    
                    TextField("Email",text: $email)
                        .autocapitalization(.none)
                    
                    SecureField("Password",text: $password)
                    Button(action: {
                        Auth.auth().sendPasswordReset(withEmail: email) { error in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showAlert = true
                            } else {
                                alertMessage = "Password reset email has been sent."
                                showAlert = true
                            }
                        }
                    }){
                        Text("Forgot Password")
                    }
                    .padding()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Password Reset"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    Button{
                        handleAction()
                    }
                label: {
                    HStack{
                        Spacer()
                        Text(isLoginMode ? "Login" :"Create Account")
                            .foregroundColor(.white)
                            .padding(.vertical,10)
                        Spacer()
                    }.background(Color.blue)
                        .shadow(radius: 8)
                        .cornerRadius(8)
                }
                    Text("-----------------------------------------")
                    Text(self.loginStatusMessage)
                        .foregroundColor(.green)
                    Button{
                        vm.signInWithGoogle()

                        
                        
                        
                    }
                label: {
                    HStack{
                        Image("google_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height:40)
                            .padding(.leading,35)
                        Text("Sign in with Google")
                            .foregroundColor(.primary)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.vertical,20)
                    }
                    .background(Color.white)
                    .shadow(radius: 8)
                    .cornerRadius(8.0)
                    .border(Color.black, width: 2)
                }
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.green)
                    
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Login" :"Create Account")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil){
            ImagePicker(image:$image)}
    }
    //MARK---LOGİN-CREATE ACCOUNT SEKMESİ DEĞİŞTİRME
    private func handleAction(){
        if isLoginMode{
            print("Should log into Firebase with existing")
            LoginAccount()
        }else{
            createNewAccount()
            print("register a new account inside")
        }
    }
    
    //MARK---YENİ KULLANICI OLUŞTURMA
    private func createNewAccount(){
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
    //MARK--SEÇİLEN RESMİ VERİTABANINA PUSH YAPMA
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
    //MARK---KULLANICI OLUŞTUĞUNDA GİRİLEN BİLGİLERİNİ users TABLOSUNA YAZ
    private func storeUserInformation(imageProfileURL:URL){
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
    //MARK--KULLANICI GİRİŞİ
    private func LoginAccount(){
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
        
        // Prompt the user to re-provide their sign-in credentials
    }
}
    
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {
            
        })
    }
}
