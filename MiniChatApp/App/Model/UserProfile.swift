//
//  UserProfile.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import FirebaseFirestore

struct UserProfile: Codable, Identifiable{
    @DocumentID var id: String?
    
    let uid: String
    let username: String
    let bio: String?
    let avatarUrl: String?
    let birthDate: Date?
    
}
