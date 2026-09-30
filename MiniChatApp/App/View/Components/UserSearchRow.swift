//
//  UserSearchRow.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 7/8/26.
//

import SwiftUI

struct UserSearchRow: View {
    let user: AppUser

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: user.avatarURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                if user.username.isEmpty {
                    Text("User")
                        .font(.headline)
                } else {
                    Text(user.username)
                        .font(.headline)
                }
                
                if !user.email.isEmpty {
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }
}
