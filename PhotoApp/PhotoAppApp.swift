//
//  PhotoAppApp.swift
//  PhotoApp
//
//  Created by ENES DEMİR on 10.05.2023.
//

import SwiftUI
import Firebase
import GoogleSignIn
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
    @available(iOS 9.0, *)
    func  application(_ apalication: UIApplication,open url: URL,options: [UIApplication.OpenURLOptionsKey:Any] = [:]) -> Bool{
        return GIDSignIn.sharedInstance.handle(url)
    }
}
@main
struct PhotoAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            TabBar()
        }
    }
}
