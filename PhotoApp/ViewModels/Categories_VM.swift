//
//  Categories_VM.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 17.05.2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
struct Category: Identifiable {
    let id: String
    let name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
class Categories_VM: ObservableObject {
    
    @Published var categories = [Category]()
    
    private var db = Firestore.firestore()
    
    init() {
        fetchCategories()
    }
    
    func fetchCategories() {
        db.collection("categories").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No categories found")
                return
            }
            self.categories = documents.map { document -> Category in
                let data = document.data()
                let id = document.documentID
                let name = data["categoriesName"] as? String
                return Category(id: id, name: data["categoriesName"] as! String)
            }
        }
    }
}
