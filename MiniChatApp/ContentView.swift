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
                if profileVM.isProfileMissing{
                    Text("Your profile hasn’t been created yet.")
                    Button{
                        Task{
                            await profileVM.recoverMissingProfile()
                        }
                    } label: {
                        Text("Create profile")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                } else {
                    Text("Could not load profile")
                }
                
                if let message = profileVM.errorMessage {
                    Text(message)
                }
                
                VStack(spacing: 12){
                    Button{
                        profileVM.errorMessage = nil
                    } label: {
                        Text("Try again")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.large)
                    
                    Button(role: .destructive) {
                        authVM.signOut()
                    } label: {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                    .tint(.red)
                    .controlSize(.large)
                    
                }
            }
            .padding(24)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)
            .disabled(profileVM.isLoading)
            
        } else if profileVM.profile == nil  {
            
            ProgressView()
                .task {
                    if profileVM.isLoading == false{
                        await profileVM.loadProfile()
                    }
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
