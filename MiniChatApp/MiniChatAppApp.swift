//
//  MiniChatAppApp.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/10/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct MiniChatAppApp: App {
    
    @AppStorage("appTextSize") private var appTextSize: AppTextSize = .medium
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    @State private var authVM: AuthViewModel
    @State private var profileVM: ProfileViewModel
    
    init(){
        FirebaseApp.configure()
        _authVM = State(initialValue: AuthViewModel())
        _profileVM = State(initialValue: ProfileViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authVM)
                .environment(profileVM)
                .onChange(of: authVM.user?.uid) { _, _ in
                    profileVM.clearProfile() }
                .task {
                    await authVM.monitorAuthState()
                }
                .preferredColorScheme(appTheme.colorScheme)
                .dynamicTypeSize(appTextSize.dynamicTypeSize)
        }
    }
}
