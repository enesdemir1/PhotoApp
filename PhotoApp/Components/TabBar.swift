//
//  TabBarView.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 17.05.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore
struct TabBar: View {
    @State var image : UIImage?
    @State var wshouldShowImagePicker = false
    @State var selectedCategory: Category?
    var body: some View {
       
        CustomNavBar()
        TabView {
            CategoriesView()
                .tabItem {
                    Image(systemName: "homekit")
                    Text("Home")
                }
            WelcomeView()
                .tabItem {
                    Image(systemName: "bell")
                    Text("Notifications")
                    
                }
            //----------------------------------
            CategoriesView()
                .tabItem {
                    Image(systemName: "plus.square.dashed")
                    Text("Join")
  
                }
            //----------------------------------
            LikeView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Like")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
