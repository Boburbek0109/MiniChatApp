//
//  ContentView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/10/26.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(AuthViewModel.self) private var authVM
    @Environment(ProfileViewModel.self) private var profileVM
    
    var body: some View {
        
        if authVM.isAuthReady == false{
            ProgressView()
        } else if authVM.user == nil || authVM.isLoading == true{
            NavigationStack{
                LoginView()
            }
        } else if profileVM.profile == nil && profileVM.errorMessage != nil{
            VStack(spacing: 8){
                Text("Could not load profile")
                
                Button("Try again"){
                    profileVM.errorMessage = nil
                }
            }
        } else if profileVM.profile == nil  {
            ProgressView()
                .task {
                    await profileVM.loadProfile()
                }
        } else {
            MainView()
        }
    }
}
    
#Preview {
    ContentView()
        .environment(AuthViewModel())
        .environment(ProfileViewModel())
}
