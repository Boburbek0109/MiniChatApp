//
//  MessageRow.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/23/26.
//

import SwiftUI

struct MessageRow: View{
    
    let message: ChatMessageModel
    
    private var formattedDate: String{
        if Calendar.current.isDateInToday(message.createdAt){
            return message.createdAt.formatted(date: .omitted, time: .shortened)
        }
        
        if Calendar.current.isDateInYesterday(message.createdAt){
            return "Yesterday, \(message.createdAt.formatted(date: .omitted, time: .shortened))"
        }
        
        return message.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
    
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
                
                Text(message.message)
                    .padding(12)
                    .background(message.isFromCurrentUser ? Color.blue : Color(.systemGray6))
                    .foregroundStyle(message.isFromCurrentUser ? Color.white : Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                
                Text(message.createdAt, style: .time)
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
}
