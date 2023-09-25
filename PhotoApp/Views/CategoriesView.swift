//
//  CategoriesView.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 10.05.2023.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct CategoriesView: View {
    @State var categories = [Category]()
    @ObservedObject var categoriesViewModel = Categories_VM()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(categoriesViewModel.categories) { category in
                        NavigationLink(destination: DashboardView(category: category)) {
                            Text(category.name)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8.0)
                        }
                    }
                }.padding()
            }
            .navigationTitle("Categories")
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
