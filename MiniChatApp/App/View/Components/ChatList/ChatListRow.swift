//
//  ChatListRow.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/27/26.
//

import SwiftUI
import FirebaseCore

struct ChatListRow: View {
    
    let user: AppUser
    let chat: ChatModel
    
    var body: some View {
        VStack{
            NavigationLink{
                MessageView(receiver: user)
            } label: {
                HStack(spacing: 16) {
                    if let avatarURL = user.avatarURL,
                       let url = URL(string: avatarURL) {
                    
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 32))
                        .padding()
                        .overlay {
                            RoundedRectangle(cornerRadius: 44)
                                .stroke(.black, lineWidth: 1)
                        }
                }
                    
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .font(.system(size: 16, weight: .bold))
                        Text(chat.lastMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.lightGray))
                    }
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.system(size: 14, weight: .semibold))
                }
                Divider()
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal)
    }
    
    private var formattedDate: String{
        chat.updatedAt.formatted(
            .relative(
                presentation: .numeric,
                unitsStyle: .abbreviated
            )
        )
    }
}
