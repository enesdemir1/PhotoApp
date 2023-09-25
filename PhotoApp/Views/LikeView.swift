//
//  LikeView.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 10.05.2023.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import SDWebImageSwiftUI

struct UserPhoto: Identifiable, Equatable {
    var id: String
    var imageURL: String
    var categoryID: String

    static func == (lhs: UserPhoto, rhs: UserPhoto) -> Bool {
        return lhs.id == rhs.id
    }
}
struct LikeView: View {
    @State private var userPhotos = [UserPhoto]()
    @State private var categories = [String: String]()
    var body: some View {
        VStack {
            if userPhotos.isEmpty {
                Text("Henüz fotoğraf yüklenmedi.")
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(userPhotos) { userPhoto in
                            if let imageURL = URL(string: userPhoto.imageURL) {
                                WebImage(url: imageURL)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 80)
                                    .cornerRadius(8)
                                
                                if let categoryName = categories[userPhoto.categoryID] {
                                    Text(categoryName)
                                        .foregroundColor(.black)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            fetchUserPhotos()
         
        }
    }

    func fetchUserPhotos() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("photo")
        
        collectionRef.whereField("userID", isEqualTo: currentUserID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching user photos: \(error.localizedDescription)")
                } else {
                    guard let documents = snapshot?.documents else {
                        print("No user photos found")
                        return
                    }
                    
                    var fetchedUserPhotos = [UserPhoto]()
                    
                    for document in documents {
                        let data = document.data()
                        guard let imageURL = data["imageURL"] as? String,
                              let categoryID = data["categoryID"] as? String else {
                                  continue
                        }
                        
                        let userPhoto = UserPhoto(id: document.documentID,
                                                  imageURL: imageURL,
                                                  categoryID: categoryID)
                        
                        fetchedUserPhotos.append(userPhoto)
                    }
                    
                    DispatchQueue.main.async {
                        userPhotos = fetchedUserPhotos
                    }
                }
            }
    }
    func fetchCategories() {
        let db = Firestore.firestore()
        let collectionRef = db.collection("categories")

        collectionRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else {
                    print("No categories found")
                    return
                }

                var fetchedCategories = [String: String]()

                for document in documents {
                    let data = document.data()
                    guard let categoryID = data["categoryID"] as? String,
                          let categoryName = data["categoryName"] as? String else {
                              continue
                    }

                    fetchedCategories[categoryID] = categoryName
                }

                DispatchQueue.main.async {
                    categories = fetchedCategories
                }
            }
        }
    }
}


struct LikeView_Previews: PreviewProvider {
    static var previews: some View {
        LikeView()
    }
}
