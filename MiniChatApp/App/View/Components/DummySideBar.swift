//
//  DummySideBar.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import SwiftUI

struct DummySideBar: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(ProfileViewModel.self) private var profileVM
    
    var onSettings: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let avatarURL = profileVM.avatarURL,
               let url = URL(string: avatarURL) {
                
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                        .padding(.bottom, 15)
                } placeholder: {
                    ProgressView()
                        .frame(width: 52, height: 52)
                        .padding(.bottom, 15)
                }
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 34, weight: .heavy))
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .padding(.bottom, 15)
                
            }
            
            Text(profileVM.username.isEmpty ? "No Username" : profileVM.username)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(authVM.appUser?.email ?? profileVM.profile?.email ?? "No Email")
                .foregroundStyle(.gray)
            
            Button{
               onSettings()
            } label: {
                Label("Go to Settings", systemImage: "gearshape")
            }
            .padding(.top, 15)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
    }
}
            
