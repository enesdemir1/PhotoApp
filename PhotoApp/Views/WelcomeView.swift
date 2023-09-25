//
//  WelcomeView.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 10.05.2023.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            HStack {
                
                VStack {
                    
                    Text("WELCOME !")
                        .font(.caption)
                        .padding()
                        
                    Text("Take your best photo and upload it to win prizes!!!")
                    Text("PhotoMatch")
                }
            }
        }
        
        
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
