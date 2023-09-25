//
//  DashboardView.swift
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
import UIKit
import Combine
import Foundation

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
struct DashboardView: View {
    
    var category: Category
    @State private var photos = [Photo]()
    @State var image : UIImage?
    @State private var shouldShowImagePicker = false
    @State private var refreshID = UUID()
    @State private var isShowingPreview = false
    @State private var isZoomed = false
    @State private var votes = [String: Int]()
    @State var voteCount: Int?
    
    @State private var winnerPhoto: Photo?
    @State private var isTimerActive = false
    
    @State private var timer: Timer?
    @State private var countdown: Int = 15
    @State private var isWinnerPhotoShown = false
    private let db = Firestore.firestore()
    var body: some View {
        
        VStack{
            Text("\(countdown) Saniye")
            Button(action: {
                self.shouldShowImagePicker = true
            }) {
                Text("Join")
            }
            .sheet(isPresented: $shouldShowImagePicker) {
                ImagePicker(image: $image)
                    .onDisappear {
                        self.uploadImage(image!)
                        self.isShowingPreview = true
                    }
            }
            .alert(isPresented: $isShowingPreview) {
                Alert(
                    title: Text("Selected Image"),
                    message: Text(""),
                    dismissButton: .cancel(Text("Close"))
                )
            }
            VStack {
                Text("\(self.category.id)")
                Text("\(self.category.name)")
                
                if photos.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: 264))
                        .padding()
                        .foregroundColor(Color(.label))
                } else {
                    if let winnerPhoto = winnerPhoto, isWinnerPhotoShown {
                        VStack {
                            Text("Kazanan")
                                .font(.headline)
                                .padding(.top, 10)
                            
                            if let imageURL = URL(string: winnerPhoto.imageURL) {
                                WebImage(url: imageURL)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 250, height: 250)
                                    .cornerRadius(8)
                            }
                            
                            if let uploadedByName = winnerPhoto.uploadedByName {
                                Text(uploadedByName)
                                    .font(.headline)
                                    .padding(.top, 10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        GeometryReader { geometry in
                            ScrollView {
                                ForEach(photos) { photo in
                                    VStack{
                                        if let uploadedByName = photo.uploadedByName {
                                            Text(uploadedByName)
                                                .font(.headline)
                                                .padding(.top, 10)
                                        }
                                        if let imageURL = URL(string: photo.imageURL) {
                                            WebImage(url: imageURL)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: isZoomed ? 400 : 250, height: isZoomed ? 400 : 250)
                                                .cornerRadius(8)
                                                .onTapGesture {
                                                    withAnimation {
                                                        isZoomed.toggle()
                                                    }
                                                }
                                        }
                                        HStack{
                                            Button(action: {
                                                // Oy verme işlemi
                                                voteForPhoto(photo)
                                                fetchPhotos()
                                            }) {
                                                Text("Oy Ver")
                                                    .foregroundColor(.white)
                                                    .padding()
                                                    .background(Color.blue)
                                                    .cornerRadius(8)
                                            }
                                            if let pho = photo.voteCount {
                                                Text("\(pho) Oy")
                                                    .foregroundColor(.black)
                                                    .font(.caption)
                                            } else {
                                                Text("0 Oy")
                                                    .foregroundColor(.black)
                                                    .font(.caption)
                                            }
                                            
                                        }
                                        
                                    }
                                    .background(Color.random)
                                    .frame(width: geometry.size.width)
                                    
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            
                        }
                    }
                }
            }
            .onAppear {
                fetchPhotos()
                startTimer()
            }
            .onReceive(NotificationCenter.default.publisher(for: .init("refreshDashboard"))) { _ in
                self.refreshID = UUID()
            }
        }
    }
    
