//
//  ChatListHeader.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/27/26.
//

import SwiftUI

struct ChatListHeader: View{
    @Environment(ProfileViewModel.self) private var profileVM
    
    var body: some View{
        VStack(alignment: .leading){
            HStack(spacing: 16) {
                if let avatarURL = profileVM.avatarURL,
                   let url = URL(string: avatarURL) {
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 34, weight: .heavy))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileVM.username.isEmpty ? "UserName" : profileVM.username)
                        .font(.system(size: 24, weight: .bold))
                    
                    HStack{
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(.lightGray))
                                  
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
    }
}
