//
//  MiniChatAppApp.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/10/26.
//

import SwiftUI
import FirebaseCore

//class AppDelegate: NSObject, UIApplicationDelegate{
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//        return true
//    }
//}

@main
struct MiniChatAppApp: App {
    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var authVM: AuthViewModel
    @State private var profileVM: ProfileViewModel
    @State private var chatVM: ChatViewModel
    
    init(){
        FirebaseApp.configure()
        _authVM = State(initialValue: AuthViewModel())
        _profileVM = State(initialValue: ProfileViewModel())
        _chatVM = State(initialValue: ChatViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authVM)
                .environment(profileVM)
                .environment(chatVM)
        }
    }
}
