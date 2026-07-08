//
//  MessageRow.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/23/26.
//

import SwiftUI

struct MessageRow: View{
    
    let message: ChatMessageModel
    
    var body: some View{
        HStack{
            if message.isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                if !message.isFromCurrentUser {
                    Text(message.senderEmail ?? "Unknown")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(message.messages)
                    .padding(12)
                    .background(message.isFromCurrentUser ? Color.blue : Color(.systemGray6))
                    .foregroundStyle(message.isFromCurrentUser ? Color.white : Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(alignment: message.isFromCurrentUser ? .bottomTrailing : .bottomLeading){
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.title)
                            .rotationEffect(.degrees(message.isFromCurrentUser ? -45 : 45))
                            .offset(x: message.isFromCurrentUser ? 30 : -30, y: 10)
                            .foregroundStyle(message.isFromCurrentUser ? Color.blue : Color(.systemGray6))
                    }
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 260, alignment: message.isFromCurrentUser ? .trailing : .leading)
            
            if !message.isFromCurrentUser{
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        
    }
    
    private var formattedDate: String{
        if Calendar.current.isDateInToday(message.createdAt){
            return message.createdAt.formatted(date: .omitted, time: .shortened)
        }
        
        if Calendar.current.isDateInYesterday(message.createdAt){
            return "Yesterday, \(message.createdAt.formatted(date: .omitted, time: .shortened))"
        }
        
        return message.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
}

