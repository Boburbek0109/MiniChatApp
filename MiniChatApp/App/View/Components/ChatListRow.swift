//
//  ChatListRow.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/27/26.
//

import SwiftUI

struct ChatListRow: View {
    
    var body: some View {
        VStack{
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 32))
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 44)
                            .stroke(.black, lineWidth: 1)
                    }
                
                VStack(alignment: .leading) {
                    Text("Username")
                        .font(.system(size: 16, weight: .bold))
                    Text("Message sent to User")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(.lightGray))
                }
                Spacer()
                
                Text("22d")
                    .font(.system(size: 14, weight: .semibold))
            }
            Divider()
                .padding(.vertical, 8)
        }
        .padding(.horizontal)
    }
}
