//
//  AppUser.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/14/26.
//

import FirebaseFirestore

struct AppUser: Codable, Hashable, Identifiable {
    var id: String{
        uid
    }
    
    let uid: String
    var username: String
    let email: String
    var bio: String
    var avatarURL: String?
    var birthDate: Date?
    
}