    func fetchPhotos() {
        let db = Firestore.firestore()
        let collectionRef = db.collection("photo")
        
        collectionRef.whereField("categoryID", isEqualTo: category.id)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching photos: \(error.localizedDescription)")
                } else {
                    guard let documents = snapshot?.documents else {
                        print("No documents found")
                        return
                    }
                    
                    var updatedPhotos = [Photo]()
                    let group = DispatchGroup()
                    
                    for document in documents {
                        let data = document.data()
                        guard let imageURL = data["imageURL"] as? String,
                              let uploadedBy = data["userID"] as? String else {
                            continue
                        }
                        
                        let photoID = document.documentID
                        var photo = Photo(id: photoID,
                                          imageURL: imageURL,
                                          uploadedBy: uploadedBy,
                                          uploadedByName: nil)
                        
                        group.enter()
                        db.collection("votes")
                            .whereField("photoID", isEqualTo: photoID)
                            .getDocuments { snapshot, error in
                                defer {
                                    group.leave()
                                }
                                
                                if let error = error {
                                    print("Error fetching votes: \(error.localizedDescription)")
                                    return
                                }
                                
                                guard let documents = snapshot?.documents else {
                                    return
                                }
                                
                                var voteCount = documents.count
                                
                                if let voteDocument = documents.first, let count = voteDocument.data()["voteCount"] as? Int {
                                    voteCount = count
                                }
                                
                                photo.voteCount = voteCount
                                
                                DispatchQueue.main.async {
                                    updatedPhotos.append(photo)
                                }
                            }
                        
                        // Kullanıcı adını çekmek için Firestore'dan ilgili kullanıcı belgesini alma.
                        group.enter()
                        db.collection("users").document(uploadedBy).getDocument { snapshot, error in
                            defer {
                                group.leave()
                            }
                            
                            if let error = error {
                                print("Error fetching user: \(error.localizedDescription)")
                                return
                            }
                            
                            if let document = snapshot, document.exists, let userData = document.data(), let userName = userData["name"] as? String {
                                photo.uploadedByName = userName
                            }
                        }
                    }
                    
                    group.notify(queue: .main) {
                        photos = updatedPhotos
                    }
                }
            }
    }
    
    
    func uploadImage(_ image: UIImage) {
        let storageRef = Storage.storage().reference()
        let photoRef = storageRef.child("photo").child(UUID().uuidString + ".jpg")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            photoRef.putData(imageData, metadata: metadata) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                } else {
                    print("Image uploaded successfully.")
                    photoRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                        } else if let downloadURL = url {
                            print("Download URL: \(downloadURL.absoluteString)")
                            saveImageToFirestore(categoryID: category.id, userID: uid, imageURL: downloadURL)
                            fetchPhotos()
                        }
                    }
                }
            }
        }
    }
    func voteForPhoto(_ photo: Photo) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturum açmamış.")
            return
        }
        
        let voteRef = db.collection("votes").document(photo.id)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let voteDocument: DocumentSnapshot
            do {
                try voteDocument = transaction.getDocument(voteRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var votedUsers = voteDocument.data()?["votedUsers"] as? [String] else {
                let newVoteCount = (voteDocument.data()?["voteCount"] as? Int ?? 0) + 1
                transaction.updateData(["voteCount": newVoteCount], forDocument: voteRef)
                transaction.updateData(["votedUsers": FieldValue.arrayUnion([uid])], forDocument: voteRef)
                
                return newVoteCount
            }
            
            if votedUsers.contains(uid) {
                let newVoteCount = (voteDocument.data()?["voteCount"] as? Int ?? 0) - 1
                transaction.updateData(["voteCount": newVoteCount], forDocument: voteRef)
                transaction.updateData(["votedUsers": FieldValue.arrayRemove([uid])], forDocument: voteRef)
                
                if let index = votedUsers.firstIndex(of: uid) {
                    votedUsers.remove(at: index)
                }
            } else {
                let newVoteCount = (voteDocument.data()?["voteCount"] as? Int ?? 0) + 1
                transaction.updateData(["voteCount": newVoteCount], forDocument: voteRef)
                transaction.updateData(["votedUsers": FieldValue.arrayUnion([uid])], forDocument: voteRef)
                
                votedUsers.append(uid)
            }
            
            return votedUsers.count
        }) { (voteCount, error) in
            if let error = error {
                print("Error saving vote to Firestore: \(error.localizedDescription)")
            } else if let newVoteCount = voteCount as? Int {
                print("Vote saved to Firestore successfully.")
                fetchPhotos() // Fotoğrafları yeniden çek
            }
        }
    }
    
    
    
    func saveImageToFirestore(categoryID: String, userID: String, imageURL: URL) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("photo")
        let documentRef = collectionRef.document()
        let voteDocumentRef = db.collection("votes").document(documentRef.documentID) // Create a reference for the votes document
        
        let data: [String: Any] = [
            "categoryID": categoryID,
            "userID": userID,
            "imageURL": imageURL.absoluteString
        ]
        
        documentRef.setData(data) { error in
            if let error = error {
                print("Error saving image to Firestore: \(error.localizedDescription)")
            } else {
                print("Image saved to Firestore successfully.")
                NotificationCenter.default.post(name: .init("refreshDashboard"), object: nil)
                
                // Create an empty votes document with the same ID as the photo document
                let voteData: [String: Any] = [
                    "photoID": documentRef.documentID
                ]
                
                voteDocumentRef.setData(voteData) { error in
                    if let error = error {
                        print("Error saving votes document to Firestore: \(error.localizedDescription)")
                    } else {
                        print("Votes document saved to Firestore successfully.")
                    }
                }
            }
        }
    }


    func startTimer() {
        isTimerActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            
            if countdown <= 0 {
                timer.invalidate()
                endTimer()
            } else if countdown == 1 {
                fetchPhotos()
            }
        }
    }
    
    func endTimer() {
        isTimerActive = false
        
        timer?.invalidate()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let photoWithHighestVotes = photos.max(by: { $0.voteCount ?? 0 < $1.voteCount ?? 0 }) {
                winnerPhoto = photoWithHighestVotes
                isWinnerPhotoShown = true
            }
        }
    }
    
    
}


    


struct Photo: Identifiable {
    var id: String
    var imageURL: String
    var image: UIImage?
    var uploadedBy: String
    var voteCount: Int?
    var uploadedByName: String?
}



struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(category: Category(id: "1", name: "Selam"))
    }
}
