//
//  CustomNavBarView.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 17.05.2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import SDWebImageSwiftUI
struct CustomNavBar: View {
    @ObservedObject private var vm = User_Fecth_VM()
    @State var shouldShowLogOutOptions = false
    var body: some View {
        HStack{
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width:50 , height: 50)
                .clipped()
                .cornerRadius(44)
                .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color.black,lineWidth: 1))
                .shadow(radius: 5)

            VStack(alignment:.leading,spacing: 4){
                Text("\(vm.chatUser?.name ?? "")")
                    .font(.system(size: 24))
                HStack{
                    Circle()
                        .foregroundColor(.green)
                        .frame(width:14,height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color.green)
                        .shadow(radius: 8)
                }
            }
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                    .font(.system(size: 24,weight: .bold))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"),message: Text("What do you want"),buttons: [
                .destructive(Text("Log Out"), action: {print("log out'a basıldı")
                    vm.handleSignOut()
                }),.cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil){
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut=false
                self.vm.fetchCurrentUser()
            })
        }
    }
}

struct CustomNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavBar()
    }
}
