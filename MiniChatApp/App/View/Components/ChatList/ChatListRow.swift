//
//  ChatListRow.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/27/26.
//

import SwiftUI

struct ChatListRow: View {
    
    let user: AppUser
    let chat: ChatModel
    
    let currentUserId: String
    
    private var unreadCount: Int {
        chat.unreadCounts(for: currentUserId)
    }
    
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
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 52))
                        .frame(width: 52, height: 52)
                }
                    
                    VStack(alignment: .leading) {
                        Text(user.username.isEmpty ? user.email : user.username)
                            .font(.system(size: 16, weight: .bold))
                        Text(chat.lastMessage)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.lightGray))
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.system(size: 8, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .init(horizontal: .leading, vertical: .center))
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
